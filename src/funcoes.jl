incert(; u::Real, t::Real) = u*t

incert(U::NamedTuple) = incert(;U...)


student(v::Union{Int, Float64}, prob::Float64 = 0.9545) = quantile(TDist(v), 1 - (1-prob)/2)

student(med::Medicao, prob::Float64 = 0.9545) = quantile(TDist(med.v), 1 - (1-prob)/2)


function medinvar(I::Vector; C::Real = 0, prob::Float64 = 0.9545) 
	
	I̅ = mean(I)
	n = length(I)
	v = n - 1
	u = std(I)
	U = u*student(v, prob)
	
	return Medicao(RM(I̅ + C, U/√n), v)
end

# add exemplo com NamedTuple na documentacao para justificar a arquitetura da funcao
function medinvar(I::Real, U::Union{Real, NamedTuple}; n::Int = 1, C::Real = 0)
	
	if U isa NamedTuple
		Uᵥ = incert(U)
		
		n == 1 && return RM(I + C, Uᵥ)
		
		v = n - 1
		return Medicao(RM(I + C, Uᵥ/√n), v)
	end
	
	n == 1 && return RM(I + C, U)
	
	v = n - 1
	return Medicao(RM(I + C, U/√n), v)
end


function medinvar_emax(I::Vector, Emax::Real)
	I̅ = mean(I)
	v = length(I) - 1
	return Medicao(RM(I̅, Emax), v)
end

medinvar_emax(I::Real, Emax::Real) = RM(I, Emax)


function medvar(I::Vector; C::Real = 0, prob::Float64 = 0.9545)
	
	I̅ = mean(I)
	v = length(I) - 1
	u = std(I)
	t = student(v, prob)
	U = u*t
	
	return Medicao(RM(I̅ + C, U), v)
end

function medvar(I̅::Real, U::Union{Real, NamedTuple};
		n::Union{Int, Float64} = Inf, C::Real = 0)
	
	v = n - 1
	
	if U isa NamedTuple
		Uᵥ = incert(U)
		return Medicao(RM(I̅ + C, Uᵥ), v)
	end
	
	return Medicao(RM(I̅ + C, U), v)
end		


function medvar_emax(I::Vector, Emax::Real; prob::Float64 = 0.9545)
	
	I̅ = mean(I)
	v = length(I) - 1
	u = std(I)
	t = student(v, prob)
	U = u*t
	
	return Medicao(RM(I̅, U + Emax), v)
end

function medvar_emax(I̅::Real, U::Union{Real, NamedTuple}, Emax::Real;
		n::Union{Int, Float64} = Inf)
	
	v = n - 1
	
	if U isa NamedTuple
		Uᵥ = incert(U)
		return Medicao(RM(I̅, Uᵥ + Emax), v)
	end
	
	return Medicao(RM(I̅, U + Emax), v)
end		


function Base.:+(x::Medicao, y::Medicao)
	
	I = x.RM.I + y.RM.I
	
	t₁ = student(x)
	t₂ = student(y)
	
	u₁ = x.RM.U/t₁
	u₂ = y.RM.U/t₂
	
	if u₁ > u₂
		r = u₂/u₁
		u = u₁*√(1 + r^2)
	else
		r = u₁/u₂
		u = u₂*√(1 + r^2)
	end
	
	v = trunc(u^4/(u₁^4/x.v + u₂^4/y.v))
	t = student(v)
	U = u*t
	
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
		u = u₁*√(1 + r^2)
	else
		r = u₁/u₂
		u = u₂*√(1 + r^2)
	end
	
	v = trunc(u^4/(u₁^4/x.v + u₂^4/y.v))
	t = student(v)
	U = u*t
	
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
	U = u*t
	
	return Medicao(RM(I, U), x.v)
end