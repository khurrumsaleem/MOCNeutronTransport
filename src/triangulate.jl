"""
    triangulate(poly::ConvexPolygon{N, 2, T}) where {N, T}

Return an SVector of the `N`-2 triangles that partition the `ConvexPolygon`. 
Generated using fan triangulation.
"""
function triangulate(poly::ConvexPolygon{N, 2, T}) where {N, T}
    triangles = MVector{N-2, Triangle{2, T}}(undef)
    for i = 1:N-2
        triangles[i] = Triangle(poly[1], poly[i+1], poly[i+2])
    end 
    return SVector(triangles.data)
end

function triangulate(quad::Quadrilateral3D{T}, N::Int64) where {T}
    # N is the number of divisions of each edge
    N1 = N + 1
    triangles = MVector{2N1^2, Triangle3D{T}}(undef)
    if N === 0
        triangles[1] = Triangle3D(quad[1], quad[2], quad[3])
        triangles[2] = Triangle3D(quad[3], quad[4], quad[1])
    else
        for j = 0:N
            s₀ = j/N1 
            s₁ = (j + 1)/N1
            for i = 0:N
                r₀ = i/N1 
                r₁ = (i + 1)/N1
                triangles[2N1*j + 2i + 1] = Triangle3D(quad(r₀, s₀),
                                                       quad(r₁, s₀),
                                                       quad(r₀, s₁))
                triangles[2N1*j + 2i + 2] = Triangle3D(quad(r₀, s₁),
                                                       quad(r₁, s₀),
                                                       quad(r₁, s₁))
            end
        end
    end
    return triangles
end

function triangulate(tri6::QuadraticTriangle{Dim, T}, N::Int64) where {Dim, T}
    # N is the number of divisions of each edge
    triangles = MVector{(N + 1)^2, Triangle{Dim, T}}(undef)
    if N === 0
        triangles[1] = Triangle(tri6[1], tri6[2], tri6[3])
    else
        i = 1
        N1 = N + 1
        for s ∈ 1:N
            s₋₁ = (s-1)/N1
            s₀ = s/N1
            s₁ = (s + 1)/N1
            for r ∈ 0:N-s
                r₀ = r/N1
                r₁ = (r + 1)/N1
                triangles[i]   = Triangle(tri6(r₀, s₀), tri6(r₁, s₀ ), tri6(r₀, s₁))
                triangles[i+1] = Triangle(tri6(r₀, s₀), tri6(r₁, s₋₁), tri6(r₁, s₀))
                i += 2
            end
        end
        j = N1*N + 1
        s₀ = zero(T)
        s₁ = 1/N1
        for r ∈ 0:N
            r₀ = r/N1
            r₁ = (r + 1)/N1
            triangles[j] = Triangle(tri6(r₀, s₀), tri6(r₁, s₀), tri6(r₀, s₁))
            j += 1
        end
    end
    return SVector(triangles.data)
end

function triangulate(quad8::QuadraticQuadrilateral{Dim, T}, N::Int64) where {Dim, T}
    # N is the number of divisions of each edge
    N1 = N + 1
    triangles = Vector{Triangle{Dim, T}}(undef, 2N1^2)
    if N === 0
        triangles[1] = Triangle(quad8[1], quad8[2], quad8[3])
        triangles[2] = Triangle(quad8[3], quad8[4], quad8[1])
    else
        for j = 0:N
            s₀ = j/N1 
            s₁ = (j + 1)/N1
            for i = 0:N
                r₀ = i/N1 
                r₁ = (i + 1)/N1
                triangles[2N1*j + 2i + 1] = Triangle(quad8(r₀, s₀),
                                                     quad8(r₁, s₀),
                                                     quad8(r₀, s₁))
                triangles[2N1*j + 2i + 2] = Triangle(quad8(r₀, s₁),
                                                     quad8(r₁, s₀),
                                                     quad8(r₁, s₁))
            end
        end
    end
    return triangles
end
