import Base: intersect
# A quadratic segment in 3D space that passes through three points: x⃗₁, x⃗₂, and x⃗₃
# The assumed relation of the points may be seen in the diagram below:
#                 ___x⃗₃___
#            ____/        \____
#        ___/                  \___
#     __/                          \__
#   _/                                \__
#  /                                     \
# x⃗₁--------------------------------------x⃗₂
#
# NOTE: x⃗₃ is between x⃗₁ and x⃗₂
#
# Let u⃗ = x⃗₂-x⃗₁. Then the parametric representation of the vector from x⃗₁ to x⃗₂
# is u⃗(t) = x⃗₁ + tu⃗ , with t ∈ [0, 1].
#
# The parametric representation of the quadratic curve is
# q(t) = (a|tu⃗|² + b|tu⃗|)ŷ + tu⃗ + x⃗₁
# similar to the familiar y(x) = ax² + bx + c, where ŷ is the unit vector in the same plane as
# x⃗₁, x⃗₂, and x⃗₃, such that ŷ ⟂ u⃗ and is pointing towards x⃗₃.
# We also define v⃗ = x⃗₃-x⃗₁. We see the ŷ vector may be computed by:
# ŷ = -((v⃗ × u⃗) × u⃗)/|(v⃗ × u⃗) × u⃗|
# A diagram of these relations may be seen below:
#                   x⃗₃
#               /
#       v⃗    /      ^
#         /         | ŷ
#      /            |
#   /               |
# x⃗₁--------------------------------------x⃗₂
#                              u⃗
struct QuadraticSegment{T <: AbstractFloat} <: Edge
    x⃗::NTuple{3,Point{T}}
    a::T
    b::T
    ŷ::Point{T}
end

# Constructors
# -------------------------------------------------------------------------------------------------
function QuadraticSegment(x⃗₁::Point{T}, x⃗₂::Point{T}, x⃗₃::Point{T}) where {T <: AbstractFloat}
    # Using q(1) = x⃗₂ gives b = -a|u⃗|.
    # Using q(t₃) = x⃗₃, the following steps may be used to derive a
    #   1) v⃗ = x⃗₃ - x⃗₁
    #   2) b = -a|u⃗|
    #   3) × u⃗ both sides, and u⃗ × u⃗ = 0⃗
    #   4) |t₃u⃗| = u⃗ ⋅v⃗/|u⃗|
    #   5) |u⃗|² = u⃗ ⋅u⃗
    #   6) v⃗ × u⃗ = -(u⃗ × v⃗)
    #   the result:
    #
    #             (u⃗ ⋅ u⃗) (v⃗ × u⃗) ⋅ (v⃗ × u⃗)
    # a = -------------------------------------------
    #     (u⃗ ⋅ v⃗)[(u⃗ ⋅ v⃗) - (u⃗ ⋅ u⃗)](ŷ × u⃗) ⋅ (v⃗ × u⃗)
    #
    # We can construct ŷ with
    #
    #      -(v⃗ × u⃗) × u⃗
    # ŷ =  -------------
    #      |(v⃗ × u⃗) × u⃗|
    #
    u⃗ = x⃗₂-x⃗₁
    v⃗ = x⃗₃-x⃗₁
    if v⃗ × u⃗ ≈ zero(v⃗)
        # x⃗₃ is on u⃗
        a = T(0)
        b = T(0)
        ŷ = zero(v⃗)
    else
        ŷ = -(v⃗ × u⃗) × u⃗/norm((v⃗ × u⃗) × u⃗)
        a = ( (u⃗ ⋅ u⃗) * (v⃗ × u⃗) ⋅(v⃗ × u⃗) )/( (u⃗ ⋅v⃗)*((u⃗ ⋅ v⃗) - (u⃗ ⋅ u⃗) ) * ( (ŷ × u⃗) ⋅ (v⃗ × u⃗)) )
        b = -a*norm(u⃗)
    end
    return QuadraticSegment((x⃗₁, x⃗₂, x⃗₃), a, b, ŷ)
end

# Base methods
# -------------------------------------------------------------------------------------------------


# Methods
# -------------------------------------------------------------------------------------------------
# Points on the curve
function (q::QuadraticSegment)(t::T) where {T <: AbstractFloat}
    u⃗ = q.x⃗[2] - q.x⃗[1]
    return (q.a*norm(t*u⃗)^2 + q.b*norm(t*u⃗))*q.ŷ + t*u⃗ + q.x⃗[1]
end
# Points within the curve, bounded by u⃗(t) on the bottom.
function (q::QuadraticSegment)(s::T, t::T) where {T <: AbstractFloat}
    u⃗ = q.x⃗[2] - q.x⃗[1]
    return (q.a*norm(s*u⃗)^2 + q.b*norm(s*u⃗))*q.ŷ + t*u⃗ + q.x⃗[1]
end

function intersect(l::LineSegment, q::QuadraticSegment)
    # q(t) = (a|tu⃗|² + b|tu⃗|)ŷ + tu⃗ + x⃗₁
    # l(s) = x⃗₄ + sw⃗
    # If a|u⃗|²ŷ × w⃗ ≢ 0⃗
    #   x⃗₄ + sw⃗ = (a|tu⃗|² + b|tu⃗|)ŷ + tu⃗ + x⃗₁
    #   sw⃗ = (a|tu⃗|² + b|tu⃗|)ŷ + tu⃗ + (x⃗₁ - x⃗₄)
    #   For valid t (t ∈ [0,1])
    #   0⃗ = (a|u⃗|²ŷ × w⃗)t² + ((b|u⃗|ŷ + u⃗) × w⃗)t + (x⃗₁ - x⃗₄) × w⃗
    #   A⃗ = (a|u⃗|²ŷ × w⃗), B⃗ = ((b|u⃗|ŷ + u⃗) × w⃗), C⃗ = (x⃗₁ - x⃗₄) × w⃗
    #   0⃗ = t²A⃗ + tB⃗ + C⃗
    #   0 = (A⃗ ⋅ A⃗)t² + (B⃗ ⋅ A⃗)t + (C⃗ ⋅ A⃗)
    #   A = (A⃗ ⋅ A⃗), B = (B⃗ ⋅ A⃗), C = (C⃗ ⋅ A⃗)
    #   0 = At² + Bt + B
    #   t = (-B - √(B²-4AC))/2A, -B + √(B²-4AC))/2A)
    #   s = ((q(t) - x⃗₄)⋅w⃗/(w⃗ ⋅ w⃗)
    #   t is invalid if:
    #     1) A = 0            
    #     2) B² < 4AC       
    #     3) t < 0 or 1 < t   (Line intersects, segment doesn't)
    #   s is invalid if:
    #     1) s < 0 or 1 < s   (Line intersects, segment doesn't)
    # If A = 0, we need to use line intersection instead.
    bool = false
    npoints = 0
    type = typeof(l.p₁.coord[1])
    points = [Point(type.((1e9, 1e9, 1e9))), Point(type.((1e9, 1e9, 1e9)))]
    w⃗ = l.p₂ - l.p₁
    u⃗ = q.x⃗[2] - q.x⃗[1]
    A⃗ = q.a*norm(u⃗)^2*q.ŷ × w⃗
    B⃗ = (q.b*norm(u⃗)*q.ŷ + u⃗) × w⃗
    C⃗ = (q.x⃗[1] - l.p₁) × w⃗
    A = A⃗ ⋅ A⃗
    B = B⃗ ⋅ A⃗
    C = C⃗ ⋅ A⃗
    if isapprox(A, type(0), atol = √eps(type))
        # Line intersection
        t = (-C⃗ ⋅ B⃗)/(B⃗ ⋅ B⃗)
        s = (q(t)- l.p₁) ⋅ w⃗/(w⃗ ⋅ w⃗)
        points[1] = q(t)
        if (0.0 ≤ s ≤ 1.0) && (0.0 ≤ t ≤ 1.0)
            bool = true
            npoints = 1
        end
    elseif B^2 ≥ 4*A*C
        # Quadratic intersection
        t⃗ = [(-B - √(B^2-4*A*C))/(2A), (-B + √(B^2-4A*C))/(2A)]
        s⃗ = [(q(t⃗[1]) - l.p₁) ⋅ w⃗/(w⃗ ⋅ w⃗), (q(t⃗[2]) - l.p₁) ⋅ w⃗/(w⃗ ⋅ w⃗)]
        # Check points to see if they are unique, valid intersections.
        for i = 1:2
            pₜ = q(t⃗[i])
            pₛ = l(s⃗[i])
            if (0.0 ≤ s⃗[i] ≤ 1.0) && (0.0 ≤ t⃗[i] ≤ 1.0) && !(pₜ≈ points[1]) && (pₜ ≈ pₛ)
                bool = true
                points[npoints + 1] = pₜ
                npoints += 1
                if npoints == 2
                    break
                end
            end
        end
    end
    return bool, npoints, points
end
intersect(q::QuadraticSegment, l::LineSegment) = intersect(l, q)

function is_left(p::Point{T}, q::QuadraticSegment; 
                 n̂::Point=Point(T(0), T(0), T(1))) where {T <: AbstractFloat}
    # Let w⃗ = p - q.x⃗₁, u⃗ = q.x⃗₂ - q.x⃗₁
    # If p is in the plane of q, then w⃗ is a linear combination of u⃗ and ŷ. 
    # w⃗ = tu⃗ + sŷ + vn̂, and v=0. Here we include n̂ to make a square system.
    # Therefore, if A = [u⃗ ŷ n̂] and x = [t; s; v], then Ax=w⃗. 
    # A is invertible since {u⃗, ŷ, n̂} are a basis for R³.
    # If p is actually in the plane of q, then v = 0.
    # If t ∉ (0, 1), then we can simply use the line is_left check.
    # If t ∈ (0, 1), then we need to see if the point is within the quad area.
    # If 0 ≤ s ≤ a|u⃗/2|² + b|u⃗/2|, then the point is within the quad area.
    # If the point is within the quad area, we need to reverse the linear result.
    w⃗ = p - q.x⃗[1]
    u⃗ = q.x⃗[2] - q.x⃗[1]
    A = hcat(u⃗.coord, q.ŷ.coord, n̂.coord)
    t, s, v = A\w⃗.coord
#    if !isapprox(t, T(0), atol=sqrt(eps(T)))
#        @warn "$p is not in the same plane as $q, v = $v"
#    end
    l = LineSegment(q.x⃗[1], q.x⃗[2])
    bool = isleft(p, l, n̂ = n̂)
    smax = q.a*norm(u⃗/2)^2 + q.b*norm(u⃗/2)
    # Point is outside quad area, just use is_left
    # Point is inside quad area, return opposite of is_left
    return (t ≤ 0) || (1 ≤ t) || (s ≤ 0) || (smax ≤ s) ? bool : !bool
end
