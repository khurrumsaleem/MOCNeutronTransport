export Vec, Vec1, Vec2, Vec3, Vec1f, Vec2f, Vec3f
export ⊙, ⊘, norm² 

"""
    Vec{Dim,T}

A vector in `Dim`-dimensional space with coordinates of type `T`.

A vector can be obtained by subtracting two [`Point`](@ref) objects.

## Examples

```julia

A = Point(0.0, 0.0)
B = Point(1.0, 0.0)
v = B - A
```
### Notes

- A `Vec` is an `SVector` from StaticArrays.jl
- Type aliases are `Vec1`, `Vec2`, `Vec3`, `Vec1f`, `Vec2f`, `Vec3f`
"""
const Vec = SVector

# type aliases for convenience
const Vec1  = Vec{1,Float64}
const Vec2  = Vec{2,Float64}
const Vec3  = Vec{3,Float64}
const Vec1f = Vec{1,Float32}
const Vec2f = Vec{2,Float32}
const Vec3f = Vec{3,Float32}

"""
    ⊙(A::AbstractArray, B::AbstractArray)

Hadamard product (element-wise multiplication) of two equal size arrays.
"""
⊙(A::AbstractArray, B::AbstractArray) = map(*, A, B)

"""
    ⊘(a::AbstractArray, b::AbstractArray)

Hadamard division (element-wise division) of two equal size arrays.
"""
⊘(A::AbstractArray, B::AbstractArray) = map(/, A, B)

"""
    inv(v::AbstractVector)

Return the Samelson inverse of a.

The returned vector, a⁻¹, satisfies a⁻¹ ⋅ a = 1.
"""
inv(a::AbstractVector) = inv(a ⋅ a) * a'

"""
    norm²(v::AbstractVector)

Return the squared 2-norm of the vector.
"""
norm²(v::AbstractVector) = v ⋅ v
