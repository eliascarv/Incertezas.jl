# Funções internas
_incerteza(; u::Real, t::Real) = u * t
_incerteza(U::NamedTuple) = _incerteza(; U...)
_incerteza(U::Real) = U

const RealOrNamedTuple = Union{Real, NamedTuple}

# Funções para calculos comuns de Metrologia

"""
    student(v::AbstractIntOrFloat, prob::AbstractFloat = 0.9545)

Calcula o índice t de Student para v graus de liberdade.
O argumento v pode ser um número inteiro ou um Inf.
Se for passdo um número Float ele será truncado.

    student(med::Medicao, prob::AbstractFloat = 0.9545)

Calcula o índice t de Student para um objeto de medição.
Como todas as funções desse pacote, a probabilidade tem valor
padrão de 0.9545, o que não impede que seja passdo um valor diferente. 

# Exemplos
```jldoctest
julia> student(50)
2.0512507818518815

julia> student(50, 0.95)
2.0085591121007607

julia> m = Medicao(15.4 ± 0.85, 50)
Medição 
15.4 ± 0.85, v = 50

julia> student(m, 0.9)
1.675905025163097
```
"""
student(v::AbstractIntOrFloat, prob::AbstractFloat = 0.9545) = quantile(TDist(v), 1 - (1-prob)/2)
student(med::Medicao, prob::AbstractFloat = 0.9545) = quantile(TDist(med.v), 1 - (1-prob)/2)

"""
    incerteza(I::Vector, prob::AbstractFloat = 0.9545)

Calcula a incerteza de medição de um vetor de indicações.
O valor padrão para a probabilidade é de 0.9545.

    incerteza(I::Matrix, prob::AbstractFloat = 0.9545)

Calcula a incerteza de medição para cada coluna de uma matriz
(no caso cada coluna seria uma observação diferente), retornando
um vetor com as respectivas incertezas. 

# Exemplos
```jldoctest
julia> I = rand(4)
4-element Vector{Float64}:
 0.4208994737862477
 0.3377616070219951
 0.46985105150020456
 0.9339224640544577

julia> incerteza(I)
0.885628905821176

julia> I = rand(4, 4)
4×4 Matrix{Float64}:
 0.723973   0.782779  0.196474  0.863371
 0.0975783  0.032279  0.914111  0.727987
 0.664777   0.761189  0.878717  0.216146
 0.0799416  0.272497  0.981025  0.634128

julia> incerteza(I)
4-element Vector{Float64}:
 1.1592427510559653
 1.226925516574539
 1.2120694557110712
 0.9231919779939417
```
"""
function incerteza(I::Vector, prob::AbstractFloat = 0.9545)
    v = length(I) - 1
    u = std(I)
    t = student(v, prob)
    U = u * t
    return U
end

function incerteza(I::Matrix, prob::AbstractFloat = 0.9545)
    v = size(I, 1) - 1
    u = [std(I[:, i]) for i in axes(I, 2)]
    t = student(v, prob)
    U = u * t
    return U
end

function correcao(I::Vector, VV::Real)
    I̅ = mean(I)
    C = -(I̅ - VV)
    return C
end

function correcao(I::Matrix, VV::Vector)
    I̅ = [mean(I[:, i]) for i in axes(I, 2)]
    C = -(I̅ - VV)
    return C
end

# Funçõs para criar objetos de Medicao
function mens_invar(I::Vector; C::Real = 0, prob::AbstractFloat = 0.9545)
    I̅ = mean(I)
    n = length(I)
    v = n - 1
    u = std(I)
    U = u * student(v, prob)
    return Medicao(RM(I̅ + C, U/√n), v)
end

function mens_invar(I::Real, U::RealOrNamedTuple; 
                    n::AbstractIntOrFloat = 1, C::Real = 0)
    v = n - 1
    Uᵥ = _incerteza(U)

    n == 1 && return RM(I + C, Uᵥ)

    return Medicao(RM(I + C, Uᵥ/√n), v)
end

function mens_invar_emax(I::Vector, Emax::Real)
    I̅ = mean(I)
    v = length(I) - 1
    return Medicao(RM(I̅, Emax), v)
end

mens_invar_emax(I::Real, Emax::Real) = RM(I, Emax)

function mens_var(I::Vector; C::Real = 0, prob::AbstractFloat = 0.9545)
    I̅ = mean(I)
    v = length(I) - 1
    u = std(I)
    t = student(v, prob)
    U = u * t
    return Medicao(RM(I̅ + C, U), v)
end

function mens_var(I̅::Real, U::RealOrNamedTuple;
                  n::AbstractIntOrFloat = Inf, C::Real = 0)
    v = n - 1
    Uᵥ = _incerteza(U)
    return Medicao(RM(I̅ + C, Uᵥ), v)
end

function mens_var_emax(I::Vector, Emax::Real; prob::AbstractFloat = 0.9545)
    I̅ = mean(I)
    v = length(I) - 1
    u = std(I)
    t = student(v, prob)
    U = u * t
    return Medicao(RM(I̅, U + Emax), v)
end

function mens_var_emax(I̅::Real, U::RealOrNamedTuple, Emax::Real;
                       n::AbstractIntOrFloat = Inf)
    v = n - 1
    Uᵥ = _incerteza(U)
    return Medicao(RM(I̅, Uᵥ + Emax), v)
end

# Operações com obejtos de Medicao
function Base.:+(x::Medicao, y::Medicao)

    I = x.RM.I + y.RM.I
    
    t₁ = student(x)
    t₂ = student(y)
    
    u₁ = x.RM.U/t₁
    u₂ = y.RM.U/t₂
    
    if u₁ > u₂
        r = u₂/u₁
        u = u₁ * √(1 + r^2)
    else
        r = u₁/u₂
        u = u₂ * √(1 + r^2)
    end
    
    v = trunc(u^4/(u₁^4/x.v + u₂^4/y.v))
    t = student(v)
    U = u * t
    
    return Medicao(RM(I, U), v)
end

function Base.:-(x::Medicao, y::Medicao)

    I = x.RM.I - y.RM.I
    
    t₁ = student(x)
    t₂ = student(y)
    
    u₁ = x.RM.U/t₁
    u₂ = y.RM.U/t₂
    
    if u₁ > u₂
        r = u₂/u₁
        u = u₁ * √(1 + r^2)
    else
        r = u₁/u₂
        u = u₂ * √(1 + r^2)
    end
    
    v = trunc(u^4/(u₁^4/x.v + u₂^4/y.v))
    t = student(v)
    U = u * t
    
    return Medicao(RM(I, U), v)
end

function Base.:*(x::Medicao, y::Medicao)

    I₁ = x.RM.I
    I₂ = y.RM.I
    I = I₁ * I₂
    
    t₁ = student(x)
    t₂ = student(y)
    
    u₁ = (x.RM.U/t₁)
    u₂ = (y.RM.U/t₂)
    
    ur₁ = u₁/I₁
    ur₂ = u₂/I₂
    
    if ur₁ > ur₂
        r = ur₂/ur₁
        u = I * ur₁ * √(1 + r^2)
    else
        r = ur₁/ur₂
        u = I * ur₂ * √(1 + r^2)
    end
    
    ur = u/I
    v = trunc(ur^4/(ur₁^4/x.v + ur₂^4/y.v))
    t = student(v)
    U = u * t
    
    return Medicao(RM(I, U), v)
end

function Base.:/(x::Medicao, y::Medicao)

    I₁ = x.RM.I
    I₂ = y.RM.I
    I = I₁ / I₂
    
    t₁ = student(x)
    t₂ = student(y)
    
    u₁ = (x.RM.U/t₁)
    u₂ = (y.RM.U/t₂)
    
    ur₁ = u₁/I₁
    ur₂ = u₂/I₂
    
    if ur₁ > ur₂
        r = ur₂/ur₁
        u = I * ur₁ * √(1 + r^2)
    else
        r = ur₁/ur₂
        u = I * ur₂ * √(1 + r^2)
    end
    
    ur = u/I
    v = trunc(ur^4/(ur₁^4/x.v + ur₂^4/y.v))
    t = student(v)
    U = u * t
    
    return Medicao(RM(I, U), v)
end

function Base.:*(x::Medicao, y::Real)
    I = x.RM.I * y
    U = x.RM.U * y
    return Medicao(RM(I, U), x.v)
end

function Base.:*(x::Real, y::Medicao)
    I = y.RM.I * x
    U = y.RM.U * x
    return Medicao(RM(I, U), y.v)
end

function Base.:/(x::Medicao, y::Real)
    I = x.RM.I / y
    U = x.RM.U / y
    return Medicao(RM(I, U), x.v)
end

function Base.:^(x::Medicao, y::Real)

    Iₓ = x.RM.I
    t = student(x)
    uₓ = x.RM.U / t
    
    I = Iₓ^y
    u = I * √(y^2 * (uₓ/Iₓ)^2)
    U = u * t
    
    return Medicao(RM(I, U), x.v)
end