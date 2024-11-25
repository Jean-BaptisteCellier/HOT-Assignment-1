using Statistics  
using Dates   

include("Script data processing.jl")
include("construction_heuristics.jl")
include("Simulated Annealing.jl")

if length(ARGS) > 0
    filepath = ARGS[1]
else
    error("A graph file must be given.")
end

function experiment_simulated_annealing(filepath, neighbor_function;  
    initial_temperature=100, cooling_rate=0.95, min_temperature=1e-3, repetitions=10)

    n_unodes, n_vnodes, n_constraints, n_edges = read_sizes(filepath)
    unodes, vnodes = create_unodes_vnodes(n_unodes, n_vnodes)
    constraints = read_constraints(filepath, n_constraints)
    edges = read_edges(filepath)

    res_const = greedy_heuristic(unodes, vnodes, edges, constraints)
    initial_solution = res_const[1]
    initial_cost = res_const[2]
    println("Initial cost: $initial_cost")
    best_sol = initial_solution
    best_cost = initial_cost
    cost_list = []  
    time_list = []  

    for i in 1:repetitions
        start_time = now()
        sol, cost = simulated_annealing(initial_solution, initial_cost, neighbor_function,
        edges, constraints; initial_temperature, cooling_rate, min_temperature)
        end_time = now()
        elapsed_time = end_time - start_time
        if cost < best_cost
            best_sol = sol
            best_cost = cost
        end

        push!(cost_list, cost)
        push!(time_list, Dates.value(elapsed_time)) 

        println("Run $i: Cost = $cost, Time = $elapsed_time")
    end

    avg_cost = mean(cost_list)
    avg_time = mean(time_list) / 1000 
    stddev_cost = std(cost_list)
    stddev_time = std(time_list) / 1000

    final_cost = cost_list[end]

    println("\n--- Simulated Annealing Experiment Summary ---")
    println("Best Solution Cost: $best_cost")
    println("Average Cost: $avg_cost")
    println("Cost std dev: $stddev_cost")
    println("Average Running Time: $avg_time seconds")
    println("Time std dev: $stddev_time")
    println("Final Objective (last run): $final_cost")

    return best_sol, best_cost, avg_cost, final_cost, avg_time
end

@time begin
    experiment_simulated_annealing(filepath, random_swap, repetitions = 4)
end

########### MAIN CODE ####################

# Path to the input file
# filepath = "C:/Users/jbcel/OneDrive/Documents/TU Wien/Heuristic Optimization Techniques/tuning_instances/tuning_instances/small/inst_50_4_00002"

# initial_solution = [6,7,8,9,10]
# edges = [((1,7),1), ((2,8),2), ((3,9),1), ((4,10),3), ((5,6), 11)]
# constraints = [(7,10), (8,9)]

# best_sol, best_cost, avg_cost, final_cost, avg_time = experiment_simulated_annealing(
#     filepath,
#     random_swap,
#     initial_temperature=10,
#     cooling_rate=0.97,
#     min_temperature=1e-3,
#     repetitions=4
# )