include("Script data processing.jl")
include("construction_heuristics.jl")

using Statistics 
using Printf      
using Dates 

#########################################################################################
######################### DETERMINISTIC GREEDY CONSTRUCTION #############################

function experiment_greedy_det(filepath, iterations, out=true)
    n_unodes, n_vnodes, n_constraints, n_edges = read_sizes(filepath)
    unodes, vnodes = create_unodes_vnodes(n_unodes, n_vnodes)
    constraints = read_constraints(filepath, n_constraints)
    edges = read_edges(filepath)

    best_sol = nothing
    best_cost = Inf
    cost_list = []  
    time_list = []  
    sol_list = []  

    for i in 1:iterations
        start_time = now()
        sol, cost = greedy_heuristic(unodes, vnodes, edges, constraints)
        end_time = now()
        elapsed_time = end_time - start_time
        push!(time_list, Dates.value(elapsed_time))
        if cost < best_cost
            best_sol = sol
            best_cost = cost
        end
        push!(cost_list, cost)
        push!(sol_list, sol) 
        if out
            println("Iteration $i: Cost = $cost, Time = $elapsed_time")
        end
    end

    avg_cost = mean(cost_list)
    avg_time = mean(time_list)
    avg_time_seconds = avg_time/1000

    avg_final_obj = cost_list[end]

    if out
        println("\n---- Experiment summary ----")
        println("--- Greedy deterministic construction ---")
        println("Best solution cost: $best_cost")
        println("Average cost: $avg_cost")
        println("Average running time: $avg_time_seconds seconds")
        println("Final objective (last run): $avg_final_obj")
    end   
    return best_sol, best_cost, avg_cost, avg_final_obj, avg_time
end

#########################################################################################
######################### RANDOMIZED CONSTRUCTION: SHUFFLE ##############################

function experiment_randomized_shuffle(filepath, iterations=10)
    n_unodes, n_vnodes, n_constraints, n_edges = read_sizes(filepath)
    unodes, vnodes = create_unodes_vnodes(n_unodes, n_vnodes)
    constraints = read_constraints(filepath, n_constraints)
    edges = read_edges(filepath)

    best_sol = nothing
    best_cost = Inf
    cost_list = []  
    time_list = [] 
   
    for i in 1:iterations
        start_time = now()
        sol, cost = randomized_construction_heuristic(unodes, vnodes, edges, constraints) 
        end_time = now()
        elapsed_time = end_time - start_time
        push!(time_list, Dates.value(elapsed_time))  
        if cost < best_cost
            best_sol = sol
            best_cost = cost
        end
        push!(cost_list, cost)
        println("Iteration $i: Cost = $cost, Time = $elapsed_time")
    end

    avg_cost = mean(cost_list)
    avg_time = mean(time_list) / 1000  
    cost_stddev = std(cost_list)
    time_stddev = std(time_list) / 1000

    avg_final_obj = cost_list[end]

    println("\n---- Experiment Summary ----")
    println("--- Randomized construction [Shuffle] ---")
    println("Best solution cost: $best_cost")
    println("Average cost: $avg_cost")
    println("Cost std dev: $cost_stddev")
    println("Average running time: $avg_time seconds")
    println("Time std dev: $time_stddev")
    println("Final objective (last run): $avg_final_obj")
    
    return best_sol, best_cost, avg_cost, avg_final_obj, avg_time
end

#########################################################################################
############### RANDOMIZED CONSTRUCTION: PICK AMONG K MOST PROMISING ####################

function experiment_K_randomized(filepath, k, iterations=10)
    n_unodes, n_vnodes, n_constraints, n_edges = read_sizes(filepath)
    unodes, vnodes = create_unodes_vnodes(n_unodes, n_vnodes)
    constraints = read_constraints(filepath, n_constraints)
    edges = read_edges(filepath)

    best_sol = nothing
    best_cost = Inf
    cost_list = []  
    time_list = [] 

    for i in 1:iterations
        start_time = now()
        sol, cost = randomized_greedy_heuristic(unodes, vnodes, edges, constraints, k)
        end_time = now()
        elapsed_time = end_time - start_time

        push!(time_list, Dates.value(elapsed_time))  
        if cost < best_cost
            best_sol = sol
            best_cost = cost
        end
        push!(cost_list, cost)
        println("Iteration $i: Cost = $cost, Time = $elapsed_time")
    end

    avg_cost = mean(cost_list)
    avg_time = mean(time_list) / 1000  # Convert ms to seconds
    avg_final_obj = cost_list[end]

    cost_stddev = std(cost_list)
    time_stddev = std(time_list) / 1000

    println("\n--- Experiment Summary ---")
    println("--- Randomized construction [K-randomized] ---")
    println("Best Solution Cost: $best_cost")
    println("Average Cost: $avg_cost")
    println("Cost std dev: $cost_stddev")
    println("Average Running Time: $avg_time seconds")
    println("Time std dev: $time_stddev")
    println("Final Objective (last run): $avg_final_obj")

    return best_sol, best_cost, avg_cost, avg_final_obj, avg_time
end


#########################################################################################
################################## EXPERIMENTS ##########################################

# filepath = "C:/Users/jbcel/OneDrive/Documents/TU Wien/Heuristic Optimization Techniques/tuning_instances/tuning_instances/small/inst_50_4_00001"

# experiment_greedy_det(filepath, 5)
# experiment_randomized_shuffle(filepath)
# experiment_K_randomized(filepath, 10)