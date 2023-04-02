function create_cache!(prb::Problem)
    cache = prb.cache
    size = prb.size

    cache.generator_is_active = vcat(ones(size.I - size.J), zeros(size.J))
    cache.line_is_active = vcat(ones(size.L - size.K), zeros(size.K))
    return
end