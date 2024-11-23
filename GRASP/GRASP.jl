include("../MWCCP.jl")
include("../Neighborhoods/Neighborhoods.jl")
using .MWCCPTools, .Neighborhoods

#= Give file path as an argument when calling julia !  You can create a launch.json in Vscode. =#

if length(ARGS) > 0
    graph_path = ARGS[1]
else
    error("A graph file must be given.")
end

(unodes, vnodes, u_dict, v_dict, constraints, edges, f_value) =  extract_mwccp(graph_path)

g = MWCCP(unodes, vnodes, u_dict, v_dict, constraints, edges, f_value)

function follows_constraints_one_node_heuristic(node, v_dict, constraints)
    for (n1,n2) in constraints
        if n2 == node
            if isnan(v_dict[n1])
                return false
                #Prevents deadlock when building a solution (otherwise it would be impossible to add n1 later).
            end
        end
    end
    return true
end

function get_candidate_list(v_nodes_partial, f_value_partial, nodes_left, u_dict, v_dict, constraints, edges, v_nodes_length)
    candidate_list::Vector{Tuple{Vector{Int64},Int64,Int64}} = []
    for i in eachindex(nodes_left)
        node = nodes_left[i]
        v_dict_candidate = deepcopy(v_dict)
        v_dict_candidate[node] = v_nodes_length + 1
        if follows_constraints_one_node_heuristic(node, v_dict_candidate, constraints)
            partial_candidate = deepcopy(v_nodes_partial)
            push!(partial_candidate, node)
            f_value_node = evaluate_one_node_interaction(edges, node, u_dict, v_dict_candidate)
         #=    Edges overlapping are not counted twice because when a sigle v_node of the edges is added
            the other v_node position is NaN which gives 'false' with every comparison (function 'crossed_values' in Neighborhoods).
            Because of that the overlapping edges are not added when the first v_node is added .
            Overlapping edges are only added when the second v_node is added. =#
            push!(candidate_list, (partial_candidate,f_value_partial + f_value_node, i))
        end
    end
    return candidate_list
end

function get_restricted_candidate_list(candidate_list, alpha)
    #sorted_candidate_list = sort(candidate_list, by = candidate -> candidate[2])
    cmin, cmax = minimum(x -> x[2], candidate_list), maximum(x-> x[2], candidate_list)
    threshold =  cmin + alpha*(cmax - cmin)
    restricted_candidate_list = [candidate for candidate in candidate_list if candidate[2] <= threshold]
    return restricted_candidate_list
end

function get_random_candidate_from_list(candidate_list)
    k = rand(1:length(candidate_list))
    return candidate_list[k]
end

function reset_dict(v_dict)
    return Dict(k => NaN for (k, v) in v_dict)
end

function randomized_greedy_heuristic(g::MWCCP)
    nodes_left = g.v_nodes
    u_dict = g.u_dict
    v_dict = reset_dict(g.v_dict)
    constraints = g.constraints
    edges = g.edges
    v_nodes_partial = []
    f_value_partial = 0
    i = 1
    while !isempty(nodes_left)
        candidate_list = get_candidate_list(v_nodes_partial, f_value_partial, nodes_left, u_dict, v_dict, constraints, edges, length(v_nodes_partial))
        restricted_candidate_list = get_restricted_candidate_list(candidate_list, 0.1)
        chosen_one = get_random_candidate_from_list(restricted_candidate_list)
        v_nodes_partial = chosen_one[1]
        f_value_partial = chosen_one[2]
        index_node = chosen_one[3]
        node = nodes_left[index_node]
        v_dict[node] = i
        deleteat!(nodes_left, index_node)
        i += 1
        print(chosen_one)
    end
    return MWCCP(g.u_nodes, v_nodes_partial, g.u_dict, v_dict, constraints, edges, f_value_partial)
end

print(g)

res = randomized_greedy_heuristic(g)

print(res)