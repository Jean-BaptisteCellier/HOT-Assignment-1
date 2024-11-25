include("../MWCCP.jl")
include("../Neighborhoods/Neighborhoods.jl")
include("local_search.jl")

using .MWCCPTools, .Neighborhoods, .LocalSearch

if length(ARGS) > 0
    graph_path = ARGS[1]
else
    error("A graph file must be given.")
end

(unodes, vnodes, u_dict, v_dict, constraints, edges, f_value) =  extract_mwccp(graph_path)

g = MWCCP(unodes, vnodes, u_dict, v_dict, constraints, edges, f_value)
println(g)

res = print_average_time(local_search_move_one_node, g, 4, 20, false)

println(res)