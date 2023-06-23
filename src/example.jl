function create_problem_line()::Problem
    prb = EvolutionaryExpansion.Problem()
    size = EvolutionaryExpansion.Size()
    data = EvolutionaryExpansion.Data()
    options = EvolutionaryExpansion.Options()

    size.I = 3 #number of generators
    size.B = 3 #number of buses
    size.L = 6 #number of lines
    size.J = 0 #number of generators candidates
    size.K = 3 #number of lines candidates

    options.use_kirchhoff_second_law = true
    options.solver = HiGHS.Optimizer

    data.Gmax = [100, 0, 0]
    data.Fmax = [100,20,100,100,20,100]
    data.demand = [0, 0, 100]
    data.ger2bus = [1, 2, 3]
    data.A = [-1 -1 0 -1 -1 0;
                0 1 -1 0 1 -1;
                1 0 1 1 0 1]
    data.R = [1,1,1,1,1,1]
    data.generation_cost = [100, 150, 1000]
    data.def_cost = [10000, 10000, 10000]

    data.expansion_line_cost = [10000, 10000, 10000]
    data.expansion_generator_cost = [10000, 10000, 10000]

    prb.size = size
    prb.data = data
    prb.options = options
    create_cache!(prb)
    return prb
end

function create_problem_generator()::Problem
    prb = EvolutionaryExpansion.Problem()
    size = EvolutionaryExpansion.Size()
    data = EvolutionaryExpansion.Data()
    options = EvolutionaryExpansion.Options()

    size.I = 6 #number of generators
    size.B = 3 #number of buses
    size.L = 3 #number of lines
    size.J = 3 #number of generators candidates
    size.K = 0 #number of lines candidates

    options.use_kirchhoff_second_law = true
    options.solver = HiGHS.Optimizer

    data.Gmax = [100, 0, 0, 0, 0, 100]
    data.Fmax = [100,20,100]
    data.demand = [0, 0, 100]
    data.ger2bus = [1, 2, 3, 1, 2, 3]
    data.A = [-1 -1 0;
                0 1 -1;
                1 0 1]
    data.R = [1,1,1]
    data.generation_cost = [100, 150, 100, 100, 150, 100]
    data.def_cost = [10000, 10000, 10000]

    data.expansion_line_cost = [10000, 10000, 10000]
    data.expansion_generator_cost = [10000, 10000, 10000]

    prb.size = size
    prb.data = data
    prb.options = options
    create_cache!(prb)
    return prb
end

function create_problem_huge()::Problem
    prb = EvolutionaryExpansion.Problem()
    size = EvolutionaryExpansion.Size()
    data = EvolutionaryExpansion.Data()
    options = EvolutionaryExpansion.Options()

    size.I = 400 #number of generators
    size.B = 600 #number of buses
    size.L = 1000 #number of lines
    size.J = 100 #number of generators candidates
    size.K = 100 #number of lines candidates

    options.use_kirchhoff_second_law = true
    options.solver = HiGHS.Optimizer

    data.Gmax = rand(size.I)*100
    data.Fmax = rand(size.L)*50
    data.demand = rand(size.B)*60
    data.ger2bus = rand(1:size.B,size.I)
    data.A = zeros(size.B, size.L)

    for l in 1:size.L
        n1 = rand(1:size.B)
        n2 = rand(1:size.B)
        while n1 == n2
            n2 = rand(1:size.B)
        end
        data.A[n1, l] = -1
        data.A[n2, l] = 1
    end

    data.R = ones(size.L)
    data.generation_cost = rand(size.I)*75
    data.def_cost = ones(size.B)*10000

    data.expansion_line_cost = ones(size.K)*10000
    data.expansion_generator_cost = ones(size.J)*10000

    prb.size = size
    prb.data = data
    prb.options = options
    create_cache!(prb)
    return prb
end