abstract type UnstructuredMesh_2D end

# Area of face
# Type-stable
function area(face::SVector{N, UInt32}, points::Vector{Point_2D}) where {N}
    return area(materialize_face(face, points))
end

# Return the area of a face set
# Type-stable if the faces are the same type
function area(mesh::M, face_set::Set{UInt32}) where {M <: UnstructuredMesh_2D} 
    if 0 < length(mesh.materialized_faces)
        return mapreduce(x->area(mesh.materialized_faces[x]), +, face_set)
    else
        return mapreduce(x->area(mesh.faces[x], mesh.points), +, face_set)
    end 
end

# Return the area of a face set by name
# Type-stable if the faces are the same type
function area(mesh::M, set_name::String) where {M <: UnstructuredMesh_2D} 
    return area(mesh, mesh.face_sets[set_name])
end

#function bounding_box(points::Vector{Point_2D})
#    x = getindex.(points, 1)
#    y = getindex.(points, 2)
#    xmin = minimum(x)
#    xmax = maximum(x)
#    ymin = minimum(y)
#    ymax = maximum(y)
#    return Quadrilateral_2D(Point_2D(xmin, ymin),
#                            Point_2D(xmax, ymin),
#                            Point_2D(xmax, ymax),
#                            Point_2D(xmin, ymax))
#end


# SVector of MVectors of point IDs representing the 3 edges of a triangle
# Type-stable
function edges(face::SVector{3, UInt32})
    edges = SVector( MVector{2, UInt32}(face[1], face[2]),
                     MVector{2, UInt32}(face[2], face[3]),
                     MVector{2, UInt32}(face[3], face[1]) )
    # Order the linear edge vertices by ID
    for edge in edges
        if edge[2] < edge[1]
            e1 = edge[1]
            edge[1] = edge[2]
            edge[2] = e1
        end
    end
    return edges
end

# SVector of MVectors of point IDs representing the 4 edges of a quadrilateral
# Type-stable
function edges(face::SVector{4, UInt32})
    edges = SVector( MVector{2, UInt32}(face[2], face[3]),
                     MVector{2, UInt32}(face[3], face[4]),
                     MVector{2, UInt32}(face[4], face[5]),
                     MVector{2, UInt32}(face[5], face[2]) )
    # Order the linear edge vertices by ID
    for edge in edges
        if edge[2] < edge[1]
            e1 = edge[1]
            edge[1] = edge[2]
            edge[2] = e1
        end
    end
    return edges
end

# SVector of MVectors of point IDs representing the 3 edges of a quadratic triangle
# Type-stable
function edges(face::SVector{6, UInt32})
    edges = SVector( MVector{3, UInt32}(face[2], face[3], face[5]),
                     MVector{3, UInt32}(face[3], face[4], face[6]),
                     MVector{3, UInt32}(face[4], face[2], face[7]) )
    # Order the linear edge vertices by ID
    for edge in edges
        if edge[2] < edge[1]
            e1 = edge[1]
            edge[1] = edge[2]
            edge[2] = e1
        end
    end
    return edges
end

# SVector of MVectors of point IDs representing the 4 edges of a quadratic quadrilateral
# Type-stable
function edges(face::SVector{8, UInt32})
    edges = SVector( MVector{3, UInt32}(face[2], face[3], face[6]),
                     MVector{3, UInt32}(face[3], face[4], face[7]),
                     MVector{3, UInt32}(face[4], face[5], face[8]),
                     MVector{3, UInt32}(face[5], face[2], face[9]) )
    # Order th linear edge vertices by ID
    for edge in edges
        if edge[2] < edge[1]
            e1 = edge[1]
            edge[1] = edge[2]
            edge[2] = e1
        end
    end
    return edges
end

# The unique edges from a vector of triangles or quadrilaterals represented by point IDs
# Type-stable if faces are the same type
function edges(mesh::M) where {M <: UnstructuredMesh_2D}
    edges_filtered = sort(unique(reduce(vcat, edges.(mesh.faces))))
    return [ SVector(e.data) for e in edges_filtered ]
end

# Return an SVector of the points in the edge (Linear)
# Type-stable
function edge_points(edge::SVector{2, UInt32}, points::Vector{Point_2D})
    return SVector(points[edge[1]], points[edge[2]])
end

# Return an SVector of the points in the edge (Quadratic)
# Type-stable
function edge_points(edge::SVector{3, UInt32}, points::Vector{Point_2D})
    return SVector(points[edge[1]], points[edge[2]], points[edge[3]])
end

# Return an SVector of the points in the edge
# Type-stable for Tri/Tri6 meshes
function edge_points(edge_id::UInt32, mesh::M) where {M <: UnstructuredMesh_2D}
    return edge_points(mesh.edges[edge_id], mesh.points)
end

# Return an SVector of the points in the face (Triangle)
# Type-stable
function face_points(face::SVector{3, UInt32}, points::Vector{Point_2D})
    return SVector(points[face[1]], points[face[2]], points[face[3]])
end

# Return an SVector of the points in the face (Quadrilateral)
# Type-stable
function face_points(face::SVector{4, UInt32}, points::Vector{Point_2D})
    return SVector(points[face[1]], points[face[2]], points[face[3]], points[face[4]])
end

# Return an SVector of the points in the face (Triangle6)
# Type-stable
function face_points(face::SVector{6, UInt32}, points::Vector{Point_2D})
    return SVector(points[face[1]], points[face[2]], points[face[3]],
                   points[face[4]], points[face[5]], points[face[6]])
end

# Return an SVector of the points in the face (Quadrilateral8)
# Type-stable
function face_points(face::SVector{8, UInt32}, points::Vector{Point_2D})
    return SVector(points[face[1]], points[face[2]], points[face[3]], points[face[4]],
                   points[face[5]], points[face[6]], points[face[7]], points[face[8]])
end

# Return an SVector of the points in the face
# Type-stable for Tri/Tri6 meshes
function face_points(edge_id::UInt32, mesh::M) where {M <: UnstructuredMesh_2D}
    return face_points(mesh.faces[edge_id], mesh.points)
end

# Return a LineSegment_2D from the point IDs in an edge
# Type-stable
function materialize_edge(edge::SVector{2, UInt32}, points::Vector{Point_2D})
    return LineSegment_2D(edge_points(edge, points))
end

# Return a QuadraticSegment_2D from the point IDs in an edge
# Type-stable
function materialize_edge(edge::SVector{3, UInt32}, points::Vector{Point_2D})
    return QuadraticSegment_2D(edge_points(edge, points))
end

# Return a LineSegment_2D or QuadraticSegment_2D
# Type-stable
function materialize_edge(edge_id::UInt32, mesh::M) where {M <: UnstructuredMesh_2D}
    return materialize_edge(mesh.edges[edge_id], mesh.points)
end

# Return a materialized edge for each edge in the mesh
# Type-stable
function materialize_edges(mesh::M) where {M <: UnstructuredMesh_2D}
    return materialize_edge.(mesh.edges, Ref(mesh.points))
end

# Return a Triangle_2D from the point IDs in a face
# Type-stable
function materialize_face(face::SVector{3, UInt32}, points::Vector{Point_2D})
    return Triangle_2D(face_points(face, points))
end

# Return a Quadrilateral_2D from the point IDs in a face
# Type-stable
function materialize_face(face::SVector{4, UInt32}, points::Vector{Point_2D})
    return Quadrilateral_2D(face_points(face, points))
end

# Return a Triangle6_2D from the point IDs in a face
# Type-stable
function materialize_face(face::SVector{6, UInt32}, points::Vector{Point_2D})
    return Triangle6_2D(face_points(face, points))
end

# Return a Quadrilateral8_2D from the point IDs in a face
# Type-stable
function materialize_face(face::SVector{8, UInt32}, points::Vector{Point_2D})
    return Quadrilateral8_2D(face_points(face, points))
end

# Return an SVector of the points in the edge
# Type-stable
function materialize_face(face_id::UInt32, mesh::M) where {M <: UnstructuredMesh_2D}
    return materialize_face(mesh.faces[face_id], mesh.points)
end

# Return a materialized face for each face in the mesh
# Type-stable on the condition that the faces are all the same type
function materialize_faces(mesh::M) where {M <: UnstructuredMesh_2D}
    return materialize_face.(mesh.faces, Ref(mesh.points))
end

# Return the number of edges in a face
# Type-stable other than the error message
function num_edges(face::SVector{L, UInt32}) where {L}
    if L % 3 === 0 
        return 0x00000003
    elseif L % 4 === 0
        return 0x00000004
    else
        # Error
        return 0x00000000
    end
end

