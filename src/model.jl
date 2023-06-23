function primal_operation(prb::Problem)::Float64
    n = prb.size
    d = prb.data
    c = prb.cache
    o = prb.options

    model = Model(o.solver)
    set_silent(model)

    @variable(model, 0 <= g[i in (1:n.I)[c.generator_is_active]] <= d.Gmax[i])
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

    expansion_cost = 0
    if n.J > 0
        c.generator_is_active[n.I-n.J+1:n.I] = x[1:n.J]
        expansion_cost += sum(x[1:n.J].*d.expansion_generator_cost)
    end
    if n.K > 0
        c.line_is_active[n.L-n.K+1:n.L] = x[n.J+1:end]
        expansion_cost += sum(x[n.J+1:end].*d.expansion_line_cost)
    end
    operational_cost = primal_operation(prb)
    return expansion_cost + operational_cost
end

function ga_expansion(prb::Problem)::Float64
    c = prb.cache
    n = prb.size
    d = prb.data
    res = Evolutionary.optimize(x->total_cost(x, prb),
                                BitVector(zeros(n.J+n.K)),
                                GA(selection=uniformranking(5), mutation=flip, crossover=SPX),
                                Evolutionary.Options(time_limit=10.0))

    x = Evolutionary.minimizer(res)
    expansion_cost = 0
    if n.J > 0
        c.generator_is_active[n.I-n.J+1:n.I] = x[1:n.J]
        expansion_cost += sum(x[1:n.J].*d.expansion_generator_cost)
    end
    if n.K > 0
        c.line_is_active[n.L-n.K+1:n.L] = x[n.J+1:end]
        expansion_cost += sum(x[n.J+1:end].*d.expansion_line_cost)
    end
    return Evolutionary.minimum(res)
end

function mip_expansion(prb::Problem)::Float64
    n = prb.size
    d = prb.data
    o = prb.options

    model = Model(o.solver)
    set_silent(model)
    set_time_limit_sec(model, 10.0)

    @variable(model, 0 <= g[i in 1:n.I] <= d.Gmax[i])
    @variable(model, -d.Fmax[l] <= f[l in 1:n.L] <= d.Fmax[l])
    @variable(model, -d.Fmax[l] <= aux[l in n.L-n.K+1:n.L] <= d.Fmax[l])
    @variable(model, theta[1:n.B])
    @variable(model, 0 <= def_demand[b = 1:n.B] <= d.demand[b])

    @variable(model, g_used[n.I-n.J+1:n.I], Bin)
    @variable(model, f_used[n.L-n.K+1:n.L], Bin)

    @constraint(model, [l in n.L-n.K+1:n.L], aux[l] <= d.Fmax[l]*f_used[l])
    @constraint(model, [l in n.L-n.K+1:n.L], aux[l] <= f[l])
    @constraint(model, [l in n.L-n.K+1:n.L], aux[l] >= f[l] - d.Fmax[l]*(1-f_used[l]))
    @constraint(model, [l in n.L-n.K+1:n.L], aux[l] >= -d.Fmax[l]*f_used[l])

    @constraint(model, [i in n.I-n.J+1:n.I], g[i] <= d.Gmax[i]*g_used[i])

    @constraint(model, [b = 1:n.B], sum(g[i] for i in 1:n.I if d.ger2bus[i] == b) + sum(f[l] * d.A[b, l] for l in 1:n.L-n.K) +
                                    + sum(aux[l] * d.A[b, l] for l in n.L-n.K+1:n.L) == d.demand[b] - def_demand[b])

    @constraint(model, [l in 1:n.L], sum(theta[b] * d.A[b, l] for b in 1:n.B) == d.R[l]*f[l])

    @objective(model, Min, sum(d.generation_cost[i]*g[i] for i in 1:n.I)
                           + sum(def_demand[b]* d.def_cost[b] for b = 1:n.B)
                           + sum(g_used[n.I - n.J + i]*d.expansion_generator_cost[i] for i in 1:n.J)
                           + sum(f_used[n.L - n.K + l]*d.expansion_line_cost[l] for l in 1:n.K)
                           )

    optimize!(model)
    return objective_value(model)
end
