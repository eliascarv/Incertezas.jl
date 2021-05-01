struct RM{T<:AbstractFloat}
    I::T
    U::T
    RM(I::T, U::T) where {T<:AbstractFloat} = new{T}(I, U)
end

RM(I::Real, U::Real) = RM(float(I), float(U))
const ± = RM


struct Medicao{T<:AbstractFloat}
    RM::RM{T}
    v::Union{T, Int}

    function Medicao{T}(RM::RM{T}, v::Union{T, Int}) where {T<:AbstractFloat}

        if v < 1
            throw(ArgumentError("Não é possível criar um objeto Medicao com v < 1."))
        end

        return new{T}(RM, v)
    end
end

Medicao(RM::RM{T}, v::Int) where {T<:AbstractFloat} = Medicao{T}(RM, v)
function Medicao(RM::RM{T}, v::AbstractFloat) where {T<:AbstractFloat}
    
    if isinf(v)
        return Medicao{T}(RM, v)
    end
    
    return Medicao(RM, trunc(Int, v))
end


function Base.show(io::IO, med::RM)
    print(io, "$(round(med.I, digits = 5)) ± $(round(med.U, digits = 5))")
end

function Base.show(io::IO, med::Medicao)
    print(io, "Medição \n$(med.RM), v = $(med.v)")
end