# Function to read the sizes
function read_sizes(filename)
    println("Opening file: ", filename)  # Debugging
    open(filename, "r") do file
        sizes = split(readline(file))
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
    edges = []  # This will hold edges with costs
    
    open(filename, "r") do file
        for line in eachline(file)
            line = strip(line)  # Remove spaces
            
            # Skip empty lines or comments
            if isempty(line) || startswith(line, "#")
                continue
            end
            
            # Skip the line #edges
            if line == "#edges"
                continue 
            end
            
            # Parse edges (node1, node2, cost)
            parsed_line = split(line)
            if length(parsed_line) == 3 
                node1 = parse(Int, parsed_line[1])
                node2 = parse(Int, parsed_line[2])
                cost = parse(Int, parsed_line[3])
                
                if node1 != node2
                    push!(edges, ((node1, node2), cost))
                end
            end
        end
    end
    return edges
end
