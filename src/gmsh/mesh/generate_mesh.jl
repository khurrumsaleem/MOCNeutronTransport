export generate_mesh

function generate_mesh(; dim::Int64 = 2,
                       order::Int64 = 1,
                       face_type::String = "Triangle",
                       opt_iters::Int64 = 0,
                       force_quads::Bool = false)
    @info "Generating a mesh of dimension $dim with $face_type faces of order $order"
    gmsh.option.set_number("Mesh.SecondOrderIncomplete", 1)
    if dim != 2
        error("Only 2D meshes are currently supported.")
    end
    if face_type == "Triangle"
        # Delaunay (5) handles large element size gradients better
        gmsh.option.set_number("Mesh.Algorithm", 5)
        if order == 1
            gmsh.model.mesh.generate(2)
            for _ in 1:opt_iters
                gmsh.model.mesh.optimize("Laplace2D")
            end
        elseif order == 2
            gmsh.option.set_number("Mesh.HighOrderOptimize", 2) # elastic + optimization
            gmsh.model.mesh.generate(2)
            gmsh.model.mesh.set_order(2)
            for _ in 1:opt_iters
                gmsh.model.mesh.optimize("HighOrderElastic")
                gmsh.model.mesh.optimize("Relocate2D")
                gmsh.model.mesh.optimize("HighOrderElastic")
            end
        else
            error("Mesh order must be 1 or 2.")
        end
    elseif face_type == "Quadrilateral"
        gmsh.option.set_number("Mesh.RecombineAll", 1)
        gmsh.option.set_number("Mesh.Algorithm", 8) # Frontal-Delaunay for quads.
        if force_quads
            gmsh.option.set_number("Mesh.RecombinationAlgorithm", 2) # simple full-quad
            gmsh.option.set_number("Mesh.SubdivisionAlgorithm", 1) # All quads
        end
        if order == 1
            gmsh.model.mesh.generate(2)
            for _ in 1:opt_iters
                gmsh.model.mesh.optimize("Laplace2D")
                gmsh.model.mesh.optimize("Relocate2D")
                gmsh.model.mesh.optimize("Laplace2D")
            end
        elseif order == 2
            gmsh.option.set_number("Mesh.HighOrderOptimize", 2)
            gmsh.model.mesh.generate(2)
            gmsh.model.mesh.set_order(2)
            for _ in 1:opt_iters
                gmsh.model.mesh.optimize("HighOrderElastic")
                gmsh.model.mesh.optimize("Relocate2D")
                gmsh.model.mesh.optimize("HighOrderElastic")
            end
        else
            error("Mesh order must be 1 or 2.")
        end
    else
        error("Could not identify face type.")
    end

    return nothing
end
