include("../MWCCP.jl")
include("../Neighborhoods/Neighborhoods.jl")
using .MWCCPTools, .Neighborhoods

(unodes, vnodes, u_dict, v_dict, constraints, edges, f_value) =  extract_mwccp(pwd() *
 "/data/tuning_instances/small/inst_50_4_00001")

g = MWCCP(unodes, vnodes, u_dict, v_dict, constraints, edges, f_value)

function VND(g, limit, bestfit = true)
    l, i = 0, 1
    Neighborhoods = [get_flip_consecutive_nodes_neighborhood,
    get_move_one_node_neighborhood,
    get_consecutive_flips_with_one_node_move_neighborhood,
    get_2_opt_neighborhood,
    get_2_opt_with_one_node_move_neighborhood
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
solution = VND(g, 2)
println(solution)
#= neighborhood = flip_consecutive_nodes(g) =#
#= neighborhood = move_one_node(g) =#
#= neighborhood = get_2_opt_neighborhood(g) =#
#= println(neighborhood)
 =#
#= println(get_first_improvement(g.v_nodes, g.f_value, neighborhood))
println(get_best_improvement(g.v_nodes, g.f_value, neighborhood)) =#
# Print results to check
#= println("Unodes: ", typeof(u_nodes))
println("Vnodes: ", typeof(v_nodes))
println("Constraints: ", typeof(constraints))
println("Edges: ", typeof(edges)) =#