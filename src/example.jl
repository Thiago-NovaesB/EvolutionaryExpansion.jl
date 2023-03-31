function create_problem()::Problem
    prb = EvolutionaryExpansion.Problem()
    size = EvolutionaryExpansion.Size()
    data = EvolutionaryExpansion.Data()
    options = EvolutionaryExpansion.Options()
    cache = EvolutionaryExpansion.Cache()

    size.I = 3 #number of generators
    size.B = 3 #number of buses
    size.L = 6 #number of lines
    size.J = 3 #number of generators candidates
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

    cache.generator_is_active= [1, 1, 1]
    cache.line_is_active= [1, 1, 1, 0, 0, 0]
    cache.generator_exp = [0, 0, 0]

    prb.size = size
    prb.data = data
    prb.options = options
    prb.cache = cache
    return prb
end