module MOCNeutronTransport
using HDF5
using LightXML
using LinearAlgebra
using StaticArrays
try
    # Use local gmsh install
    using gmsh
catch e
    # Fall back on Gmsh package
    @warn "Using Gmsh package instead of install from source"
    using Gmsh: gmsh
end

import Base: +, -, *, /, ≈, ==, intersect, in
include("Tree.jl")
include("Point_2D.jl")
#include("Point_3D.jl")
include("LineSegment_2D.jl")
#include("LineSegment_3D.jl")
include("QuadraticSegment_2D.jl")
#include("QuadraticSegment_3D.jl")
include("Triangle_2D.jl")
#include("Triangle_3D.jl")
include("Quadrilateral_2D.jl")
#include("Quadrilateral_3D.jl")
include("Triangle6_2D.jl")
#include("Triangle6_3D.jl")
include("Quadrilateral8_2D.jl")
#include("Quadrilateral8_3D.jl")
include("gauss_legendre_quadrature.jl")
include("UnstructuredMesh_2D.jl")
include("HierarchicalRectangularlyPartitionedMesh.jl")
include("abaqus.jl")
include("vtk.jl")
include("xdmf.jl")

include("gmsh_rectangular_grid.jl")
include("gmsh_group_preserving_fragment.jl")
include("gmsh_overlay_rectangular_grid.jl")
#
#include("AngularQuadrature.jl")
#export AngularQuadrature,
#       GeneralAngularQuadrature,
#       ProductAngularQuadrature
#

# Structs
export  Tree,
        Point_2D,
#        Point_3D,
        LineSegment_2D,
#        LineSegment_3D,
        QuadraticSegment_2D,
#        QuadraticSegment_3D,
        Triangle_2D,
#        Triangle_3D,
        Quadrilateral_2D,
#        Quadrilateral_3D,
        Triangle6_2D,
#        Triangle6_3D,
        Quadrilateral8_2D,
#        Quadrilateral8_3D,
        UnstructuredMesh_2D,
        HierarchicalRectangularlyPartitionedMesh
# Functions
export  ×,
        ⋅,
        AABB,
        add_edges,
        add_edges_materialized,
        add_faces_materialized,
        add_edge_face_connectivity,
        add_face_edge_connectivity,
        arc_length,
        area,
        derivative,
        distance,
        edges,
        edges_materialized,
        edge_face_connectivity,
        edge_materialized,        
        faces_materialized,
        face_edge_connectivity,
        face_materialized,
        gauss_legendre_quadrature,
        get_level,
        intersect,
        intersect_edges,
        intersect_faces,
        intersect_iterative,
        jacobian,
        materialize,
        norm,
        partition_rectangularly,
        read_abaqus_2d,
        read_vtk_2d,
        real_to_parametric,
        submesh,
        triangulate,
        write_vtk_2d,
        write_xdmf_2d

# Gmsh
export gmsh,
       gmsh_rectangular_grid,
       gmsh_group_preserving_fragment,
       gmsh_overlay_rectangular_grid


end # module
