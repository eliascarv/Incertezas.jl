module Incertezas

using Distributions

export RM, Medicao, ± 
export mens_invar, mens_invar_emax
export mens_var, mens_var_emax
export student, incerteza, correcao

include("tipos.jl")
include("funcoes.jl")

end # End of Module