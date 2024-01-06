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

Implementation of section 2.3 of Nithiarasu *et al.* (2016) of a transient heat transfer problem. This is the logical extension of what has been explored in a previous [study](./01-Composite-Conduction.md). The overall problem is stated in terms of the inertia matrix $\mathbf{C}$, the stiffness $\mathbf{K}$ and the forcing function $\mathbf{f}$. The following first order differential equation of temperature $\mathcal{T}$ is to be solved:

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

Since our goal is to make the problem fully treated in matrix form, we stack the specific heats together. Since matrix $\mathrm{C}$ is diagonal and composed by these specific heats, its inverse is simply the reciprocal of its diagonal elements, what is trivial to prove. This allows the problem to be reworked as

$$
\dot{\mathcal{T}}+\mathbf{C}^{-1}\mathbf{K}\mathcal{T}=\mathbf{C}^{-1}\mathbf{f}
$$
Setting the derivative term to be alone could be interesting for testing different time-stepping strategies, for instance. Matrix $\mathrm{C}^{-1}$ is provided by `inertiainv` below:

```julia; results = "hidden"
specificheat(T) = [cp(T[1]); cg(T[2]); cw(T[3])]

inertiainv(T) = diagm(1 ./ specificheat(T))
```

We inspect the inverse inertia matrix:

```julia
inertiainv([300.0, 300.0, 300.0])
```

Stiffness matrix $\mathrm{K}$ in this problem provides the convective heat transfer terms. It is given by

$$
\mathbf{K} = \begin{bmatrix}
h_pA_p  & -h_pA_p         & 0\\
-h_pA_p & h_pA_p + h_gA_g & -h_gA_g\\
0       & -h_gA_g         & h_gA_g + h_wA_w
\end{bmatrix}
$$

Since this matrix does not contain any element that depends on temperature it needs to be computed only once and we will not seek an optimized way to evaluate it. The code below is generic for any *layered* structure as the one being modelled here. Notice that the pairwise interactions lead to a tridiagonal structure.

```julia; results = "hidden"
function stiffness(h, A)
    p = @. h * A
    q = -1 * p[1:end-1]
    p[2:end] -= q
    return diagm(0=>p, -1=>q, 1=>q)
end
```

For testing its implementation and later simulating the system we provide already the set of convective heat transfer coefficients on `h` and heat transfer areas in `A`. The order of magnitude of areas was kept compatible with the geometrical description provided before.

```julia
h = [100.0, 100.0, 10.0] * 1u"W/(m^2*K)"
A = [0.032, 0.500, 1.15] * 1u"m^2"

stiffness(h, A)
```


```julia; results = "hidden"
function forcing(T, h, A, Ta, ϵp, ϵw)
    f1 = -ϵp*σ*A[1]*(T[1]^4-T[3]^4)
    f3 = h[3]*A[3]*Ta - f1 - ϵw*σ*A[3]*(T[3]^4 - Ta^4)
    return [ f1; 0u"W"; f3 ]
end
```

```julia; results = "hidden"
function buildlhsmatrix(τ, h, A)
    K = stiffness(h, A)
    I = diagm([1, 1, 1] * 1u"1")
    return (Tₖ) -> I + τ * inertiainv(Tₖ) * K
end
```

```julia; results = "hidden"
function buildrhsvector(τ, h, A, Ta, ϵp, ϵw)
    F(T) = τ * forcing(T, h, A, Ta, ϵp, ϵw)
    return (Tₖ) -> inertiainv(Tₖ) * F(Tₖ)
end
```

```julia; results = "hidden"
function relaxation(Tᵢ, Tⱼ, β)
    return @. β * Tⱼ + (1-β) * Tᵢ
end
```

```julia; results = "hidden"
function residual(Tᵢ, Tⱼ)
    # TODO instead return all to allow better debugging
    # It should be the test that verify that all < tol!
    return maximum(abs.(Tⱼ .- Tᵢ) ./ Tᵢ)
end
```

```julia; results = "hidden"
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
```

```julia; results = "hidden"
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
```


```julia; results = "hidden"
```

```julia
ϵp = 0.8
ϵw = 0.3
Ta = 313.15u"K"

tend =  7200

T = [1273.0u"K", Ta, Ta]
t = range(0, tend, convert(Int64, tend / 2))
τ = step(t) * 1u"s"

K = buildlhsmatrix(τ, h, A)
B = buildrhsvector(τ, h, A, Ta, ϵp, ϵw)

maxiter = 80
rtol = 1.0e-12
β = 0.85

@time solution = integrate(t, T, K, B; maxiter, rtol, β);
```

```julia; echo = false
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
```

## Using `ModelingToolkit`