export add_materials_to_physical_groups_by_color

"""
    add_materials_to_physical_groups_by_color(materials::Vector{Material})

Assign entities with RGBA color matching the color in a Material X to a physical group
named "Material: X".
"""
function add_materials_to_physical_groups_by_color(materials::Vector{Material})
    color_to_ent = get_entities_by_color()
    for mat in sort(materials, by = m -> m.name)
        ents = color_to_ent[mat.color]
        safe_add_physical_group("Material: " * mat.name, ents)
    end
    return nothing
end
