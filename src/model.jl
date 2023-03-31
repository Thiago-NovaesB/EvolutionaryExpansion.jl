function primal_operation(prb::Problem)::Float64
    n = prb.size
    d = prb.data
    c = prb.cache
    o = prb.options

    model = Model(o.solver)
    set_silent(model)

    @variable(model, 0 <= g[i in (1:n.I)[c.generator_is_active]] <= d.Gmax[i] + c.generator_exp[i])
    @variable(model, -d.Fmax[l] <= f[l in (1:n.L)[c.line_is_active]] <= d.Fmax[l])
    @variable(model, theta[1:n.B])
    @variable(model, 0 <= def_demand[b = 1:n.B] <= d.demand[b])

    @constraint(model, [b = 1:n.B], sum(g[i] for i in (1:n.I)[c.generator_is_active] if d.ger2bus[i] == b) + sum(f[l] * d.A[b, l] for l in (1:n.L)[c.line_is_active]) == d.demand[b] - def_demand[b])
    @constraint(model, [l in (1:n.L)[c.line_is_active]], sum(theta[b] * d.A[b, l] for b in 1:n.B) == d.R[l]*f[l])

    @objective(model, Min, sum(d.generation_cost[i]*g[i] for i in (1:n.I)[c.generator_is_active])
                           + sum(def_demand[b]* d.def_cost[b] for b = 1:n.B))
    optimize!(model)
    return objective_value(model)
end

function total_cost(x::BitVector, prb::Problem)::Float64
    d = prb.data
    c = prb.cache
    n = prb.size
    c.line_is_active[n.L-n.K+1:n.L] = x
    expansion_cost = sum(x.*d.expansion_line_cost)
    operational_cost = EvolutionaryExpansion.primal_operation(prb)
    return expansion_cost + operational_cost
end

function test()::Problem
    prb = create_problem()
    c = prb.cache
    n = prb.size
    res = Evolutionary.optimize(x->total_cost(x, prb), BitVector(zeros(3)), GA(selection=uniformranking(5),
    mutation=flip, crossover=SPX))
    c.line_is_active[n.L-n.K+1:n.L] = Evolutionary.minimizer(res)
    return prb
end
