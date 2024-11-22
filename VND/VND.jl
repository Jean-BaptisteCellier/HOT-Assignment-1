include("../MWCCP.jl")
using .MWCCPTools

g = extract_mwccp(pwd() * "/data/tuning_instances/small/inst_50_4_00001")

function get_edges_connected_to_vnode(edges, node)
    node_edges::Vector{Tuple{Tuple{Int64,Int64},Int64}} = []
    for ((e1,e2),w) in edges
        if e2 == node
            push!(node_edges, ((e1,e2),w))
        end
    end
    return node_edges
end

function evaluate_interaction(node_edges_1, node_edges_2, u_dict, v_dict)
    f_restricted_to_e1_e2::Int64 = 0
    for ((e11,e12),w1) in node_edges_1
        for ((e21,e22),w2) in node_edges_2
            if crossed_values(u_dict[e11],u_dict[e21],v_dict[e12],v_dict[e22])
                f_restricted_to_e1_e2 += (w1 + w2)
            end
        end
    end
    return f_restricted_to_e1_e2
end

function evaluate_mutual_interaction(edges, node1, node2, u_dict, v_dict)
    edges_v1 = get_edges_connected_to_vnode(edges, node1)
    edges_v2 = get_edges_connected_to_vnode(edges, node2)
    f_restricted_v1_v2 = evaluate_interaction(edges_v1, edges_v2, u_dict, v_dict)
    return f_restricted_v1_v2
end

function flip(arr, key1, key2)
    temp = arr[key1]
    arr[key1] = arr[key2]
    arr[key2] = temp
end

function follows_constraints_two_nodes_consecutive(arr, id1, id2, constraints)
    N = length(constraints)
    for i in 1:N
        if arr[id1] == constraints[i][2] && arr[id2] == constraints[i][1]
            return false
        end
    end
    return true
end

function get_flip_consecutive_nodes_neighborhood(g::MWCCP)
    v_nodes = g.v_nodes
    edges = g.edges
    constraints = g.constraints
    u_dict = g.u_dict
    v_dict = g.v_dict
    f_value = g.f_value
    N = length(v_nodes)
    neighborhood::Vector{Tuple{Vector{Int64},Int64}} = []
    for i in 1:N-1
        neighbor = deepcopy(v_nodes)
        flip(neighbor, i, i+1)
        if follows_constraints_two_nodes_consecutive(neighbor, i, i+1, constraints)
            neighbor_v_dict = reverse_list(neighbor)
            f_partial_before = evaluate_mutual_interaction(edges, v_nodes[i], v_nodes[i+1], u_dict, v_dict)
            f_partial_after = evaluate_mutual_interaction(edges, neighbor[i], neighbor[i+1], u_dict, neighbor_v_dict)
            push!(neighborhood, (neighbor,f_value - f_partial_before + f_partial_after))
        end
    end
    return neighborhood
end

function get_first_improvement(v_nodes, f_value, neighborhood::Vector{Tuple{Vector{Int64},Int64}})
    for (neighbor_v_nodes, neighbor_value) in neighborhood
        if neighbor_value < f_value
            return (neighbor_v_nodes, neighbor_value)
        end
    end
    return (v_nodes, f_value)
end

function get_best_improvement(v_nodes, f_value, neighborhood::Vector{Tuple{Vector{Int64},Int64}})
    for (neighbor_v_nodes, neighbor_value) in neighborhood
        if neighbor_value < f_value
            v_nodes, f_value = neighbor_v_nodes, neighbor_value
        end
    end
    return (v_nodes, f_value)
end

function evaluate_one_node_interaction(edges, node, u_dict, v_dict)
    edges_node = get_edges_connected_to_vnode(edges, node)
    f_restricted_value = evaluate_interaction(edges_node, edges, u_dict, v_dict)
    return f_restricted_value
end

function follows_constraints_one_node(node, v_dict, constraints)
    for (n1,n2) in constraints
        if n1 == node
            if v_dict[n2] < v_dict[node]
                return false
            end
        else
            if n2 == node
                if v_dict[n1] > v_dict[node]
                    return false
                end
            end
        end
    end
    return true
end

function get_move_one_node_neighborhood(g::MWCCP)
    neighborhood::Vector{Tuple{Vector{Int64},Int64}} = []
    v_nodes = g.v_nodes
    edges = g.edges
    u_dict = g.u_dict
    v_dict = g.v_dict
    constraints = g.constraints
    f_value = g.f_value
    N = length(v_nodes)
    for i in 1:N
        neighbor_without_node_i = deepcopy(v_nodes)
        node = neighbor_without_node_i[i]
        f_partial_before = evaluate_one_node_interaction(edges, node, u_dict, v_dict)
        deleteat!(neighbor_without_node_i, i)
        for j in 1:N
            neighbor = deepcopy(neighbor_without_node_i)
            if i != j
                insert!(neighbor, j, node)
                new_v_dict = reverse_list(neighbor)
                if follows_constraints_one_node(node, new_v_dict, constraints)
                    f_partial_after = evaluate_one_node_interaction(edges, node, u_dict, new_v_dict)
                    push!(neighborhood, (neighbor, f_value - f_partial_before + f_partial_after))
                end
            end
        end
    end
    return neighborhood
end

function follows_constraints_two_nodes_general(node1, node2, v_dict, constraints)
    return  (follows_constraints_one_node(node1, v_dict, constraints) &&
    follows_constraints_one_node(node2, v_dict, constraints))
end

function evaluate_two_nodes_global_interaction(edges, node1, node2, u_dict, v_dict)
    return (evaluate_one_node_interaction(edges, node1, u_dict, v_dict) +
    evaluate_one_node_interaction(edges, node2, u_dict, v_dict) -
    evaluate_mutual_interaction(edges, node1, node2, u_dict, v_dict))
    # We need to remove the mutual interaction otherwise node1 and node2 would be counted twice!
end

function get_2_opt_neighborhood(g::MWCCP)
    neighborhood::Vector{Tuple{Vector{Int64},Int64}} = []
    edges = g.edges
    v_nodes = g.v_nodes
    constraints = g.constraints
    u_dict = g.u_dict
    v_dict = g.v_dict
    f_value = g.f_value
    N = length(v_nodes)
    for i in 1:N-1
        for j in i+1:N
            f_partial_before = evaluate_two_nodes_global_interaction(edges, v_nodes[i], v_nodes[j], u_dict, v_dict)
            neighbor = deepcopy(v_nodes)
            flip(neighbor, i, j)
            new_v_dict = reverse_list(neighbor)
            if follows_constraints_two_nodes_general(v_nodes[i], v_nodes[j], new_v_dict, constraints)
                f_partial_after = evaluate_two_nodes_global_interaction(edges, neighbor[i], neighbor[j], u_dict, new_v_dict)
                push!(neighborhood, (neighbor, f_value - f_partial_before + f_partial_after))
            end
        end
    end
    return neighborhood
end

function get_consecutive_flips_with_one_node_move_neighborhood(g::MWCCP)
    return vcat(get_flip_consecutive_nodes_neighborhood(g),
    get_move_one_node_neighborhood(g))
end

function get_2_opt_with_one_node_move_neighborhood(g::MWCCP)
    return vcat(get_2_opt_neighborhood(g),
    get_move_one_node_neighborhood(g))
end

function VND(g, limit, bestfit = false)
    l, i = 0, 1
    Neighborhoods = [get_flip_consecutive_nodes_neighborhood,
    get_move_one_node_neighborhood,
    get_consecutive_flips_with_one_node_move_neighborhood,
    get_2_opt_neighborhood,
    get_2_opt_with_one_node_move_neighborhood
    ]
    n = length(Neighborhoods)
    value = g.f_value
    nodes = g.v_nodes
    while (l < limit) && (i <= n)
        neighborhood = Neighborhoods[i](g)
        if bestfit
            best_neighbor = get_best_improvement(nodes, value, neighborhood) #/!\ v_nodes, f_value !
        else
            best_neighbor = get_first_improvement(nodes, value, neighborhood)
        end
        (neighbor_nodes, neighbor_value) = best_neighbor
        if value == neighbor_value
            l += 1
        else
            l = 0
        end
        nodes, value = neighbor_nodes, neighbor_value
        neighbor_v_dict = reverse_list(nodes)
        g = MWCCP(g.u_nodes,nodes,g.u_dict, neighbor_v_dict, g.constraints, g.edges, value)
        i += 1
    end
    return g
end

println(g)
solution = VND(g, 2, true)
println(solution)
#= neighborhood = flip_consecutive_nodes(g) =#
#= neighborhood = move_one_node(g) =#
#= neighborhood = get_2_opt_neighborhood(g) =#
#= println(neighborhood)
 =#
#= println(get_first_improvement(g.v_nodes, g.f_value, neighborhood))
println(get_best_improvement(g.v_nodes, g.f_value, neighborhood)) =#
# Print results to check
#= println("Unodes: ", typeof(u_nodes))
println("Vnodes: ", typeof(v_nodes))
println("Constraints: ", typeof(constraints))
println("Edges: ", typeof(edges)) =#