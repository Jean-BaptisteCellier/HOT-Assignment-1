module MWCCPTools

    #= using Graphs
    using SimpleWeightedGraphs =#

    export MWCCP
    export reverse_list
    export crossed_values

    struct MWCCP
        u_nodes::Vector{Int64}
        v_nodes::Vector{Int64}
        u_dict::Dict{Int64,Int64}
        v_dict::Dict{Int64,Int64}
        constraints::Vector{Tuple{Int64, Int64}}
        edges::Vector{Tuple{Tuple{Int64,Int64},Int64}}
    #=     graph::SimpleWeightedGraph =#
        f_value::Int64
    end

    # Function to read the sizes
    function read_sizes(filename)
        println("Opening file: ", filename)  # Debugging
        open(filename, "r") do file
            sizes = split(readline(file))  # Read the first line and split it
            n_unodes = parse(Int, sizes[1])  
            n_vnodes = parse(Int, sizes[2])  
            n_constraints = parse(Int, sizes[3])
            n_edges = parse(Int, sizes[4])
            return n_unodes, n_vnodes, n_constraints, n_edges
        end
    end

    # Function to create unodes and vnodes
    function create_unodes_vnodes(n_unodes, n_vnodes)
        unodes = 1:n_unodes
        vnodes = (n_unodes+1):(n_unodes + n_vnodes)
        return collect(unodes), collect(vnodes)
    end

    # Function to read constraints
    function read_constraints(filename, n_constraints)
        constraints = []
        open(filename, "r") do file
            readline(file)  # Skip the first line
            while n_constraints > 0
                line = readline(file)
                line = strip(line)  # Remove spaces
                if isempty(line) || startswith(line, "#")  # Skip comment/empty lines
                    continue
                end
                nums = parse.(Int, split(line))  # Parse integers
                push!(constraints, tuple(nums[1], nums[2]))
                n_constraints -= 1  # Decrease count of remaining constraints
            end
        end
        return constraints
    end

    # Function to read edges
    function read_edges(filename::String)
        source::Vector{Int64} = []
        destination::Vector{Int64} = []
        weight::Vector{Int64} = []
        edges::Vector{Tuple{Tuple{Int64, Int64}, Int64}} = []
        
        open(filename, "r") do file
            for line in eachline(file)
                line = strip(line)  # Remove leading/trailing spaces
                
                # Skip empty lines or comments
                if isempty(line) || startswith(line, "#")
                    continue
                end
                
                # If we encounter the #edges marker, switch to reading edges
                if line == "#edges"
                    continue  # Skip the line #edges
                end
                
                # Parse edges (node1, node2, cost)
                parsed_line = split(line)
                if length(parsed_line) == 3 
                    node1 = parse(Int, parsed_line[1])
                    node2 = parse(Int, parsed_line[2])
                    cost = parse(Int, parsed_line[3])
                    
                    if node1 != node2
                        push!(source, node1)
                        push!(destination, node2)
                        push!(weight, cost)
                        push!(edges, ((node1,node2),cost))
                    end
                end
            end
        end
        return source, destination, weight, edges
    end


    ########### MAIN CODE ####################

    export extract_mwccp

    function extract_mwccp(filepath)

        # pwd() * "/HOT-Assignment-1/data/tuning_instances/small/inst_50_4_00001"

        # Read sizes
        n_unodes, n_vnodes, n_constraints, n_edges = read_sizes(filepath)

        # Create unodes and vnodes
        unodes, vnodes = create_unodes_vnodes(n_unodes, n_vnodes)

        # Read constraints and edges
        constraints = read_constraints(filepath, n_constraints)
        source, destination, weight, edges = read_edges(filepath)

    #=    graph = SimpleWeightedGraph(source, destination, weight) =#

        u_dict, v_dict = reverse_list(unodes), reverse_list(vnodes)

        positions = get_vertices_positions(edges,u_dict,v_dict)

        f_value = objective_value(positions)

        return (unodes, vnodes, u_dict, v_dict, constraints, edges, f_value)

    end

    #= unodes, vnodes, constraints, edges = extract_mwccp(pwd() * "/HOT-Assignment-1/data/tuning_instances/small/inst_50_4_00001")
    =#

    function reverse_list(nodes)
        d = Dict()
        N = length(nodes)
        for i in 1:N
            d[nodes[i]] = i
        end
        return d
    end

    #= function update_dict(dict, val, nodes)
        if !haskey(dict, val)
            dict[val] = (findfirst(x -> x==val, nodes))
        end
    end =#

    function get_vertices_positions(edges, u_dict, v_dict)
        positions::Vector{Tuple{Tuple{Int64,Int64},Int64}} = []
        for ((e1,e2),w) in edges
            x, y = u_dict[e1], v_dict[e2]
            push!(positions, ((x,y),w))
        end
        return positions
    end

    function crossed_values(i1,i2,j1,j2)
        return ((j1 < j2) && (i1 > i2)) || ((j1 > j2) && (i1 < i2))
    end

    function objective_value(positions::Vector{Tuple{Tuple{Int64,Int64},Int64}})
        N = length(positions)
        f_value = 0
        for i in 1:N-1
            ((e11,e12),w1) = positions[i]
            for j in i+1:N
                ((e21,e22),w2) = positions[j]
                if crossed_values(e11,e21,e12,e22)
                        f_value += w1 * w2
                end
            end
        end
        return f_value
    end

    # Surcharge de la méthode string
    Base.show(io :: IO, g::MWCCP) = print(io,
                "------------------------------------------------MWCCP------------------------------------------------" * '\n' *
            "u_nodes: $(g.u_nodes)," * '\n' *
            "v_nodes: $(g.v_nodes)," * '\n' *
            "constraints: $(g.constraints)," * '\n' *
            "graph: graph: {($(length(g.u_nodes)) + $(length(g.v_nodes))), $(length(g.edges))} 
                undirected simple Int64 graph with Int64 weights" * '\n' *
            "f_value : $(g.f_value)" * '\n' *
            "------------------------------------------------------------------------------------------------------"
    )

end

#= # Print results to check
println("Unodes: ", unodes)
println("Vnodes: ", vnodes)
println("Constraints: ", constraints)
println("Edges: ", edges) =#
