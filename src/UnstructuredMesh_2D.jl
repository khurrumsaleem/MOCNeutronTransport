Base.@kwdef struct UnstructuredMesh_2D{T <: AbstractFloat}
    points::Vector{Point_2D{T}}
    edges::Union{Nothing, Vector{Union{
                                       NTuple{2, Int64},
                                       NTuple{3, Int64}
                                      }}} = nothing
    edges_materialized::Union{Nothing, Vector{Union{
                                                    LineSegment_2D{T},
                                                    QuadraticSegment_2D{T}
                                                   }}} = nothing
    faces::Vector{Union{
                        NTuple{4, Int64},
                        NTuple{5, Int64},
                        NTuple{7, Int64},
                        NTuple{9, Int64}
                       }}
    faces_materialized::Union{Nothing, Vector{Union{
                                                    Triangle_2D{T},
                                                    Quadrilateral_2D{T},
                                                    Triangle6_2D{T},
                                                    Quadrilateral8_2D{T}
                                                    }}} = nothing
    name::String = "DefaultMeshName"
    face_sets::Dict{String, Set{Int64}} = Dict{String, Set{Int64}}()
end

Base.broadcastable(mesh::UnstructuredMesh_2D) = Ref(mesh)
#    edges::NTuple{E, Tuple{Vararg{Int64}}}

# Cell types are the same as VTK
const UnstructuredMesh_2D_linear_cell_types = [5, # Triangle 
                                               9  # Quadrilateral
                                              ]
const UnstructuredMesh_2D_quadratic_cell_types = [22, # Triangle6
                                                  23  # Quadrilateral8
                                                 ]
const UnstructuredMesh_2D_cell_types = vcat(UnstructuredMesh_2D_linear_cell_types,
                                            UnstructuredMesh_2D_quadratic_cell_types)

# Return each edge for a face
# Note, this returns a vector of vectors because we want to mutate the elements of the edge vectors
function edges(face::Tuple{Vararg{Int64}})
    cell_type = face[1]
    n_vertices = length(face) - 1
    if face[1] ∈  UnstructuredMesh_2D_linear_cell_types 
        edges = [ [face[i], face[i+1]] for i = 2:n_vertices]
        # Add the final edge that connects first and last vertices
        push!(edges, [face[n_vertices + 1], face[2]])
    elseif face[1] ∈  UnstructuredMesh_2D_quadratic_cell_types
        # There are N linear vertices and N quadratic vertices
        N = n_vertices ÷ 2
        edges = [ [face[i], face[i+1], face[N + i]] for i = 2:N]
        # Add the final edge that connects first and last vertices
        push!(edges, [face[N+1], face[2], face[2N+1]])
    else
        error("Unsupported cell type.")
        edges = [[-1, -1]]
    end
    return edges
end

# Create the edges for each face
function edges(faces::NTuple{F, Tuple{Vararg{Int64}}}) where F
    edges_unfiltered = Vector{Int64}[]
    for face in faces
        # Get the edges for each face
        face_edges = edges(face)
        # Order the linear edge vertices by ID
        for edge in face_edges 
            if edge[2] < edge[1]
                e1 = edge[1]
                edge[1] = edge[2]
                edge[2] = e1
            end
            # Add the edge to the list of edges
            push!(edges_unfiltered, edge)
        end
    end
    # Filter the duplicate edges
    edges_filtered = sort(collect(Set(edges_unfiltered)))
    return Tuple([ Tuple(v) for v in edges_filtered ])
end

function submesh(mesh::UnstructuredMesh_2D, 
                 face_ids::Set{Int64};
                 name::String = "DefaultMeshName")
    # Setup faces and get all vertex ids
    faces = Vector{Vector{Int64}}(undef, length(face_ids))
    vertex_ids = Set{Int64}()
    for (i, face_id) in enumerate(face_ids)
        face = collect(mesh.faces[face_id])
        faces[i] = face
        union!(vertex_ids, Set(face[2:length(face)]))
    end
    # Need to remap vertex ids in faces to new ids
    vertex_ids_sorted = sort(collect(vertex_ids))
    vertex_map = Dict{Int64, Int64}()
    for (i,v) in enumerate(vertex_ids_sorted)
        vertex_map[v] = i
    end
    points = Vector{Point_2D{typeof(mesh.points[1].x[1])}}(undef, length(vertex_ids_sorted))
    for (i, v) in enumerate(vertex_ids_sorted)
        points[i] = mesh.points[v]
    end
    # remap vertex ids in faces
    for face in faces
        for (i, v) in enumerate(face[2:length(face)])
            face[i + 1] = vertex_map[v] 
        end
    end
    # At this point we have points, faces, & name.
    # Just need to get the face sets
    face_sets = Dict{String, Set{Int64}}()
    for face_set_name in keys(mesh.face_sets)
        set_intersection = intersect(mesh.face_sets[face_set_name], face_ids)
        if length(set_intersection) !== 0
            face_sets[face_set_name] = set_intersection
        end
    end
    # Need to remap face ids in face sets
    face_map = Dict{Int64, Int64}()
    for (i,f) in enumerate(face_ids)
        face_map[f] = i
    end
    for face_set_name in keys(face_sets)                                       
        new_set = Set{Int64}()
        for fid in face_sets[face_set_name]
            union!(new_set, face_map[fid])
        end
        face_sets[face_set_name] = new_set
    end
    faces_tuple = Vector{Union{
                                NTuple{4, Int64},
                                NTuple{5, Int64},
                                NTuple{7, Int64},
                                NTuple{9, Int64}
                               }}(undef, length(faces))
    for i in eachindex(faces)
        faces_tuple[i] = Tuple(faces[i])
    end
    return UnstructuredMesh_2D(points = points,
                               faces = faces_tuple,
                               name = name,
                               face_sets = face_sets
                              )
end

function submesh(mesh::UnstructuredMesh_2D, set_name::String)
    @debug "Creating submesh for '$set_name'"
    face_ids = mesh.face_sets[set_name]
    return submesh(mesh, face_ids, name = set_name) 
end

# Axis-aligned bounding box, in 2d a rectangle.
function AABB(mesh::UnstructuredMesh_2D; rectangular_boundary=false)
    # If the mesh does not have any quadratic faces, the AABB may be determined entirely from the 
    # points. If the mesh does have quadratic cells/faces, we need to find the bounding box of the edges
    # that border the mesh.
    if (any(x->x ∈  UnstructuredMesh_2D_quadratic_cell_types, getindex.(mesh.faces, 1)) && 
        !rectangular_boundary)
        error("Cannot find AABB for a mesh with quadratic faces that does not have a rectangular boundary")
    else # Can use points
        x = map(p->p[1], mesh.points)
        y = map(p->p[2], mesh.points)
        xmin = minimum(x)
        xmax = maximum(x)
        ymin = minimum(y)
        ymax = maximum(y)
        return Quadrilateral_2D(Point_2D(xmin, ymin), 
                                Point_2D(xmax, ymin),
                                Point_2D(xmax, ymax),
                                Point_2D(xmin, ymax))
    end
end

function get_face_points(mesh::UnstructuredMesh_2D, 
                         face::Union{
                                       NTuple{4, Int64},
                                       NTuple{5, Int64},
                                       NTuple{7, Int64},
                                       NTuple{9, Int64}
                                     })
    T = typeof(mesh.points[1].x[1])
    points = Vector{Point_2D{T}}(undef, length(face) - 1)
    i = 1
    for pt in face[2:length(face)]
        points[i] = mesh.points[pt]
        i += 1
    end
    return Tuple(points)
end

function area(mesh::UnstructuredMesh_2D, face_set::Set{Int64}) 
    unsupported = sum(x->x[1] ∉  UnstructuredMesh_2D_cell_types, mesh.faces)
    if 0 < unsupported
        @warn "Mesh contains an unsupported face type"
    end
    return mapreduce(x->area(mesh, mesh.faces[x]), +, face_set)
end

function area(mesh::UnstructuredMesh_2D, set_name::String)
    return area(mesh, mesh.face_sets[set_name])
end

function area(mesh::UnstructuredMesh_2D{T}, face::NTuple{4, Int64}) where {T <: AbstractFloat}
    the_area = T(0)
    type_id = face[1]
    if type_id == 5 # Triangle
        the_area = area(Triangle_2D(get_face_points(mesh, face)))
    end
    return the_area
end

function area(mesh::UnstructuredMesh_2D{T}, face::NTuple{5, Int64}) where {T <: AbstractFloat}
    the_area = T(0)
    type_id = face[1]
    if type_id == 9 # Quadrilateral
        the_area = area(Quadrilateral_2D(get_face_points(mesh, face)))
    end
    return the_area
end

function area(mesh::UnstructuredMesh_2D{T}, face::NTuple{7, Int64}) where {T <: AbstractFloat}
    the_area = T(0)
    type_id = face[1]
    if type_id == 22 # Triangle6
        the_area = area(Triangle6_2D(get_face_points(mesh, face)))
    end
    return the_area
end

function area(mesh::UnstructuredMesh_2D{T}, face::NTuple{9, Int64}) where {T <: AbstractFloat}
    the_area = T(0)
    type_id = face[1]
    if type_id == 23 # Quadrilateral8
        the_area = area(Quadrilateral8_2D(get_face_points(mesh, face)))
    end
    return the_area
end

function intersect_faces(l::LineSegment_2D{T}, mesh::UnstructuredMesh_2D{T}
                        ) where {T <: AbstractFloat}
    # An array to hold all of the intersection points
    intersection_points = Point_2D{T}[]
    # Check if any of the face types are unsupported
    unsupported = sum(x->x[1] ∉  UnstructuredMesh_2D_cell_types, mesh.faces)
    if 0 < unsupported
        @warn "Mesh contains an unsupported face type"
    end
    if mesh.faces_materialized != nothing
        intersections = l .∩ mesh.faces_materialized
        for i in eachindex(intersections)
            # If the intersections yields 1 or more points, push those points to the array of points
            npoints = intersections[i][1]
            if 0 < npoints 
                append!(intersection_points, collect(intersections[i][2][1:npoints]))
            end
        end
        intersections = nothing
    else
        # Intersect the line with each of the faces
        for face in mesh.faces              
            type_id = face[1]
            npoints = 0
            if type_id == 5 # Triangle
                npoints, points = l ∩ Triangle_2D(get_face_points(mesh, face))
            elseif type_id == 9 # Quadrilateral
                npoints, points = l ∩ Quadrilateral_2D(get_face_points(mesh, face))
            elseif type_id == 22 # Triangle6
                npoints, points = l ∩ Triangle6_2D(get_face_points(mesh, face))
            elseif type_id == 23 # Quadrilateral8
                npoints, points = l ∩ Quadrilateral8_2D(get_face_points(mesh, face))
            end
            # If the intersections yields 1 or more points, push those points to the array of points
            if 0 < npoints 
                append!(intersection_points, collect(points[1:npoints]))
            end
        end
    end
    # Sort the points based upon their distance to the first point
    distances = distance.(l.points[1], intersection_points)
    sorted_pairs = sort(collect(zip(distances, intersection_points)); by=first);
    intersection_points = getindex.(sorted_pairs, 2)
    # Remove duplicate points
    intersection_points_reduced = Point_2D{T}[]
    push!(intersection_points_reduced, intersection_points[1]) 
    for i = 2:length(intersection_points)
        if last(intersection_points_reduced) ≉ intersection_points[i]
            push!(intersection_points_reduced, intersection_points[i])
        end
    end
    return intersection_points_reduced
end

function materialize_faces(mesh::UnstructuredMesh_2D{T}) where {T <: AbstractFloat}
    mat_faces = convert(Union{Nothing, Vector{Union{
                                                    Quadrilateral8_2D{T}, 
                                                    Quadrilateral_2D{T}, 
                                                    Triangle6_2D{T}, 
                                                    Triangle_2D{T}}
                                                   }}, materialized_face.(mesh, mesh.faces))
    return UnstructuredMesh_2D(points = mesh.points,
                               edges = mesh.edges,
                               edges_materialized = mesh.edges_materialized,
                               faces = mesh.faces,
                               faces_materialized = mat_faces,
                               name = mesh.name,
                               face_sets = mesh.face_sets
                              )
end

function materialized_faces(mesh::UnstructuredMesh_2D{T}) where {T <: AbstractFloat}
    return materialize_face.(mesh, mesh.faces)
end

function materialized_face(mesh::UnstructuredMesh_2D{T},
                          face:: Union{
                                       NTuple{4, Int64},
                                       NTuple{5, Int64},
                                       NTuple{7, Int64},
                                       NTuple{9, Int64}
                                      }) where {T <: AbstractFloat}
    type_id = face[1]
    if type_id == 5 # Triangle
        return Triangle_2D(get_face_points(mesh, face))
    elseif type_id == 9 # Quadrilateral
        return Quadrilateral_2D(get_face_points(mesh, face))
    elseif type_id == 22 # Triangle6
        return Triangle6_2D(get_face_points(mesh, face))
    elseif type_id == 23 # Quadrilateral8
        return Quadrilateral8_2D(get_face_points(mesh, face))
    else
        @error "Unsupported face type"
        return Triangle_2D(get_face_points(mesh, face[2:4])) 
    end
end

function Base.show(io::IO, mesh::UnstructuredMesh_2D)
    println(io, mesh.name)
    size_MB = Base.summarysize(mesh)/1E6
    println(io, "  ├─ Size (MB) : $size_MB")
    type = typeof(mesh.points[1].x[1])
    println(io, "  ├─ Type      : $type")
    npoints = length(mesh.points)
    println(io, "  ├─ Points    : $npoints")
    nfaces = length(mesh.faces)
    println(io, "  ├─ Faces     : $nfaces")
    ntri   = sum(x->x[1] == 5,  mesh.faces)
    nquad  = sum(x->x[1] == 9,  mesh.faces)
    ntri6  = sum(x->x[1] == 22, mesh.faces)
    nquad8 = sum(x->x[1] == 23, mesh.faces)
    println(io, "  │  ├─ Triangle       : $ntri")
    println(io, "  │  ├─ Quadrilateral  : $nquad")
    println(io, "  │  ├─ Triangle6      : $ntri6")
    println(io, "  │  └─ Quadrilateral8 : $nquad8")
    nface_sets = length(keys(mesh.face_sets))
    println(io, "  └─ Face sets : $nface_sets")
end
