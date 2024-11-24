using Random
include("Script data processing.jl")

function constraints_satisfied(constructed_v, vnode, constraints)
    # Check if adding vnode satisfies all constraints given the constructed_v order
    for (before, after) in constraints
        if vnode == after && !(before in constructed_v)
            return false 
        end
    end
    return true
end

function delta_evaluation(vnode, v_order, edges, v_index)
    delta_cost = 0
    temp_index = deepcopy(v_index)  # Simulate adding vnode by creating a temp index
    temp_index[vnode] = length(v_order) + 1  # Simulate adding vnode to the order

    # Calculate the crossing cost only for edges that involve the newly added node
    for ((u1, v1), cost1) in edges
        if v1 == vnode
            for ((u2, v2), cost2) in edges
                if v2 == vnode  # Skip 
                    continue
                end
                if haskey(temp_index, v1) && haskey(temp_index, v2)
                    if (u1 < u2 && temp_index[v1] > temp_index[v2]) || (u1 > u2 && temp_index[v1] < temp_index[v2])
                        delta_cost += cost1+cost2 
                    end
                end
            end
        end
    end
    return delta_cost
end

function greedy_heuristic(unodes, vnodes, edges, constraints)
    remaining_vnodes = copy(vnodes)
    v_order = []
    v_index = Dict()  # Positions of nodes in the solution
    total_cost = 0

    while !isempty(remaining_vnodes)
        min_cost = Inf
        best_vnode = nothing

        for vnode in remaining_vnodes
            if constraints_satisfied(v_order, vnode, constraints)
                delta_cost = delta_evaluation(vnode, v_order, edges, v_index)
                candidate_cost = total_cost + delta_cost
                if candidate_cost < min_cost
                    min_cost = candidate_cost
                    best_vnode = vnode
                end
            end
        end

        if best_vnode === nothing
            error("No valid node found! Check constraints.")
        end

        # Add the best vnode to the solution
        push!(v_order, best_vnode)
        v_index[best_vnode] = length(v_order)  # Update the position of the node
        total_cost += delta_cost  # Accumulate the delta cost (not halved)
        filter!(x -> x != best_vnode, remaining_vnodes)  # Remove the chosen node from remaining list
    end

    return v_order, total_cost  # Return the solution and the total cost
end


################ Greedy deterministic construction heuristic ################

function greedy_heuristic(unodes, vnodes, edges, constraints)
    remaining_vnodes = copy(vnodes)
    v_order = []
    v_index = Dict()  # Track positions of nodes in the solution
    total_cost = 0

    while !isempty(remaining_vnodes)
        min_cost = Inf
        best_vnode = nothing

        for vnode in remaining_vnodes
            if constraints_satisfied(v_order, vnode, constraints)
                delta_cost = delta_evaluation(vnode, v_order, edges, v_index)
                candidate_cost = total_cost + delta_cost
                if candidate_cost < min_cost
                    min_cost = candidate_cost
                    best_vnode = vnode
                end
            end
        end
        push!(v_order, best_vnode)  # Add the best node to the solution
        v_index[best_vnode] = length(v_order)  # Update the position of the node
        total_cost += delta_evaluation(best_vnode, v_order, edges, v_index) # Accumulate the delta cost
        filter!(x -> x != best_vnode, remaining_vnodes)  # Remove the chosen node from remaining list
    end

    return v_order, total_cost
end


################ Randomized construction heuristics ################

# 1st option for randomization: shuffling the vnodes input order at each iteration
function randomized_construction_heuristic(unodes, vnodes, edges, constraints)
    shuffled_vnodes = shuffle(vnodes)
    return greedy_heuristic(unodes, shuffled_vnodes, edges, constraints)
end

# 2nd option for randomization: selecting the k "nearest" nodes at each step then pick randomly the next node among them, and repeating
function randomized_greedy_heuristic(unodes, vnodes, edges, constraints, k)
    remaining_vnodes = copy(vnodes)
    v_order = []
    v_index = Dict() 
    total_cost = 0
    while !isempty(remaining_vnodes)
        candidate_list = []
        
        for vnode in remaining_vnodes
            if constraints_satisfied(v_order, vnode, constraints)
                delta_cost = delta_evaluation(vnode, v_order, edges, v_index)
                candidate_cost = total_cost + delta_cost
                push!(candidate_list, (vnode, candidate_cost))
            end
        end
        # Restricted Candidate List (RCL)
        if !isempty(candidate_list)
            sorted_candidates = sort(candidate_list, by = x -> x[2]) 
            num_candidates = min(k, length(sorted_candidates))
            rcl = sorted_candidates[1:num_candidates]  # RCL contains k best candidates

            # Randomly pick one node from the RCL
            selected_candidate = rand(rcl)
            selected_node, selected_cost = selected_candidate

            push!(v_order, selected_node)
            v_index[selected_node] = length(v_order)
            total_cost = selected_cost
            filter!(x -> x != selected_node, remaining_vnodes)
        else
            break
        end
    end
    return v_order, total_cost
end

# # Repeating the last function max_iter times
# function repeat_randomized_K(unodes, vnodes, edges, constraints, k, max_iter)
#     rcl = []
#     costs = []
#     for _ in 1:max_iter
#         sol_iter, cost = randomized_greedy_heuristic(unodes, vnodes, edges, constraints, k)
#         push!(rcl, sol_iter)
#         push!(costs, cost)
#     end
#     best_cost_idx = argmin(costs)
#     best_cost = costs[best_cost_idx]
#     best_sol = rcl[best_cost_idx]
#     return best_sol, best_cost
# end

function calculate_full_cost(v_order, edges)
    total_cost = 0
    v_index = Dict(v => i for (i, v) in enumerate(v_order))

    for ((u1, v1), cost1) in edges
        for ((u2, v2), cost2) in edges
            if haskey(v_index, v1) && haskey(v_index, v2)
                if (u1 < u2 && v_index[v1] > v_index[v2]) || (u1 > u2 && v_index[v1] < v_index[v2])
                    total_cost += cost1 + cost2
                end
            end
        end
    end

    return total_cost / 2
end