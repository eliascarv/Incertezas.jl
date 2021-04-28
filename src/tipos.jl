struct RM{T<:AbstractFloat}
    I::T
    U::T
    RM(I::T, U::T) where {T<:AbstractFloat} = new{T}(I, U)
end

RM(I::Real, U::Real) = RM(float(I), float(U))
const ± = RM

struct Medicao{T<:AbstractFloat}
    RM::RM{T}
    v::Union{Int, T}

    function Medicao(RM::RM{T}, v::Union{Int, T}) where {T<:AbstractFloat}
    
        if v isa Int
            return new{T}(RM, v)
        end
        
        if isinf(v)
            return new{T}(RM, v)
        end
        
        return new{T}(RM, trunc(Int, v))
    end
end


function Base.show(io::IO, med::RM)
    print(io, "$(round(med.I, digits = 5)) ± $(round(med.U, digits = 5))")
end

function Base.show(io::IO, med::Medicao)
    print(io, "Medição \n$(med.RM), v = $(med.v)")
end