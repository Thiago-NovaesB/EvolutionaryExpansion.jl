@kwdef mutable struct Size
    I::Int #number of generators
    B::Int #number of buses
    L::Int #number of lines
    J::Int #number of generators candidates
    K::Int #number of lines candidates
end

@kwdef mutable struct Data
    Gmax::Vector{Float64}
    Fmax::Vector{Float64}
    demand::Vector{Float64}
    ger2bus::Vector{Int}
    A::Matrix{Int}
    R::Vector{Float64}
    generation_cost::Vector{Float64}
    def_cost::Vector{Float64}

    expansion_line_cost::Vector{Float64}
    expansion_generator_cost::Vector{Float64}
end

@kwdef mutable struct Cache
    generator_is_active::Vector{Bool}
    line_is_active::Vector{Bool}
end

@kwdef mutable struct Options
    solver::Union{DataType,Nothing} = nothing
    use_kirchhoff_second_law::Bool = false
end

@kwdef mutable struct Output

end

@kwdef mutable struct Problem
    size::Size
    data::Data
    cache::Cache
    options::Options
    output::Output
end
