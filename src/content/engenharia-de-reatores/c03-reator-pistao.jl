### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ fe2c3680-5b91-11ee-282c-c74d3b01ef9b
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.resolve()
    Pkg.instantiate()

    using CairoMakie
    using DocStringExtensions
    using Polynomials
    using Printf
    using Roots
    using SparseArrays: spdiagm
    using SparseArrays: SparseMatrixCSC
    import PlutoUI

    include("util-reator-pistao.jl")
    toc = PlutoUI.TableOfContents(title = "Tópicos")
end;

# ╔═╡ f33f5453-dd05-4a4e-ae12-695320fcd70d
md"""
# Reator pistão - Parte 3

As ideias gerais para a simulação de um reator formulado na entalpia tendo sido introduzidas na *Parte 2*, vamos agora aplicar o mesmo algoritmo de solução para um problema menos trivial: integração de reatores em contra-corrente com trocas térmicas. Esse é o caso, por exemplo, em uma serpentina dupla em contato mecânico. Esse sistema pode ser aproximado por um par de reatores pistão em contra-corrente se tomada propriamente em conta a resistência térmica dos dutos.

Outro caso clássico que pode ser as vezes tratado desta forma é o modelo de forno rotativo para produção de cimento, como discutido por [Hanein *et al.* (2017)](https://doi.org/10.1080/17436753.2017.1303261). Outro exemplo é fornecido por [Bulfin (2019)](https://doi.org/10.1039/C8CP07077F) para a síntese de ceria. [Kerkhof (2007)](https://doi.org/10.1016/j.ces.2006.12.047) apresenta uma abordagem mais geral introduzindo troca de massa entre partículas.

Ainda precisamos tratar de tópicos mais básicos antes de implementar modelos similares ao longo dessa série, mas espero que a literatura citada sirva como motivação para o estudo.

Neste notebook trataremos dois casos: (I)... TODO

$(toc)
"""

# ╔═╡ 67b0a6ab-c128-4ab6-b588-c2322b0e61e9
md"""
## Reatores em contra corrente

No que se segue não se fará hipótese de que ambos os escoamentos se dão com o mesmo fluido ou que no caso de mesmo fluido as velocidades são comparáveis. Neste caso mais geral, o número de Nusselt de cada lado da interface difere e portanto o coeficiente de troca térmica convectiva. É portanto necessário estabelecer-se uma condição de fluxo constante na interface das malhas para assegurar a conservação global da energia no sistema... TODO (escrever, já programado)
"""

# ╔═╡ f3b7d46f-0fcc-4f68-9822-f83e977b87ee
md"""
## Estudo de caso II
"""

# ╔═╡ 975744de-7ab0-4bfa-abe5-3741ec7ec1cf
md"""
## Anexos
"""

# ╔═╡ 04cf5b92-d10b-43f5-8fc5-1e549105ef9d
md"""
### Dados
"""

# ╔═╡ dcfd8b59-429f-4c99-9eae-1aa34fa87033
const reactor = notedata.c03.reactor

# ╔═╡ 9f94f21d-2805-4b30-8451-7b09b575081c
const fluid1 = notedata.c03.fluid1

# ╔═╡ 2f088bd3-184d-41a3-9254-8fa458d8ccaf
const fluid3 = notedata.c03.fluid3

# ╔═╡ cc1a6701-8907-440a-a77b-b89ec6abac65
const operations1 = notedata.c03.operations1

# ╔═╡ f1cc566b-87bb-42be-a0a5-c160f326817f
const operations2 = notedata.c03.operations2

# ╔═╡ 7a278913-bf0f-4532-9c9b-f42aded9b6e9
md"""
## Estudo de caso I

O par escolhido para exemplificar o comportamento de contra-corrente dos reatores
pistão tem por característica de que cada reator ocupa a metade de um cilindro de diâmetro `D` = $(reactor.D) m de forma que o perímetro de troca é igual o diâmetro e a área transversal a metade daquela do cilindro. A temperatura inicial do fluido no reator (1) que escoa da esquerda para a direita é de $(operations1.Tₚ) K e naquele em contra-corrente (2) é de $(operations2.Tₚ) K.

O fluido do reator (2) tem um calor específico que é o triplo daquele do reator (1).
"""

# ╔═╡ 9a529019-9cfc-4018-a7ce-051e6dbdd85e
"Cria um par padronizado de reatores para simulação exemplo."
function createprfpair1(; N = 10)
    shared = (
        N = N,
        L = reactor.L,
        P = reactor.D,
        A = 0.5π * (reactor.D/2)^2,
        ρ = fluid1.ρ
    )

    ĥ₁ = computehtc(; reactor..., fluid1..., u = operations1.u, verbose = false)
    ĥ₂ = computehtc(; reactor..., fluid1..., u = operations2.u, verbose = false)

    r₁ = IncompressibleEnthalpyPFRModel(;
        shared...,
        T = operations1.Tₚ,
        u = operations1.u,
        ĥ = ĥ₁,
        h = (T) -> 1.0fluid1.cₚ * T + 1000.0
    )

    r₂ = IncompressibleEnthalpyPFRModel(;
        shared...,
        T = operations2.Tₚ,
        u = operations2.u,
        ĥ = ĥ₂,
        h = (T) -> 3.0fluid1.cₚ * T + 1000.0,
    )

    return r₁ , r₂
end

# ╔═╡ eecf85b0-180c-49c5-83ab-619ba6683960
const operations3 = notedata.c03.operations3

# ╔═╡ 7afff466-5463-431f-b817-083fe6102a8c
"Cria um par padronizado de reatores para simulação exemplo."
function createprfpair2(; N = 10)
    # Condições operatórias do gás.
    p₃ = 101325.0
    h₃ = integrate(fluid3.cₚpoly)
    M̄₃ = 0.02897530345830224

    fluid₃ = (
        ρ = (p₃ * M̄₃) / (GAS_CONSTANT * operations3.Tₚ),
        μ = fluid3.μpoly(operations3.Tₚ),
        cₚ = fluid3.cₚpoly(operations3.Tₚ),
        Pr = fluid3.Pr
    )

    # Condições modificadas do fluido condensado.
    operations₁ = (
        u = operations3.u * (fluid₃.ρ / fluid1.ρ),
        Tₚ = operations1.Tₚ
    )

    shared = (
        N = N,
        L = reactor.L,
        P = reactor.D,
        A = 0.5π * (reactor.D/2)^2,
        ρ = fluid1.ρ
    )

    ĥ₁ = computehtc(; reactor..., fluid1..., u = operations₁.u, verbose = false)
    ĥ₃ = computehtc(; reactor..., fluid₃..., u = operations3.u, verbose = false)

    r₁ = IncompressibleEnthalpyPFRModel(;
        shared...,
        T = operations₁.Tₚ,
        u = operations₁.u,
        ĥ = ĥ₁,
        h = (T) -> 1.0fluid1.cₚ * T + 1000.0
    )

    r₃ = IncompressibleEnthalpyPFRModel(;
        shared...,
        T = operations3.Tₚ,
        u = operations3.u,
        ĥ = ĥ₃,
        h = (T) -> h₃(T),
    )

    return r₁ , r₃
end

# ╔═╡ 2d296ee3-ed4b-422a-9573-d10bbbdce344
"Ilustração padronizada para a simulação exemplo."
function plotpfrpair(cf::CounterFlowPFRModel; ylims = (300, 400), loc = :rb)
    z1 = coordinates(cf)
    T1 = thistemperature(cf)
    T2 = thattemperature(cf)

    fig = Figure(resolution = (720, 500))
    ax = Axis(fig[1, 1])
    stairs!(ax, z1, T1, label = "r₁", color = :blue, step = :center)
    stairs!(ax, z1, T2, label = "r₂", color = :red, step = :center)
    ax.xticks = range(0.0, z1[end], 6)
    ax.yticks = range(ylims..., 6)
    ax.xlabel = "Posição [m]"
    ax.ylabel = "Temperatura [K]"
    xlims!(ax, (0, z1[end]))
    ylims!(ax, ylims)
    axislegend(position = loc)
    return fig
end

# ╔═╡ 2b667c73-1c05-48a5-a6e7-b7490ab5916c
"Gera grafico com resíduos da simulação"
function plotreactorresiduals(ra, rb)
    function getreactordata(r)
        xg = 1:r.counter
        xs = r.finalsteps
        yg = log10.(r.residuals)
        ys = log10.(r.finalresiduals)
        return xg, xs, yg, ys
    end

    function axlimitmax(niter)
        rounder = 10^floor(log10(niter))
        return convert(Int64, rounder * ceil(niter/rounder))
    end

    niter = max(ra.counter, rb.counter)
    xga, xsa, yga, ysa = getreactordata(ra)
    xgb, xsb, ygb, ysb = getreactordata(rb)

    fig = Figure(resolution = (720, 500))
    ax = Axis(fig[1, 1], yscale = identity)

    ax.xlabel = "Iteração global"
    ax.ylabel = "log10(Resíduo)"
    ax.title = "Histórico de convergência"

    ax.yticks = -12:2:0
    xlims!(ax, (0, axlimitmax(niter)))
    ylims!(ax, (-12, 0))

    lines!(ax, xga, yga, color = :blue,  linewidth = 0.9, label = "r₁")
    lines!(ax, xgb, ygb, color = :red, linewidth = 0.9, label = "r₂")

    scatter!(ax, xsa, ysa, color = :black, markersize = 6)
    scatter!(ax, xsb, ysb, color = :black, markersize = 6)

    axislegend(position = :rt)
    return fig
end

# ╔═╡ b1ccbbf0-cded-4831-8ecf-4b5534ae9fa4
figs1 = let
    r₁, r₂ = createprfpair1(; N = 1000)
    cf = CounterFlowPFRModel(r₁, r₂)

    resa, resb = outerloop(cf;
        inner = 30,
        outer = 100,
        relax = 0.0,
        Δhmax = 1.0e-10,
        rtol  = 1.0e-10
    )

    fig1 = plotpfrpair(cf)
    fig2 = plotreactorresiduals(resa, resb)
    fig1, fig2
end;

# ╔═╡ 2b57fee2-97cf-4f69-b1d4-b4e20065a07b
figs1[1]

# ╔═╡ bdf4c11d-92e0-493b-b163-c3e5e52789ea
figs1[2]

# ╔═╡ 9f1357f1-1e7b-4f55-9f4b-cc6a1fd3e2aa
figs2 = let
    r₁, r₂ = createprfpair2(; N = 1000)
    cf = CounterFlowPFRModel(r₁, r₂)

    resa, resb = outerloop(cf;
        inner = 100,
        outer = 200,
        relax = 0.6,
        Δhmax = 1.0e-10,
        rtol  = 1.0e-10
    )

    fig1 = plotpfrpair(cf, ylims = (300, 400))
    fig2 = plotreactorresiduals(resa, resb)
    fig1, fig2
end;

# ╔═╡ 509da475-fa3e-4f86-84f0-8ebca1088532
figs2[1]

# ╔═╡ 486add22-bf9b-49ea-99d7-b61b961e2791
figs2[2]

# ╔═╡ 54aa6060-a605-4a05-83f1-2b672f1d148f
md"""
### Pacotes
"""

# ╔═╡ Cell order:
# ╟─f33f5453-dd05-4a4e-ae12-695320fcd70d
# ╟─67b0a6ab-c128-4ab6-b588-c2322b0e61e9
# ╟─7a278913-bf0f-4532-9c9b-f42aded9b6e9
# ╟─9a529019-9cfc-4018-a7ce-051e6dbdd85e
# ╟─2b57fee2-97cf-4f69-b1d4-b4e20065a07b
# ╟─bdf4c11d-92e0-493b-b163-c3e5e52789ea
# ╟─b1ccbbf0-cded-4831-8ecf-4b5534ae9fa4
# ╟─f3b7d46f-0fcc-4f68-9822-f83e977b87ee
# ╟─7afff466-5463-431f-b817-083fe6102a8c
# ╟─509da475-fa3e-4f86-84f0-8ebca1088532
# ╟─486add22-bf9b-49ea-99d7-b61b961e2791
# ╟─9f1357f1-1e7b-4f55-9f4b-cc6a1fd3e2aa
# ╟─975744de-7ab0-4bfa-abe5-3741ec7ec1cf
# ╟─04cf5b92-d10b-43f5-8fc5-1e549105ef9d
# ╟─dcfd8b59-429f-4c99-9eae-1aa34fa87033
# ╟─9f94f21d-2805-4b30-8451-7b09b575081c
# ╟─2f088bd3-184d-41a3-9254-8fa458d8ccaf
# ╟─cc1a6701-8907-440a-a77b-b89ec6abac65
# ╟─f1cc566b-87bb-42be-a0a5-c160f326817f
# ╟─eecf85b0-180c-49c5-83ab-619ba6683960
# ╟─2d296ee3-ed4b-422a-9573-d10bbbdce344
# ╟─2b667c73-1c05-48a5-a6e7-b7490ab5916c
# ╟─54aa6060-a605-4a05-83f1-2b672f1d148f
# ╟─fe2c3680-5b91-11ee-282c-c74d3b01ef9b
