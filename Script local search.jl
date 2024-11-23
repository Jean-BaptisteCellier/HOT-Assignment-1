######### LOCAL SEARCH ##########

function localsearch(initial_solution, neighborhood_function, step_function, objective_function, iterations=100)
    current_solution = initial_solution
    best_solution = current_solution
    best_cost = objective_function(current_solution)

    for i in 1:iterations
        neighbors = neighborhood_function(current_solution)
        next_solution = step_function(current_solution, neighbors, objective_function)
        next_cost = objective_function(next_solution)
        if next_cost < best_cost
            best_solution = next_solution
            best_cost = next_cost
        end
        current_solution = next_solution
    end
    return best_solution, best_cost
end

##### STEP FUNCTIONS #####

function first_improvement(current_solution, neighbors, objective_function)
    current_cost = objective_function(current_solution)
    for neighbor in neighbors
        if objective_function(neighbor) < current_cost
            println("Improvement found:")
            return neighbor
        end
    end
    println("No improvement found.")
    return current_solution
end

function best_improvement(current_solution, neighbors, objective_function)
    best_neighbor = neighbors[1]
    best_cost = objective_function(best_neighbor)
    for neighbor in neighbors[2:end]
        cost = objective_function(neighbor)
        if cost < best_cost
            best_neighbor = neighbor
            best_cost = cost
        end
    end
    return best_neighbor
end

function random_step(neighbors)
    return rand(neighbors)
end