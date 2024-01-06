---
title  : Transient heat transfer
author : Walter Dal'Maz Silva
date   : `j import Dates; Dates.Date(Dates.now())`
weave_options:
  error: false
  term: false
  wrap: true
  line_width: 100
---

```julia; echo = false; results = "hidden"
include(joinpath(@__DIR__(), "shared.jl"))
```

# First problem

Implementation of setion 2.3 of Nithiarasu *et al.* (2016)...

```julia
V = (4/3)*π * ([0.05, 0.20, 0.30]).^3
V = [V[1], (V[2:3] .- V[1:2])...]
m = 1u"kg" * ([7890, 1.0, 3000] .* V)

println(m)
# Note since the system is lumped the following units apply:
cp(T) = m[1] * 6.00e+03u"J/(kg*K)"
cg(T) = m[2] * 1.00e+03u"J/(kg*K)"
cw(T) = m[3] * 9.00e+02u"J/(kg*K)"

specificheat(T) = [cp(T[1]); cg(T[2]); cw(T[3])]
inertiainv(T) = diagm(1 ./ specificheat(T))

function stiffness(h, A)
    p = @. h * A
    q = -1 * p[1:end-1]
    p[2:end] -= q
    return diagm(0=>p, -1=>q, 1=>q)
end

function forcing(T, h, A, Ta, ϵp, ϵw)
    f1 = -ϵp*σ*A[1]*(T[1]^4-T[3]^4)
    f3 = h[3]*A[3]*Ta - f1 - ϵw*σ*A[3]*(T[3]^4 - Ta^4)
    return [ f1; 0u"W"; f3 ]
end

function buildlhsmatrix(τ, h, A)
    K = stiffness(h, A)
    I = diagm([1, 1, 1] * 1u"1") # kg in fact!

    function getlhsmatrix(Tₖ)
        return I + τ * inertiainv(Tₖ) * K
    end
end

function buildrhsvector(τ, h, A, Ta, ϵp, ϵw)
    F(T) = τ * forcing(T, h, A, Ta, ϵp, ϵw)

    function getrhsvector(Tₖ)
        return inertiainv(Tₖ) * F(Tₖ)
    end
end

function relaxation(Tᵢ, Tⱼ, β)
    return @. β * Tⱼ + (1-β) * Tᵢ
end

function residual(Tᵢ, Tⱼ)
    # TODO instead return all to allow better debugging
    # It should be the test that verify that all < tol!
    return maximum(abs.(Tⱼ .- Tᵢ) ./ Tᵢ)
end

function steptime(T₀, K, B; maxiter = 50, rtol = 1.0e-12, β = 1.0)
    Tᵢ = copy(T₀)
    Tⱼ = copy(T₀)
    Δ = 9.0e+100

    for j in range(1, maxiter)
        # TODO with units this does not work!
        # Tⱼ[:] = K(Tⱼ) \ (B(Tⱼ) .+ T₀)
        Tⱼ[:] = inv(K(Tⱼ)) * (B(Tⱼ) .+ T₀)

        Tⱼ[:] = relaxation(Tᵢ, Tⱼ, β)
        Δ = residual(Tᵢ, Tⱼ)
        Tᵢ[:] = Tⱼ[:]

        if Δ < rtol
            # @info("Converged on iteration $(j) @ $(@sprintf("%.6e", Δ))")
            return Tᵢ, j, Δ
        end
    end

    @warn("No convergence during step @ $(@sprintf("%.6e", Δ))")
    return Tᵢ, maxiter, Δ
end

function integrate(t, T, K, B; maxiter, rtol, β)
    U = copy(T)
    nvars = length(T)
    solution = zeros(length(t), nvars + 2)
    solution[1, 1:nvars] = ustrip(U)

    for (i, tᵢ) in enumerate(t[1:end])
        (U[:], niters, Δ) = steptime(U, K, B; maxiter, rtol, β)
        solution[i, 1:nvars] = ustrip(U)
        solution[i, nvars+1] = niters
        solution[i, nvars+2] = Δ
    end

    return solution
end

h = [10.0, 10.0, 10.0] * 1u"W/(m^2*K)"
A = [1.0, 2.0, 4.0] * 1u"m^2"

ϵp = 0.8
ϵw = 0.3
Ta = 313.15u"K"

tend =  7200

T = [1273.0, 298.15, 298.15] * 1u"K"
t = range(0, tend, convert(Int64, tend / 2))
τ = step(t) * 1u"s"

K = buildlhsmatrix(τ, h, A)
B = buildrhsvector(τ, h, A, Ta, ϵp, ϵw)

maxiter = 80
rtol = 1.0e-12
β = 0.85

@time solution = integrate(t, T, K, B; maxiter, rtol, β);

fig = let
    fig = Figure(size = (700, 500))
    ax = Axis(fig[1, 1])
    lines!(ax, t, solution[:, 1]; color = :black, label = "Metal")
    lines!(ax, t, solution[:, 2]; color = :green, label = "Gas")
    lines!(ax, t, solution[:, 3]; color = :red,   label = "Wall")
    hlines!(ax, ustrip(Ta); color = :blue, label = "Environment")
    axislegend(ax; position = :rt)
    ax.xlabel = "Time [s]"
    ax.ylabel = "Temperature [K]"
    ax.xticks = 0:600:tend
    ax.yticks = 300:200:1300
    xlims!(ax, extrema(ax.xticks.val))
    ylims!(ax, extrema(ax.yticks.val))

    ax = Axis(fig[2, 1])
    lines!(ax, t, solution[:, 5]; color = :black)

    fig
end

# C = specificheat(T)
# K = stiffness(h, A)
# f = forcing(T, h, A, Ta, ϵp, ϵw)

# TODO make the same thing with ModelingToolkit!

```