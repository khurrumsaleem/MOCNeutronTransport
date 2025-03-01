export Tree

export data, 
       parent, 
       children, 
       isroot, 
       is_parents_last_child, 
       leaves, 
       num_leaves, 
       isleaf,
       num_children,
       nodes_at_level,
       root

# A simple tree data structure for homogeneous data.
# If heterogeneous data is desired, use a Union or Any
mutable struct Tree{T}
    data::T
    parent::Union{Nothing, Tree{T}}
    children::Union{Nothing, Vector{Tree{T}}}
end

# -- Constructors --

Tree(data::T) where {T} = Tree{T}(data, nothing, nothing)

function Tree(data::T, parent::Tree{T}) where {T}
    this = Tree{T}(data, parent, nothing)
    if isnothing(children(parent))
        parent.children = [this]
    else
        push!(children(parent), this)
    end
    return this
end

# -- Accessors --

data(node::Tree) = node.data
Base.parent(node::Tree) = node.parent
children(node::Tree) = node.children

# -- Methods --

isroot(node::Tree) = parent(node) === nothing
isleaf(node::Tree) = children(node) === nothing
is_parents_last_child(node::Tree) = children(parent(node))[end] === node

function root(node::Tree)
    if isroot(node)
        return node
    else
        return root(parent(node))
    end
end

function Base.push!(node::Tree, child::Tree)
    if isnothing(children(node))
        node.children = [child]
    else
        push!(children(node), child)
    end
    child.parent = node
    return nothing
end

function num_children(node::Tree) 
    node_children = children(node) 
    if !isnothing(node_children)
        return length(node_children)
    else
        return 0
    end
end

function get_leaves!(node::Tree{T}, leaf_nodes::Vector{Tree{T}}) where {T}
    node_children = children(node)
    if !isnothing(node_children)
        for child in node_children
            get_leaves!(child, leaf_nodes)
        end
    else
        push!(leaf_nodes, node)
    end
    return nothing
end

function leaves(node::Tree{T}) where {T}
    leaf_nodes = Tree{T}[]
    node_children = children(node)
    if !isnothing(node_children)
        for child in node_children
            get_leaves!(child, leaf_nodes)
        end
    else
        push!(leaf_nodes, node)
    end
    return leaf_nodes
end

function num_leaves(node::Tree)
    node_children = children(node)
    if !isnothing(node_children)
        return mapreduce(num_leaves, +, node_children)
    else
        return 1
    end
end

function nodes_at_level!(node::Tree{T}, level::Int64, 
                         nodes::Vector{Tree{T}}) where {T}
    if level == 0
        push!(nodes, node)
    else
        node_children = children(node)
        if !isnothing(node_children)
            for child in node_children
                nodes_at_level!(child, level-1, nodes)
            end
        end
    end
    return nothing
end

function nodes_at_level(node::Tree{T}, level::Int64) where {T}
    nodes = Tree{T}[]
    nodes_at_level!(node, level, nodes)
    return nodes
end

# -- IO --

function Base.show(io::IO, node::Tree)
    println(io, "Tree{", typeof(node.data), "}")
    println(io, data(node))
    node_children = children(node)
    if !isnothing(node_children)
        nchildren = length(node_children)
        if 7 < nchildren
            show(io, node_children[1], "")
            show(io, node_children[2], "")
            println(io, "│  ⋮")
            println(io, "│  ⋮ (", nchildren - 4, " additional children)")
            println(io, "│  ⋮")
            show(io, node_children[end - 1], "")
            show(io, node_children[end], "")
        else
            for child in node_children
                show(io, child, "")
            end
        end
    end
end

function Base.show(io::IO, node::Tree, predecessor_string::String)
    next_predecessor_string = ""
    if !isroot(node)
        if is_parents_last_child(node)
            print(io, predecessor_string * "└─ ")
            next_predecessor_string = predecessor_string * "   "
        else
            print(io, predecessor_string * "├─ ")
            next_predecessor_string = predecessor_string * "│  "
        end
    end
    println(io, data(node))
    node_children = children(node)
    if !isnothing(node_children)
        nchildren = length(node_children)
        if 7 < nchildren
            show(io, node_children[1], next_predecessor_string)
            show(io, node_children[2], next_predecessor_string)
            println(io, next_predecessor_string * "│  ⋮")
            println(io, next_predecessor_string * "│  ⋮ (", nchildren - 4,
                    " additional children)")
            println(io, next_predecessor_string * "│  ⋮")
            show(io, node_children[end - 1], next_predecessor_string)
            show(io, node_children[end], next_predecessor_string)
        else
            for child in node_children
                show(io, child, next_predecessor_string)
            end
        end
    end
end
