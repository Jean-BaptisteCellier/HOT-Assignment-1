include("Experiments_construction.jl")
include("construction_heuristics.jl")

function simulated_annealing(initial_solution, initial_cost, random_neighbor_function,
    edges, constraints; initial_temperature=100.0, cooling_rate=0.95, min_temperature=1e-3)

    temperature = initial_temperature
    current_solution = initial_solution
    current_cost = initial_cost
    best_solution = current_solution
    best_cost = current_cost

    while temperature > min_temperature
        neighbor, delta_cost = random_neighbor_function(current_solution, edges, constraints)

        # Acceptance criteria
        if delta_cost < 0 || rand() < exp(-abs(delta_cost) / temperature)
            current_solution = neighbor
            current_cost += delta_cost
        end
        # Update the best solution, if improvement
        if current_cost < best_cost
            best_solution = current_solution
            best_cost = current_cost
            #println("New improvement $best_solution: Cost = $best_cost")
        end
        # Cool down the temperature
        temperature *= cooling_rate
    end

    return best_solution, best_cost
end

function constraints_satisfied(solution, constraints)
    for (v1, v2) in constraints
        # Ensure v1 appears before v2
        if findfirst(==(v1), solution) > findfirst(==(v2), solution)
            return false  # Violation
        end
    end
    return true  # No violations
end

function random_swap(solution, edges, constraints; max_attempts=100)
    for _ in 1:max_attempts
        # Randomly pick two indices to swap
        i, j = sort(rand(1:length(solution), 2))
        neighbor = copy(solution)
        neighbor[i], neighbor[j] = neighbor[j], neighbor[i]  

        # Respect of constraints
        if neighbor != solution && constraints_satisfied(neighbor, constraints)
            delta_cost = delta_evaluation_sa(solution, neighbor, edges)
            return neighbor, delta_cost
        end
    end
    println("No valid neighbor found")
    return solution, Inf
end


function delta_evaluation_sa(current_solution, neighbor_solution, edges)
    delta_cost = 0
    # Indices of the nodes that were swapped
    swapped_indices = findall(x -> current_solution[x] != neighbor_solution[x], 1:length(current_solution))
    node1, node2 = current_solution[swapped_indices[1]], current_solution[swapped_indices[2]]

    # Create position mappings (indices) for both solutions
    current_index = Dict(v => i for (i, v) in enumerate(current_solution))
    neighbor_index = Dict(v => i for (i, v) in enumerate(neighbor_solution))

    # Step 1: Calculate removed crossing costs when removing incoming edges to node1 and node2
    removed_crossing_cost = 0
    for ((u1, v1), cost1) in edges
        for ((u2, v2), cost2) in edges
            if (v1 == node1 || v1 == node2 || v2 == node1 || v2 == node2)
                # Check if there's a crossing in the current solution
                if haskey(current_index, v1) && haskey(current_index, v2)
                    if (u1 < u2 && current_index[v1] > current_index[v2]) ||
                       (u1 > u2 && current_index[v1] < current_index[v2])
                        removed_crossing_cost += cost1 + cost2
                    end
                end
            end
        end
    end
    removed_crossing_cost /= 2  # avoid double counting

    # Step 2: Calculate added crossing costs when realizing the swap
    added_crossing_cost = 0
    for ((u1, v1), cost1) in edges
        for ((u2, v2), cost2) in edges
            if (v1 == node1 || v1 == node2 || v2 == node1 || v2 == node2)
                # Check if there's a crossing in the neighbor solution
                if haskey(neighbor_index, v1) && haskey(neighbor_index, v2)
                    if (u1 < u2 && neighbor_index[v1] > neighbor_index[v2]) ||
                       (u1 > u2 && neighbor_index[v1] < neighbor_index[v2])
                        added_crossing_cost += cost1 + cost2
                    end
                end
            end
        end
    end
    added_crossing_cost /= 2  # avoid double counting
    # Delta evaluation
    delta_cost = added_crossing_cost - removed_crossing_cost
    return delta_cost
end


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

#############################################################
########### MAIN CODE ####################

# # Path to the input file
# filepath = "C:/Users/jbcel/OneDrive/Documents/TU Wien/Heuristic Optimization Techniques/test_instances/inst_4_0_00001.unknown"

# # Read sizes
# n_unodes, n_vnodes, n_constraints, n_edges = read_sizes(filepath)

# # Create unodes and vnodes
# unodes, vnodes = create_unodes_vnodes(n_unodes, n_vnodes)

# # Read constraints and edges
# constraints = read_constraints(filepath, n_constraints)
# edges = read_edges(filepath)

# initial_solution, initial_cost = greedy_heuristic(unodes, vnodes, edges, constraints)
# println("Initial solution: $initial_solution")
# println("Initial cost: $initial_cost")

# initial_solution = [6,7,8,9,10]
# edges = [((1,7),1), ((2,8),2), ((3,9),1), ((4,10),3), ((5,6), 11)]
# constraints = [(7,10), (8,9)]
# initial_cost = calculate_full_cost(initial_solution, edges)
# println("Initial solution: $initial_solution")
# println("Initial cost: $initial_cost")

# # Call Simulated annealing
# best_solution, best_cost = simulated_annealing(
#     initial_solution,
#     initial_cost,
#     random_two_opt, 
#     calculate_full_cost, 
#     edges, constraints,
#     initial_temperature=100.0,
#     cooling_rate=0.9,
#     min_temperature=1e-3
# )

# println("Best solution: $best_solution")
# println("Best cost: $best_cost")
