include("Script local search.jl")

function simulated_annealing(initial_solution, neighborhood_function,
    objective_function, initial_temperature=100.0,
    cooling_rate=0.95, min_temperature=1e-3, max_iter=100)

    temperature = initial_temperature
    current_solution = initial_solution
    current_cost = objective_function(current_solution)
    best_solution = current_solution
    best_cost = current_cost

    while temperature > min_temperature
        neighbors = neighborhood_function(current_solution)

        # Pick a random neighbor
        neighbor = random_step(neighbors)
        neighbor_cost = objective_function(neighbor)

        # Calculate cost difference
        delta_cost = neighbor_cost - current_cost

        # Acceptance criteria
        if delta_cost < 0 || rand() < exp(-abs(delta_cost) / temperature)
            current_solution = neighbor
            current_cost = neighbor_cost
        end

        # Update the best solution (if improvement found)
        if current_cost < best_cost
            best_solution = current_solution
            best_cost = current_cost
        end

        temperature *= cooling_rate
    end

    return best_solution, best_cost
end