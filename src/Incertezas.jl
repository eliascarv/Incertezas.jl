
module Incertezas

using Distributions

export RM, Medicao, ± 
export medinvar, medinvar_emax
export medvar, medvar_emax
export student

include("tipos.jl")
include("funcoes.jl")

end # End of Module