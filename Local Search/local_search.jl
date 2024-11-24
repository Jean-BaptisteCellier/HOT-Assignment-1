module LocalSearch

    include("../MWCCP.jl")
#=     include("../Neighborhoods/Neighborhoods.jl") =#
    using ..MWCCPTools#=,  .Neighborhoods =#

    export local_search

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

end