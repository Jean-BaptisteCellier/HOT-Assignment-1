include("Script data processing.jl")
include("construction_heuristics.jl")

using Statistics 
using Printf      
using Dates 

#########################################################################################
######################### DETERMINISTIC GREEDY CONSTRUCTION #############################

function experiment_greedy_det(unodes, vnodes, edges, constraints, iterations)
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
        println("Iteration $i: Cost = $cost, Time = $elapsed_time")
    end

    avg_cost = mean(cost_list)
    avg_time = mean(time_list)
    avg_time_seconds = avg_time/1000

    avg_final_obj = cost_list[end]

    println("\n---- Experiment summary ----")
    println("--- Greedy deterministic construction ---")
    println("Best solution cost: $best_cost")
    println("Average cost: $avg_cost")
    println("Average running time: $avg_time_seconds seconds")
    println("Final objective (last run): $avg_final_obj")
    
    return best_sol, best_cost, avg_cost, avg_final_obj, avg_time
end

#########################################################################################
######################### RANDOMIZED CONSTRUCTION: SHUFFLE ##############################

function experiment_randomized_shuffle(unodes, vnodes, edges, constraints, iterations=5, max_iter=10)
    best_sol = nothing
    best_cost = Inf
    cost_list = []  
    time_list = [] 
    
    for i in 1:iterations
        start_time = now()
        sol, cost = randomized_construction_heuristic(unodes, vnodes, edges, constraints, max_iter) 
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

    avg_final_obj = cost_list[end]

    println("\n---- Experiment Summary ----")
    println("--- Randomized construction [Shuffle] ---")
    println("Best Solution Cost: $best_cost")
    println("Average Cost: $avg_cost")
    println("Average Running Time: $avg_time seconds")
    println("Final Objective (last run): $avg_final_obj")
    
    return best_sol, best_cost, avg_cost, avg_final_obj, avg_time
end

#########################################################################################
#################### RANDOMIZED CONSTRUCTION: K MOST PROMISING ##########################

function experiment_Kgreedy_randomized(unodes, vnodes, edges, constraints, k, iterations=5, max_iter=10)
    best_sol = nothing
    best_cost = Inf
    cost_list = [] 
    time_list = [] 

    for i in 1:iterations
        start_time = now()
        sol, cost = repeat_randomized_K(unodes, vnodes, edges, constraints, k, max_iter)
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

    avg_final_obj = cost_list[end]

    println("\n--- Experiment summary ---")
    println("--- Randomized construction [K most promising] ---")
    println("Best solution cost: $best_cost")
    println("Average cost: $avg_cost")
    println("Average running time: $avg_time seconds")
    println("Final objective (last run): $avg_final_obj")

    return best_sol, best_cost, avg_cost, avg_final_obj, avg_time
end

#########################################################################################
################################## EXPERIMENTS ##########################################
# experiment_greedy_det(unodes, vnodes, edges, constraints)
# experiment_randomized_shuffle(unodes, vnodes, edges, constraints)
# experiment_Kgreedy_randomized(unodes, vnodes, edges, constraints, 5)