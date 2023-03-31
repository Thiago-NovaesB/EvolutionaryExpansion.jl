module EvolutionaryExpansion

using LinearAlgebra
using JuMP
using HiGHS
using Evolutionary
using Gurobi

include("utils.jl")
include("types.jl")
include("example.jl")
include("model.jl")

end # module EvolutionaryExpansion
