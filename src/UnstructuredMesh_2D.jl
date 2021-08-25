struct UnstructuredMesh_2D{P, F, T}
    points::NTuple{P, Point_2D{T}}
    faces::NTuple{F, Tuple{Vararg{Int64}}}
end

#Base.@kwdef struct UnstructuredMesh_2D{P, T}
#    points::NTuple{Point_2D{T}} = Point_2D{T}[]
#    edges::Vector{Vector{Int64}} = Vector{Int64}[]
#    faces::Vector{Vector{Int64}} = Vector{Int64}[]
#    face_connectivity
#    name::String = "DefaultMeshName"
#end
#
#
#
#
#
#
## Cell types are the same as VTK
#const UnstructuredMesh_2D_linear_cell_types = [5, 9]
#const UnstructuredMesh_2D_quadratic_cell_types = [22, 23]
#const UnstructuredMesh_2D_cell_types = [5,     # Triangle
#                                        9,     # Quadrilateral
#                                        22,    # Triangle6
#                                        23     # Quadrilateral8
#                                       ]
#
## Return each edge for a face
#function edges(face::Vector{Int64})
#    cell_type = face[1]
#    if cell_type == 5 # Triangle
#        return [
#                [face[2], face[3]],  
#                [face[3], face[4]],  
#                [face[4], face[2]]
#               ]
##    elseif cell_type = 9 # Quadrilateral
##
##    elseif cell_type = 22 # Quadratic Triangle
##
##    elseif cell_type = 23 # Quadratic Quadrilaterial
#    else
#        error("Unsupported cell type.")
#        return [[0]]
#    end
#end
#
## Create the edges for each face
#function edges(faces::Vector{Vector{Int64}})
#    edges_unfiltered = Vector{Int64}[]
#    for face in faces
#        # Get the edges for each face
#        face_edges = edges(face)
#        # Order the linear edge vertices by ID
#        for edge in face_edges 
#            if edge[2] < edge[1]
#                e1 = edge[1]
#                edge[1] = edge[2]
#                edge[2] = e1
#            end
#            # Add the edge to the list of edges
#            push!(edges_unfiltered, edge)
#        end
#    end
#    # Filter the duplicate edges
#    return sort(collect(Set(edges_unfiltered)))
#end
#
### Axis-aligned bounding box, a rectangle.
##function AABB(mesh::UnstructuredMesh; tight::Bool=false)
##    # If the mesh does not have any quadratic cells/faces, the AABB may be determined entirely from the 
##    # points. If the mesh does have quadratic cells/faces, we need to find the bounding box of the edges
##    # that border the mesh. This algorithm naively performs the bounding box for each edge.
##    if mesh.dim == 2
##        if any(x->x ∈ UnstructuredMesh_quadratic_cell_types, getindex.(mesh.faces, 1))
##            for edge in mesh.edges
##                # construct the edge
##                # Check warntype
###                AABB(
##            end
##        else # Can use points
##            x = map(p->p[1], points)
##            y = map(p->p[2], points)
##            xmin = minimum(x)
##            xmax = maximum(x)
##            ymin = minimum(y)
##            ymax = maximum(y)
##            return (xmin, ymin, xmax, ymax)
##        end
##    else
##
##    end
##end
#
## function AABV (volume, cuboid)
## hasEdges
## hasFaces
## hasCells
## setupFaces
## setupCells
## pointdata dict -> name of data -> data (array/array) cells over which it is defined and values 
## edgedata
## facedata
## celldata
## visualize
## write
## read
