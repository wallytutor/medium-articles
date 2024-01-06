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

Implementation of setion 2.3 of Nithiarasu *et al.* (2016) of a transient heat transfer problem. This is the logical extension of what has been explored in a previous [study](./01-Composite-Conduction.md). The overall problem is stated in terms of the inertia matrix $\mathbf{C}$, the stiffness $\mathbf{K}$ and the forcing function $\mathbf{f}$. The following first order differential equation of temperature $\mathcal{T}$ is to be solved:

$$
\mathbf{C}\dot{\mathcal{T}}+\mathbf{K}\mathcal{T}=\mathbf{f}
$$

Notice here that the temperature $\mathcal{T}$ here is a vector corresponding to the three problem components, the steel part, the furnace gas, and the outer refractory walls.

Because the model is stated in lumped form, *i.e.* simplified to a zero-dimensional space, we add a phase of calculation of the *heat capacities* of materials in compatible units to remain within the formulation proposed in the reference. In this lumped format, the elements of matrix $\mathbf{C}$ are given in units of energy per unit temperature because they already incorporate the effect bodies masses through $C_{i,i}=m_i{}c_{P,i}$ where $i$ indicates de component index.

To get a dynamics that is interpretable in the real world we will start by computing reasonable orders of magnitude of the $C_{i,i}$ by providing the masses of the bodies and typical values of specific heats for the involved materials. Considering a steel sphere of 10 cm placed **floating** in a 40 cm air environment limited by a spherical refractory with outer shell of 60 cm we can estimate these masses, in the same order, as:

```julia; results = "hidden"
m = 1u"kg" * [4.2, 0.033, 240.0]
```

Next we provide the specific heats of the materials already multiplied by the above masses:

```julia; results = "hidden"
cp(T) = m[1] * 6.00e+03u"J/(kg*K)"
cg(T) = m[2] * 1.00e+03u"J/(kg*K)"
cw(T) = m[3] * 9.00e+02u"J/(kg*K)"
```

Since our goal is to make the problem fully treated in matrix form, we stack the specific heats together.

```julia; results = "hidden"
specificheat(T) = [cp(T[1]); cg(T[2]); cw(T[3])]
inertiainv(T) = diagm(1 ./ specificheat(T))
```

```julia
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