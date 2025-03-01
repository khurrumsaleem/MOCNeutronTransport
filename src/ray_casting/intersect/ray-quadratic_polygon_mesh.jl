export intersect_faces_all,
       intersect_faces_all!,
       sorted_intersect_faces_all!

function intersect_faces_all(R::Ray2{UM_F}, mesh::QPolygonMesh{N}) where {N}
    r_miss = UM_F(INF_POINT)
    rvec = UM_F[]
    for fv_conn in fv_conn_iterator(mesh)
        for ev_conn in qpolygon_ev_conn_iterator(fv_conn)
            v1 = mesh.vertices[ev_conn[1]]
            v2 = mesh.vertices[ev_conn[2]]
            v3 = mesh.vertices[ev_conn[3]]
            r12 = ray_quadratic_segment_intersection(R, v1, v2, v3)
            if r12[1] != r_miss
                push!(rvec, r12[1])
            end
            if r12[2] != r_miss
                push!(rvec, r12[2])
            end
        end
    end
    return rvec
end

function intersect_faces_all!(rvec::Vector{UM_F},
                              R::Ray2{UM_F}, 
                              mesh::QPolygonMesh{N}) where {N}
    r_miss = UM_F(INF_POINT)
    nintersect = 0
    rvec_length = length(rvec)
    for fv_conn in fv_conn_iterator(mesh)
        for ev_conn in qpolygon_ev_conn_iterator(fv_conn)
            v1 = mesh.vertices[ev_conn[1]]
            v2 = mesh.vertices[ev_conn[2]]
            v3 = mesh.vertices[ev_conn[3]]
            r12 = ray_quadratic_segment_intersection(R, v1, v2, v3)
            if r12[1] != r_miss
                if nintersect + 1 <= rvec_length
                    rvec[nintersect + 1] = r12[1]
                    nintersect += 1
                else
                    push!(rvec, r12[1])
                    nintersect += 1
                    rvec_length += 1
                end
            end
            if r12[2] != r_miss
                if nintersect + 1 <= rvec_length
                    rvec[nintersect + 1] = r12[2]
                    nintersect += 1
                else
                    push!(rvec, r12[2])
                    nintersect += 1
                    rvec_length += 1
                end
            end
        end
    end
    return nintersect
end

function sorted_intersect_faces_all!(rvec::Vector{UM_F},
                                     R::Ray2{UM_F}, 
                                     mesh::QPolygonMesh{N}) where {N}
    r_miss = UM_F(INF_POINT)
    nintersect = 0
    rvec_length = length(rvec)
    for fv_conn in fv_conn_iterator(mesh)
        for ev_conn in qpolygon_ev_conn_iterator(fv_conn)
            v1 = mesh.vertices[ev_conn[1]]
            v2 = mesh.vertices[ev_conn[2]]
            v3 = mesh.vertices[ev_conn[3]]
            r12 = ray_quadratic_segment_intersection(R, v1, v2, v3)
            if r12[1] != r_miss
                if nintersect + 1 <= rvec_length
                    rvec[nintersect + 1] = r12[1]
                    nintersect += 1
                else
                    push!(rvec, r12[1])
                    nintersect += 1
                    rvec_length += 1
                end
            end
            if r12[2] != r_miss
                if nintersect + 1 <= rvec_length
                    rvec[nintersect + 1] = r12[2]
                    nintersect += 1
                else
                    push!(rvec, r12[2])
                    nintersect += 1
                    rvec_length += 1
                end
            end
        end
    end
    sort!(view(rvec, 1:nintersect))
    return nintersect
end
