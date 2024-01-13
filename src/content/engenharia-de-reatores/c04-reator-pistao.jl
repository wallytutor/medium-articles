### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ dc471220-61ee-11ee-0281-f991a063e50c
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.resolve()
    Pkg.instantiate()

    using CairoMakie
    using Interpolations
    using Printf
    using Roots
    using SparseArrays: spdiagm
    using SteamTables
    import PlutoUI

    include("util-reator-pistao.jl")
    toc = PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ db0cf709-c127-42e0-9e3d-6e988a1e659d
md"""
# Reator pistão - Parte 4

$(toc)
"""

# ╔═╡ 451f21a0-22ae-452f-937c-01f6617209ea
let
    P = 0.1 * 270.0
    T = collect(300.0:5:1200.0)
    ρ = map((t)->1.0 / SpecificV(P, t), T)

    let
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        lines!(ax, T, ρ)
        ax.xlabel = "Temperatura [K]"
        ax.ylabel = "Mass específica [kg/m³]"
        ax.xticks = 300:100:1200
        ax.yticks = 000:200:1000
        xlims!(ax, (300, 1200))
        ylims!(ax, (000, 1000))
        fig
    end
end

# ╔═╡ 14dfac23-a63c-4715-9e39-105bd7c8c325
let
    P = 27.0
    T = collect(300.0:5.0:2000.0)
    h = map((t)->SpecificH(P, t), T)
    h_interp = linear_interpolation(T, h)

    let
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        lines!(ax, T, h)
        lines!(ax, T, h_interp(T))
        ax.xlabel = "Temperatura [K]"
        ax.ylabel = "Entalpia específica [kJ/kg]"
        ax.xticks = 300:100:1200
        ax.yticks = 000:500:4500
        xlims!(ax, (300, 1200))
        ylims!(ax, (000, 4500))
        fig
    end
end

# ╔═╡ 763992dd-0ab7-422e-8983-a398725326e7
"Integra reator pistão circular no espaço das entalpias."
function solveenthalpypfr(; mesh::AbstractDomainFVM, P::T, A::T, Tₛ::T, Tₚ::T,
                            ĥ::T, u::T, ρ::T, h::Function, M::Int64 = 100,
                            α::Float64 = 0.4, ε::Float64 = 1.0e-10,
                            alg::Any = Order16(), vars...) where T
    N = length(mesh.z) - 1

    Tm = Tₚ * ones(N + 1)
    hm = h.(Tm)

    a = (ĥ * P * mesh.δ) / (ρ * u * A)
    K = 2spdiagm(-1 => -ones(N-1), 0 => ones(N))

    b = (2a * Tₛ) * ones(N)
    b[1] += 2h(Tₚ)

    residual = -ones(M)

    @time for niter in 1:M
        Δ = (1-α) * (K\(b - a * (Tm[1:end-1] + Tm[2:end])) - hm[2:end])
        hm[2:end] += Δ

        Tm[2:end] = map(
            (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ, alg, atol=0.1),
            Tm[2:end], hm[2:end]
        )

        residual[niter] = maximum(abs.(Δ))

        if (residual[niter] <= ε)
            @info("Convergiu após $(niter) iterações")
            break
        end
    end

    return Tm, residual
end

# ╔═╡ f2f7bae5-3bcc-426b-9c29-2d4b96abbf74
let
    L = 3.0
    mesh = ImmersedConditionsFVM(; L = L, N = 3000)

    D = 0.0254 / 2
    P = π * D
    A = π * D^2 / 4

    Tₛ = 873.15
    ṁ = 60.0 / 3600.0

    Pₚ = 27.0
    Tₚ = 300.0
    ρₚ = 1.0 / SpecificV(Pₚ, Tₚ)
    uₚ = ṁ / (ρₚ * A)

    h_interp = let
        T = collect(300.0:5.0:2000.0)
        h = map((t)->SpecificH(Pₚ, t), T)
        linear_interpolation(T, h)
    end

    z = mesh.z
    ĥ = 4000.0

    # TODO search literature for supercritical!
    # ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    h(t) = 1000h_interp(t)

    pars = (
        mesh = mesh,
        P = P,
        A = A,
        Tₛ = Tₛ,
        Tₚ = Tₚ,
        ĥ = ĥ,
        u = uₚ,
        ρ = ρₚ,
        h = h,
        M = 1000,
        α = 0.85,
        ε = 1.0e-06,
        alg = Order16()
    )

    T, residuals = solveenthalpypfr(; pars...)

    fig1 = let
        yrng = (300.0, 900.0)

        Tend = @sprintf("%.2f", T[end])
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        stairs!(ax, z, T,
                color = :red, linewidth = 2,
                label = "Numérica", step = :center)
        xlims!(ax, (0, L))
        ax.title = "Temperatura final = $(Tend) K"
        ax.xlabel = "Posição [m]"
        ax.ylabel = "Temperatura [K]"
        ax.xticks = range(0.0, L, 5)
        ax.yticks = range(yrng..., 7)
        ylims!(ax, yrng)
        axislegend(position = :rb)
        fig
    end
end

# ╔═╡ daab21e0-e9f8-4b75-b335-785553a0e064
md"""
## Pacotes
"""

# ╔═╡ Cell order:
# ╟─db0cf709-c127-42e0-9e3d-6e988a1e659d
# ╟─451f21a0-22ae-452f-937c-01f6617209ea
# ╟─14dfac23-a63c-4715-9e39-105bd7c8c325
# ╟─763992dd-0ab7-422e-8983-a398725326e7
# ╟─f2f7bae5-3bcc-426b-9c29-2d4b96abbf74
# ╟─daab21e0-e9f8-4b75-b335-785553a0e064
# ╟─dc471220-61ee-11ee-0281-f991a063e50c
