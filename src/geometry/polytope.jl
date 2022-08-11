export Polytope, Edge, Face, Cell

# POLYTOPE    
# -----------------------------------------------------------------------------    
#    
# A K-dimensional polytope, of polynomial order P, represented by the connectivity    
# of its vertices. These N vertices are D-dimensional vertices of type T.    
#    
# This struct only supports the shapes found in "The Visualization Toolkit:    
# An Object-Oriented Approach to 3D Graphics, 4th Edition, Chapter 8, Advanced    
# Data Representation".    
#    
# See the VTK book for specific vertex ordering info, but generally vertices are    
# ordered in a counterclockwise fashion, with vertices of the linear shape given    
# first.    
#    
# See https://en.wikipedia.org/wiki/Polytope for help with terminology.    

abstract type Polytope{K, D, T} end
abstract type Edge{D, T} <: Polytope{1, D, T} end
abstract type Face{D, T} <: Polytope{2, D, T} end
abstract type Cell{D, T} <: Polytope{3, D, T} end
