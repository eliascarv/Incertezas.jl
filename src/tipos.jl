struct RM{T<:AbstractFloat}
    I::T
    U::T
    RM(I::T, U::T) where {T<:AbstractFloat} = new{T}(I, U)
end

RM(I::Real, U::Real) = RM(float(I), float(U))
const ± = RM

const AbstractIntOrFloat = Union{Integer, AbstractFloat}

struct Medicao{T<:AbstractFloat, S<:AbstractIntOrFloat}
    RM::RM{T}
    v::S

    function Medicao{T, S}(RM::RM{T}, v::S) where {T<:AbstractFloat, S<:AbstractIntOrFloat}

        if v < one(v)
            throw(ArgumentError("Não é possível criar um objeto Medicao com v < 1."))
        end

        return new{T, S}(RM, v)
    end
end

Medicao(RM::RM{T}, v::S) where {T<:AbstractFloat, S<:Integer} = Medicao{T, S}(RM, v)
function Medicao(RM::RM{T}, v::S) where {T<:AbstractFloat, S<:AbstractFloat}
    
    if isinf(v)
        return Medicao{T, S}(RM, v)
    end
    
    return Medicao(RM, trunc(Int, v))
end


function Base.show(io::IO, med::RM)
    print(io, "$(round(med.I, digits = 5)) ± $(round(med.U, digits = 5))")
end

function Base.show(io::IO, med::Medicao)
    print(io, "Medição \n$(med.RM), v = $(med.v)")
end