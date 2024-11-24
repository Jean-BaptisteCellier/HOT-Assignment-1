module LocalSearch

    include("../MWCCP.jl")
    include("../Neighborhoods/Neighborhoods.jl")
    using ..MWCCPTools,  .Neighborhoods

    export local_search
    export print_average_time
    export local_search_consecutive
    export local_search_2_opt

    ######### LOCAL SEARCH ##########

    function local_search(g::MWCCP, neighborhood_function::Function, step_function::Function, iterations=100)
        v_nodes = g.v_nodes
        f_value = g.f_value

        current_solution = deepcopy(g)

        for _ in 1:iterations
            neighbors = neighborhood_function(current_solution)
            v_nodes, f_value = step_function(current_solution.v_nodes, current_solution.f_value, neighbors)
            current_solution = MWCCP(current_solution.u_nodes, v_nodes, current_solution.u_dict, reverse_list(v_nodes), current_solution.constraints, current_solution.edges, f_value)
        end

    return current_solution
    end

    function print_average_time(heuristic_method, g::MWCCP, iterations, ls_it, disp = true)
        elapsed_time = 0
        solution = deepcopy(g)
        for i in 1:iterations
            start = time()
            solution = heuristic_method(g, ls_it)
            the_end = time()
            if disp
                println(i)
                println(solution)
            end
            elapsed_time += (the_end - start)
        end
        println("")
        print("Elapsed time : ")
        println(elapsed_time / iterations)
        return solution
    end

    function local_search_consecutive(g::MWCCP, iterations)
        local_search(g, get_flip_consecutive_nodes_neighborhood, get_best_improvement, iterations)
    end

    function local_search_2_opt(g::MWCCP, iterations)
        local_search(g, get_2_opt_neighborhood, get_best_improvement, iterations)
    end

end