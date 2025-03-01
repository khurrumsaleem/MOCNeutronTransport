
# # A vector of SVectors, denoting the edge ID each face is connected to.
# function face_edge_connectivity(mesh::QuadrilateralMesh{Dim,T,U}) where {Dim,T,U}
#     if length(mesh.edges) === 0
#         @error "Mesh does not have edges!"
#     end
#     # A vector of MVectors of zeros for each face
#     # Each MVector is the length of the number of edges
#     face_edge = [MVector{4, U}(0, 0, 0, 0) for _ in eachindex(mesh.faces)]
#     # For each face in the mesh, generate the edges.
#     # Search for the index of the edge in the mesh.edges vector
#     # Insert the index of the edge into the face_edge connectivity vector
#     for i in eachindex(mesh.faces)
#         for (j, edge) in enumerate(edges(mesh.faces[i]))
#             face_edge[i][j] = searchsortedfirst(mesh.edges, SVector(edge.data))
#         end
#         if any(x->x === U(0), face_edge[i])
#             @error "Could not determine the face/edge connectivity of face $i"
#         end
#     end
#     return [SVector(sort!(conn).data) for conn in face_edge]
# end
# 
# # A vector of SVectors, denoting the edge ID each face is connected to.
# function face_edge_connectivity(mesh::TriangleMesh{Dim,T,U}) where {Dim,T,U}
#     if length(mesh.edges) === 0
#         @error "Mesh does not have edges!"
#     end
#     # A vector of MVectors of zeros for each face
#     # Each MVector is the length of the number of edges
#     face_edge = [MVector{3, U}(0, 0, 0) for _ in eachindex(mesh.faces)]
#     # For each face in the mesh, generate the edges.
#     # Search for the index of the edge in the mesh.edges vector
#     # Insert the index of the edge into the face_edge connectivity vector
#     for i in eachindex(mesh.faces)
#         for (j, edge) in enumerate(edges(mesh.faces[i]))
#             face_edge[i][j] = searchsortedfirst(mesh.edges, SVector(edge.data))
#         end
#         if any(x->x === U(0), face_edge[i])
#             @error "Could not determine the face/edge connectivity of face $i"
#         end
#     end
#     return [SVector(sort!(conn).data) for conn in face_edge]
# end
# 
# # 
# # # Return a mesh with boundary edges
# # function add_boundary_edges(mesh::M; boundary_shape="Unknown"
# #     ) where {M <: UnstructuredMesh_2D}
# #     if 0 === length(mesh.edge_face_connectivity)
# #         mesh = add_connectivity(mesh)
# #     end
# #     return M(name = mesh.name,
# #              points = mesh.points,
# #              edges = mesh.edges,
# #              materialized_edges = mesh.materialized_edges,
# #              faces = mesh.faces,
# #              materialized_faces = mesh.materialized_faces,
# #              edge_face_connectivity = mesh.edge_face_connectivity,
# #              face_edge_connectivity = mesh.face_edge_connectivity,
# #              boundary_edges = boundary_edges(mesh, boundary_shape),
# #              face_sets = mesh.face_sets
# #             )
# # end
# # 
# 
# # # Return a vector of the faces adjacent to the face of ID face
# # function adjacent_faces(face::UInt32, mesh::UnstructuredMesh_2D)
# #     edges = mesh.face_edge_connectivity[face]
# #     the_adjacent_faces = UInt32[]
# #     for edge in edges
# #         faces = mesh.edge_face_connectivity[edge]
# #         for face_id in faces
# #             if face_id != face && face_id != 0
# #                 push!(the_adjacent_faces, face_id)
# #             end
# #         end
# #     end
# #     return the_adjacent_faces
# # end
# # 
# # # Return a vector containing vectors of the edges in each side of the mesh's bounding shape, e.g.
# # # For a rectangular bounding shape the sides are North, East, South, West. Then the output would
# # # be [ [e1, e2, e3, ...], [e17, e18, e18, ...], ..., [e100, e101, ...]]
# # function boundary_edges(mesh::UnstructuredMesh_2D, boundary_shape::String)
# #     # edges which have face 0 in their edge_face connectivity are boundary edges
# #     the_boundary_edges = UInt32.(findall(x->x[1] === 0x00000000, mesh.edge_face_connectivity))
# #     if boundary_shape == "Rectangle"
# #         # Sort edges into NESW
# #         bb = boundingbox(mesh.points)
# #         y_north = bb.ymax
# #         x_east  = bb.xmax
# #         y_south = bb.ymin
# #         x_west  = bb.xmin
# #         p_NW = Point_2D(x_west, y_north)
# #         p_NE = bb.tr
# #         p_SE = Point_2D(x_east, y_south)
# #         p_SW = bb.bl
# #         edges_north = UInt32[] 
# #         edges_east = UInt32[] 
# #         edges_south = UInt32[] 
# #         edges_west = UInt32[] 
# #         # Insert edges so that indices move from NW -> NE -> SE -> SW -> NW
# #         for edge ∈  the_boundary_edges
# #             epoints = edgepoints(mesh.edges[edge], mesh.points)
# #             if all(x->abs(x[2] - y_north) < 1e-4, epoints)
# #                 insert_boundary_edge!(edge, p_NW, edges_north, mesh)
# #             elseif all(x->abs(x[1] - x_east) < 1e-4, epoints)
# #                 insert_boundary_edge!(edge, p_NE, edges_east, mesh)
# #             elseif all(x->abs(x[2] - y_south) < 1e-4, epoints)
# #                 insert_boundary_edge!(edge, p_SE, edges_south, mesh)
# #             elseif all(x->abs(x[1] - x_west) < 1e-4, epoints)
# #                 insert_boundary_edge!(edge, p_SW, edges_west, mesh)
# #             else
# #                 @error "Edge $edge could not be classified as NSEW"
# #             end
# #         end
# #         return [ edges_north, edges_east, edges_south, edges_west ]
# #     else
# #         return [ convert(Vector{UInt32}, the_boundary_edges) ]
# #     end 
# # end 
# # 
# 
# 
# # # Find the faces which share the vertex of ID v.
# # function faces_sharing_vertex(v::Integer, mesh::UnstructuredMesh_2D)
# #     shared_faces = UInt32[]
# #     for i ∈ 1:length(mesh.faces)
# #         if v ∈  mesh.faces[i]
# #             push!(shared_faces, UInt32(i))
# #         end
# #     end
# #     return shared_faces
# # end
# # 
# # 
# # # Insert the boundary edge into the correct place in the vector of edge indices, based on
# # # the distance from some reference point
# # function insert_boundary_edge!(edge_index::UInt32, p_ref::Point_2D, edge_indices::Vector{UInt32},
# #                                mesh::UnstructuredMesh_2D)
# #     # Compute the minimum distance from the edge to be inserted to the reference point
# #     insertion_distance = minimum(distance.(Ref(p_ref), 
# #                                            edgepoints(mesh.edges[edge_index], mesh.points)))
# #     # Loop through the edge indices until an edge with greater distance from the reference point
# #     # is found, then insert
# #     nindices = length(edge_indices)
# #     for i ∈ 1:nindices
# #         epoints = edgepoints(mesh.edges[edge_indices[i]], mesh.points)
# #         edge_distance = minimum(distance.(Ref(p_ref), epoints))
# #         if insertion_distance < edge_distance
# #             insert!(edge_indices, i, edge_index)
# #             return nothing
# #         end
# #     end
# #     insert!(edge_indices, nindices+1, edge_index)
# #     return nothing
# # end
# # 
# # 
# 
# # # If a point is a vertex
# # function isvertex(p::Point_2D, mesh::UnstructuredMesh_2D)
# #     for point in mesh.points
# #         if p ≈ point
# #             return true
# #         end
# #     end
# #     return false
# # end
# # 
# 
# # 
# # # Return the ID of the edge shared by two adjacent faces
# # function shared_edge(face1::UInt32, face2::UInt32, mesh::UnstructuredMesh_2D)
# #     for edge1 in mesh.face_edge_connectivity[face1]
# #         for edge2 in mesh.face_edge_connectivity[face2]
# #             if edge1 == edge2
# #                 return edge1
# #             end
# #         end
# #     end
# #     return 0x00000000 
# # end
