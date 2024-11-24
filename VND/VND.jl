include("../MWCCP.jl")
include("../Neighborhoods/Neighborhoods.jl")
using .MWCCPTools, .Neighborhoods, Test

#= Give file path as an argument when calling julia !  You can create a launch.json in Vscode. =#

if length(ARGS) > 0
    graph_path = ARGS[1]
else
    error("A graph file must be given.")
end

(unodes, vnodes, u_dict, v_dict, constraints, edges, f_value) =  extract_mwccp(graph_path)

g = MWCCP(unodes, vnodes, u_dict, v_dict, constraints, edges, f_value)

function VND(g, limit, bestfit = true)
    l, i = 0, 1
    #=     There is no "get_2_opt_with_consecutive_flips" because the consecutive flips are already included in 2_opt =#
    Neighborhoods = [get_flip_consecutive_nodes_neighborhood,
    get_2_opt_neighborhood,
    get_move_one_node_neighborhood,
    get_consecutive_flips_with_one_node_move_neighborhood,
    get_2_opt_with_one_node_move_neighborhood,
    ]
    n = length(Neighborhoods)
    value = g.f_value
    nodes = g.v_nodes
    while (l < limit) && (i <= n)
        neighborhood = Neighborhoods[i](g)
        if bestfit
            best_neighbor = get_best_improvement(nodes, value, neighborhood) #/!\ v_nodes, f_value !
        else
            best_neighbor = get_first_improvement(nodes, value, neighborhood)
        end
        (neighbor_nodes, neighbor_value) = best_neighbor
        if value == neighbor_value
            l += 1
        else
            l = 0
        end
        nodes, value = neighbor_nodes, neighbor_value
        neighbor_v_dict = reverse_list(nodes)
        g = MWCCP(g.u_nodes,nodes,g.u_dict, neighbor_v_dict, g.constraints, g.edges, value)
        i += 1
    end
    return g
end

println(g)

@time begin
    solution = VND(g, 3)
end

#= @test objective_value(solution) == solution.f_value =#

println(solution)