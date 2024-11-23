using Random

function constraints_satisfied(constructed_v, vnode, constraints)
    # Check if adding vnode satisfies all constraints given the constructed_v order
    for (before, after) in constraints
        if vnode == after && !(before in constructed_v)
            return false 
        end
    end
    return true
end

function calculate_crossing_cost(v_order, edges)
    # Compute total crossing cost for a given order of V nodes
    total_cost = 0
    v_index = Dict(v => i for (i, v) in enumerate(v_order))
    
    # Calculate crossing cost for each pair of edges
    for ((u1, v1), cost1) in edges
        for ((u2, v2), cost2) in edges
            if haskey(v_index, v1) && haskey(v_index, v2)
                if (u1 < u2 && v_index[v1] > v_index[v2]) || (u1 > u2 && v_index[v1] < v_index[v2])
                    total_cost += cost1 + cost2  # Sum cost of both crossing edges
                end
            end
        end
    end
    return total_cost / 2  # Account for double counting of all crossings
end


function greedy_heuristic(unodes, vnodes, edges, constraints)
    remaining_vnodes = copy(vnodes)
    v_order = []

    while !isempty(remaining_vnodes)
        min_cost = Inf
        best_vnode = nothing
        
        for vnode in remaining_vnodes
            # Check constraints
            if constraints_satisfied(v_order, vnode, constraints)
                test_order = vcat(v_order, [vnode])
                crossing_cost = calculate_crossing_cost(test_order, edges)
                
                if crossing_cost < min_cost
                    min_cost = crossing_cost
                    best_vnode = vnode
                end
            end
        end
        push!(v_order, best_vnode)
        filter!(x -> x != best_vnode, remaining_vnodes)
    end
    return v_order, calculate_crossing_cost(v_order, edges)
end

# 1st option: shuffling the vnodes input order at each iteration
function randomized_construction_heuristic(unodes, vnodes, edges, constraints, max_iter)
    best_order = []
    best_cost = Inf
    for _ in 1:max_iter
        # Randomly shuffle the vnodes
        shuffled_vnodes = shuffle(vnodes)
        # Apply the greedy heuristic with the randomized vnodes
        current_order, current_cost = greedy_heuristic(unodes, shuffled_vnodes, edges, constraints)
        # If the new order has a lower cost, update the best order
        if current_cost < best_cost
            best_cost = current_cost
            best_order = current_order
        end
    end
    return best_order, best_cost
end

# 2nd option: selecting the k "nearest" nodes at each step then pick randomly the next node among them, and repeating
function randomized_greedy_heuristic(unodes, vnodes, edges, constraints, k)
    remaining_vnodes = copy(vnodes)
    v_order = []
    while !isempty(remaining_vnodes)
        # Initialize minimum cost and best vnode
        min_cost = Inf
        best_vnode = nothing
        cl = [] # candidate list
        costs = []
        for vnode in remaining_vnodes
            if constraints_satisfied(v_order, vnode, constraints)
                test_order = vcat(v_order, [vnode])  # Build the new order with the candidate vnode
                crossing_cost = calculate_crossing_cost(test_order, edges)
                
                push!(cl, vnode)
                push!(costs, crossing_cost)
            end
        end
        if !isempty(costs)
            sorted_indices = sortperm(costs)
            num_candidates = min(k, length(sorted_indices))
            minimal_values = costs[sorted_indices[1:num_candidates]]   # k minimal costs
            rcl = cl[sorted_indices[1:num_candidates]]       # restricted candidate list
            
            # Randomly pick one node from the k minimal ones
            rand_node = rand(rcl)
            push!(v_order, rand_node)

            # Remove the selected node from remaining vnodes
            filter!(x -> x != rand_node, remaining_vnodes)
        else
            break
        end
    end
    return v_order, calculate_crossing_cost(v_order, edges)
end

function repeat_randomized_K(unodes, vnodes, edges, constraints, k, iterations)
    rcl = []
    costs = []
    for _ in 1:iterations
        sol_iter, cost = randomized_greedy_heuristic(unodes, vnodes, edges, constraints, k)
        push!(rcl, sol_iter)
        push!(costs, cost)
    end
    best_cost_idx = argmin(costs)
    best_cost = costs[best_cost_idx]
    best_sol = rcl[best_cost_idx]
    return best_sol, best_cost
end