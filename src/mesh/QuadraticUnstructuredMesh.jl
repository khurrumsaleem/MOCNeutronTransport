struct GeneralQuadraticUnstructuredMesh_2D <: QuadraticUnstructuredMesh_2D
    name::String
    points::Vector{Point_2D}
    edges::Vector{SVector{3, UInt32}}
    materialized_edges::Vector{QuadraticSegment_2D}
    faces::Vector{<:SArray{S, UInt32, 1, L} where {S<:Tuple, L}}
    materialized_faces::Vector{<:Face_2D}
    edge_face_connectivity::Vector{SVector{2, UInt32}}
    face_edge_connectivity::Vector{<:SArray{S, UInt32, 1, L} where {S<:Tuple, L}}
    boundary_edges::Vector{Vector{UInt32}}
    face_sets::Dict{String, Set{UInt32}}
end

function GeneralQuadraticUnstructuredMesh_2D(;
        name::String = "DefaultMeshName",
        points::Vector{Point_2D} = Point_2D[],
        edges::Vector{SVector{3, UInt32}} = SVector{3, UInt32}[],
        materialized_edges::Vector{QuadraticSegment_2D} = QuadraticSegment_2D[],
        faces::Vector{<:SArray{S, UInt32, 1, L} where {S<:Tuple, L}} = SVector{6, UInt32}[],
        materialized_faces::Vector{<:Face_2D} = Triangle6_2D[],
        edge_face_connectivity::Vector{SVector{2, UInt32}} = SVector{2, UInt32}[],
        face_edge_connectivity ::Vector{<:SArray{S, UInt32, 1, L} where {S<:Tuple, L}} = SVector{3, UInt32}[],
        boundary_edges::Vector{Vector{UInt32}} = Vector{UInt32}[],
        face_sets::Dict{String, Set{UInt32}} = Dict{String, Set{UInt32}}()
    )
        return GeneralUnstructuredMesh_2D(name,
                                          points,
                                          edges,
                                          materialized_edges,
                                          faces,
                                          materialized_faces,
                                          edge_face_connectivity,
                                          face_edge_connectivity,
                                          boundary_edges,
                                          face_sets,
                                         )
end

struct Triangle6Mesh_2D <: QuadraticUnstructuredMesh_2D
    name::String
    points::Vector{Point_2D}
    edges::Vector{SVector{3, UInt32}}
    materialized_edges::Vector{QuadraticSegment_2D}
    faces::Vector{SVector{3, UInt32}}
    materialized_faces::Vector{Triangle6_2D}
    edge_face_connectivity::Vector{SVector{2, UInt32}} 
    face_edge_connectivity::Vector{SVector{3, UInt32}} 
    boundary_edges::Vector{Vector{UInt32}}
    face_sets::Dict{String, Set{UInt32}}
end

function Triangle6Mesh_2D(;
        name::String = "DefaultMeshName",
        points::Vector{Point_2D} = Point_2D[],
        edges::Vector{SVector{3, UInt32}} = SVector{3, UInt32}[],
        materialized_edges::Vector{QuadraticSegment_2D} = QuadraticSegment_2D[],
        faces::Vector{SVector{6, UInt32}} = SVector{6, U}[],
        materialized_faces::Vector{Triangle6_2D} = Triangle6_D[],
        edge_face_connectivity::Vector{SVector{2, UInt32}} = SVector{2, UInt32}[],
        face_edge_connectivity ::Vector{SVector{3, UInt32}} = SVector{3, UInt32}[],
        boundary_edges::Vector{Vector{UInt32}} = Vector{UInt32}[],
        face_sets::Dict{String, Set{UInt32}} = Dict{String, Set{UInt32}}()
    )
        return Triangle6Mesh_2D(name,
                               points,
                               edges,
                               materialized_edges,
                               faces,
                               materialized_faces,
                               edge_face_connectivity,
                               face_edge_connectivity,
                               boundary_edges,
                               face_sets,
                              )
end

## Axis-aligned bounding box, in 2d a rectangle.
## Type-stable
#function bounding_box(mesh::M) where {M <: QuadraticUnstructuredMesh_2D}
#    # If the mesh does not have any quadratic faces, the bounding_box may be determined 
#    # entirely from the points. 
#    return bounding_box(mesh.points)
#end

