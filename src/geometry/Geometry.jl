module Geometry

using LinearAlgebra
using StaticArrays
using ..MOCNeutronTransport: RefLine, RefSquare, RefCube, RefTriangle, gauss_quadrature

import Base: -, +, inv, zero

include("constants.jl")
include("vector.jl")
include("point.jl")
include("plane.jl")
include("axisalignedbox.jl")
include("polytope.jl")
include("polytopes/interpolate.jl")
include("polytopes/jacobian.jl")
include("polytopes/polynomial.jl")
include("polytopes/quadraticsegment.jl")
include("polytopes/edges.jl")
include("polytopes/measure.jl")
include("polytopes/triangulate.jl")
end
