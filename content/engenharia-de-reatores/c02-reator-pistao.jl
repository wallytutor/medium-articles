### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ ea183591-cc73-44cc-b1d0-572cf24d5b6b
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.resolve()
    Pkg.instantiate()

    using CairoMakie
    using Printf
    using Roots
    using SparseArrays: spdiagm
    import PlutoUI

    include("util-reator-pistao.jl")
    toc = PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ 0c42a060-5cf5-11ee-273c-b16c31ed2b48
md"""
# Reator pistão - Parte 2

Neste notebook damos continuidade ao precedente através da extensão do modelo para a resolução da conservação de energia empregando a entalpia do fluido como variável independente. O caso tratado será o mesmo da *Parte 1* para que possamos ter uma base de comparação da solução.

$(toc)
"""

# ╔═╡ eaed30cf-e984-4ae6-8eb8-43ba533c23ee
md"""
## Modelo na entalpia

Em diversos casos a forma expressa na temperatura não é conveniente. Esse geralmente é o caso quando se inclui transformações de fase no sistema. Nessas situações a solução não suporta integração direta e devemos recorrer a um método iterativo baseado na entalpia. Isso se dá pela adição de uma etapa suplementar da solução de equações não lineares para se encontrar a temperatura à qual a entalpia corresponde para se poder avaliar as trocas térmicas.

Para se efetuar a integração partimos do modelo derivado anteriormente numa etapa antes da simplificação final para solução na temperatura e já agrupamos os parâmetros livres em ``a``

```math
\frac{dh}{dz}=\frac{\hat{h}P}{\rho{}u{}A_{c}}(T_{s}-T^{\star})=a(T_{s}-T^{\star})
```

É interessante observar que toda a discussão precedente acerca de porque não integrar sobre ``T^{\star}`` perde seu sentido aqui: a temperatura é claramente um parâmetro.

```math
\int_{h_P}^{h_N}dh=a^{\prime}\int_{0}^{\delta}(T_{s}-T^{\star})dz
```

Seguindo um procedimento de integração similar ao aplicado na formulação usando a temperatura chegamos a equação do gradiente fazendo ``a=a^{\prime}\delta``

```math
h_{E}-h_{P}=aT_{s}-aT^{\star}
```

Seguindo a mesma lógica discutida na formulação na temperatura, introduzimos a relação de interpolação ``T^{\star}=(1/2)(T_{E}+T_{P})`` e aplicando-se esta expressão na forma numérica final, após manipulação chega-se à

```math
-2h_{P}+2h_{E}=2aT_{s}-aT_{E}-aT_{P}
```

Essa expressão permite a solução da entalpia e a atualização do campo de temperaturas se faz através da solução de uma equação não linear do tipo ``h(T_{P})-h_{P}=0`` por célula.

Substituindo a temperatura inicial ``T_{0}`` e sua entalpia associada ``h_{0}`` na forma algébrica do problema encontramos a primeira linha da matriz que explicita as modificações para se implementar a condição inicial do problema

```math
2h_{1}=2aT_{s}-aT_{1}-aT_{0}-2h_{0}
```

Completamos assim as derivações para se escrever a forma matricial

```math
\begin{bmatrix}
 2      &  0     &  0     & \dots  &  0      &  0      \\
-2      &  2     &  0     & \dots  &  0      &  0      \\
 0      & -2     &  2     & \ddots &  0      &  0      \\
\vdots  & \ddots & \ddots & \ddots & \ddots  & \vdots  \\
 0      &  0     &  0     & -2     &  2      &  0     \\
 0      &  0     &  0     &  0     & -2      &  2 \\
\end{bmatrix}
\begin{bmatrix}
h_{1}    \\
h_{2}    \\
h_{3}    \\
\vdots   \\
h_{N-1}  \\
h_{N}    \\
\end{bmatrix}
=
\begin{bmatrix}
f_{0,1} + 2h(T_{0}) \\
f_{1,2}     \\
f_{2,3}      \\
\vdots                       \\
f_{N-2,N-1}  \\
f_{N-1,N}    \\
\end{bmatrix}
```

No vetor do lado direito introduzimos uma função de ``f`` dada por

```math
f_{i,j} = 2aT_{s} - a(T_{i}+T_{j})
```
"""

# ╔═╡ da2429b7-5dd5-44f4-a5ec-d60b69100fb6
md"""
## Solução em volumes finitos

Como as temperaturas usadas no lado direito da equação não são conhecidas inicialmente, o problema tem um carater iterativo intrínsico. Initializamos o lado direito da equação para em seguida resolver o problema na entalpia, que deve ser invertida (equações não lineares) para se atualizar as temperaturas. Isso se repete até que a solução entre duas iterações consecutivas atinja um *critério de convergência*.

Como a estimativa inicial do campo de temperaturas pode ser extremamente ruim, usamos um método com relaxações consecutivas da solução no caminho da convergência. A ideia de base é evitar atualizações bruscas que podem gerar temperaturas negativas ou simplesmente divergir para o infinito. A cada passo, partindo das temperaturas ``T^{(m)}``, aonde ``m`` é o índice da iteração, resolvemos o sistema não-linear para encontrar ``T^{(m+1)^\prime}``. Pelas razões citadas, não é razoável utilizar essa solução diretamente, portanto realizamos a ponderação, dita relaxação, que se segue

```math
T^{(m+1)}=(1-\alpha)T^{(m+1)^\prime}+αT^{(m)}
```

Como critério de parada do cálculo, o que chamamos convergência, queremos que a máxima *atualização* ``\Delta{}T`` do campo de temperaturas seja menor que um critério ``\varepsilon``, ou seja

```math
\max\vert{}T^{(m+1)}-T^{(m)}{}\vert=\max\vert{}\Delta{}T{}\vert<\varepsilon
```

Para evitar cálculos separados da nova temperatura e então da variação, podemos usar as definições acima para chegar à

```math
\Delta{}T{} = (1-\alpha)(T^{(m+1)^\prime}-T^{(m)})
```

e então atualizar a solução com ``T^{(m+1)}+T^{(m)}+\Delta{}T{}``.

A solução integrando esses passos foi implementada em `solventhalpypfr`.
"""

# ╔═╡ 548a5654-47bf-42d4-bfb6-38e1c2860c32
"Integra reator pistão circular no espaço das entalpias."
function solveenthalpypfr(; mesh::AbstractDomainFVM, P::T, A::T,
                            Tₛ::T, Tₚ::T, ĥ::T, u::T, ρ::T, h::Function,
                            M::Int64 = 100, α::Float64 = 0.4, ε::Float64 = 1.0e-10,
                            relax::Symbol = :h, vars...) where T
    @info "Resolvendo o problema com relaxação de $(relax)"

    N = length(mesh.z) - 1
    Tm = Tₚ * ones(N + 1)
    hm = h.(Tm)

    a = (ĥ * P * mesh.δ) / (ρ * u * A)
    K = 2spdiagm(-1 => -ones(N-1), 0 => ones(N))

    b = (2a * Tₛ) * ones(N)
    b[1] += 2h(Tₚ)

    # Aloca e inicia em negativo o vetor de residuos. Isso
    # é interessante para o gráfico aonde podemos eliminar
    # os elementos negativos que não tem sentido físico.
    residual = -ones(M)

    @time for niter in 1:M
        # Calcula o vetor `b` do lado direito e resolve o sistema.
        h̄ = K \ (b - a * (Tm[1:end-1] + Tm[2:end]))

        # Relaxa solução para gerir não linearidades.
        if relax == :h
            Δ = (1-α) * (h̄ - hm[2:end])
            m = maximum(hm)

            hm[2:end] += Δ

            # Solução das temperaturas compatíveis com hm.
            Tm[2:end] = map(
                (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ),
                Tm[2:end], hm[2:end]
            )
        else
            # Solução das temperaturas compatíveis com h̄.
            Um = map(
                (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ),
                Tm[2:end], h̄
            )

            Δ = (1-α) * (Um - Tm[2:end])
            m = maximum(Tm)

            Tm[2:end] += Δ
        end

        # Verifica status da convergência.
        residual[niter] = maximum(abs.(Δ/m))

        if (residual[niter] <= ε)
            @info("Convergiu após $(niter) iterações")
            break
        end
    end

    return Tm, residual
end

# ╔═╡ bd79aef3-2634-48b2-b06c-2f0185ebc3ac
md"""
Usamos agora essa função para uma última simulação do mesmo problema. Para que os resultados sejam comparáveis as soluções precedentes, fizemos ``h(T) = c_{p}T + h_{ref}``. O valor de ``h_{ref}`` é arbitrário e não deve afetar a solução por razões que deveriam ser evidentes neste ponto do estudo.
"""

# ╔═╡ 2ff750d6-8680-44cd-a873-bc6f9ac9a383
md"""
Verificamos abaixo que a solução levou um certo número de iterações para convergir. Para concluir vamos averiguar a qualidade da convergência ao longo das iterações.
"""

# ╔═╡ 14a9f7a5-c127-4ac5-8fb9-e94dc4f8462d
md"""
Introduzimos também a possibilidade de se utilizar a relaxação diretamente na entalpia, resolvendo o problema não linear apenas para encontrar diretamente a nova estimação do campo de temperaturas. A figura que segue ilustas o comportamento de convergência. Neste caso específico a relaxação em entalpia não apresenta vantagens, mas veremos em outras ocasiões que esta é a maneira mais simples de se fazer convergir uma simulação.
"""

# ╔═╡ 5c97795c-fc24-409b-ac15-7fafebf6153b
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/).
"""

# ╔═╡ b272c7d6-1697-4805-bcb4-73ca02de4b1c
md"""
## Anexos
"""

# ╔═╡ 7b150e7e-564b-49cf-b4e2-f753a8526d80
"Paramêtros do reator."
const reactor = notedata.c01.reactor

# ╔═╡ a821271c-e66c-422c-8156-848b708ce193
"Parâmetros do fluido"
const fluid = notedata.c01.fluid

# ╔═╡ a6cd5113-eb4d-445a-a646-15458d2b8177
"Parâmetros de operação."
const operations = notedata.c01.operations

# ╔═╡ 5ef2eb0d-1884-4cef-8f00-781f9f164941
"Perímetro da seção circular do reator [m]."
const P = π * reactor.D

# ╔═╡ 096df29b-42ef-4b44-9a54-145f84a9e06b
"Área da seção circula do reator [m²]."
const A = π * (reactor.D/2)^2

# ╔═╡ 97f56fc2-bbb0-4cde-8d55-751160dea9a1
"Solução analítica do reator pistão circular no espaço das temperaturas."
function analyticalthermalpfr(; P::T, A::T, Tₛ::T, Tₚ::T, ĥ::T, u::T, ρ::T,
                                cₚ::T, z::Vector{T})::Vector{T} where T
    return @. Tₛ - (Tₛ - Tₚ) * exp(-z * (ĥ * P) / (ρ * u * cₚ * A))
end

# ╔═╡ 29f8a7e8-8570-43b6-a1e4-48f42f6b1e5a
fig1, fig2 = let
    mesh = ImmersedConditionsFVM(; L = reactor.L, N = 10000)

    z = mesh.z
    ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    h = (T) -> fluid.cₚ * T + 1000

    pars = (z = z, ĥ = ĥ, P = P, A = A, ρ = fluid.ρ, cₚ = fluid.cₚ, operations...)
    solver = (relax = :T, ε = 1.0e-10)

    Tₐ = analyticalthermalpfr(; pars...)
    Tₙ, residuals = solveenthalpypfr(; mesh = mesh, h = h, pars..., solver...)

    fig1 = let
        yrng = (300.0, 400.0)
        Tend = @sprintf("%.2f", Tₐ[end])
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        lines!(ax, z, Tₐ, color = :red,    linewidth = 4, label = "Analítica")
        stairs!(ax, z, Tₙ, color = :black, linewidth = 1, label = "Numérica",
                step = :center)
        xlims!(ax, (0, reactor.L))
        ax.title = "Temperatura final = $(Tend) K"
        ax.xlabel = "Posição [m]"
        ax.ylabel = "Temperatura [K]"
        ax.xticks = range(0.0, reactor.L, 6)
        ax.yticks = range(yrng..., 6)
        ylims!(ax, yrng)
        axislegend(position = :rb)
        fig
    end

    fig2 = let
        r = residuals[residuals .> 0]
        n = ceil(length(r)/5)*5

        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1], ylabel = "log10(r)", xlabel = "Iteração")
        lines!(ax, log10.(r))
        ax.xticks = 0:5:n
        ax.yticks = range(-12, 0, 7)
        xlims!(ax, (0, n))
        ylims!(ax, (-12, 0))
        fig
    end

    fig1, fig2
end;

# ╔═╡ 93cdcc24-60aa-4c6c-87aa-1f941c7a33f5
fig1

# ╔═╡ c4b7cfe3-37a8-4619-b8c9-3d506f74468b
fig2

# ╔═╡ 383998d7-2edf-4748-a58d-1fbfec86bb97
fig3, fig4 = let
    mesh = ImmersedConditionsFVM(; L = reactor.L, N = 10000)

    z = mesh.z
    ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    h = (T) -> fluid.cₚ * T + 1000

    pars = (z = z, ĥ = ĥ, P = P, A = A, ρ = fluid.ρ, cₚ = fluid.cₚ, operations...)
    solver = (relax = :h, ε = 1.0e-10)

    Tₐ = analyticalthermalpfr(; pars...)
    Tₙ, residuals = solveenthalpypfr(; mesh = mesh, h = h, pars..., solver...)

    fig1 = let
        yrng = (300.0, 400.0)
        Tend = @sprintf("%.2f", Tₐ[end])
        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1])
        lines!(ax, z, Tₐ, color = :red,    linewidth = 4, label = "Analítica")
        stairs!(ax, z, Tₙ, color = :black, linewidth = 1, label = "Numérica",
                step = :center)
        xlims!(ax, (0, reactor.L))
        ax.title = "Temperatura final = $(Tend) K"
        ax.xlabel = "Posição [m]"
        ax.ylabel = "Temperatura [K]"
        ax.xticks = range(0.0, reactor.L, 6)
        ax.yticks = range(yrng..., 6)
        ylims!(ax, yrng)
        axislegend(position = :rb)
        fig
    end

    fig2 = let
        r = residuals[residuals .> 0]
        n = ceil(length(r)/5)*5

        fig = Figure(resolution = (720, 500))
        ax = Axis(fig[1, 1], ylabel = "log10(r)", xlabel = "Iteração")
        lines!(ax, log10.(r))
        ax.xticks = 0:5:n
        ax.yticks = range(-12, 0, 7)
        xlims!(ax, (0, n))
        ylims!(ax, (-12, 0))
        fig
    end

    fig1, fig2
end;

# ╔═╡ ef9aa780-07c1-490c-8056-286e97927867
fig4

# ╔═╡ 7158a6ea-48ec-4b19-81db-1317198cc980
md"""
## Pacotes
"""

# ╔═╡ Cell order:
# ╟─0c42a060-5cf5-11ee-273c-b16c31ed2b48
# ╟─eaed30cf-e984-4ae6-8eb8-43ba533c23ee
# ╟─da2429b7-5dd5-44f4-a5ec-d60b69100fb6
# ╟─548a5654-47bf-42d4-bfb6-38e1c2860c32
# ╟─bd79aef3-2634-48b2-b06c-2f0185ebc3ac
# ╟─29f8a7e8-8570-43b6-a1e4-48f42f6b1e5a
# ╟─93cdcc24-60aa-4c6c-87aa-1f941c7a33f5
# ╟─2ff750d6-8680-44cd-a873-bc6f9ac9a383
# ╟─c4b7cfe3-37a8-4619-b8c9-3d506f74468b
# ╟─14a9f7a5-c127-4ac5-8fb9-e94dc4f8462d
# ╟─383998d7-2edf-4748-a58d-1fbfec86bb97
# ╟─ef9aa780-07c1-490c-8056-286e97927867
# ╟─5c97795c-fc24-409b-ac15-7fafebf6153b
# ╟─b272c7d6-1697-4805-bcb4-73ca02de4b1c
# ╟─7b150e7e-564b-49cf-b4e2-f753a8526d80
# ╟─a821271c-e66c-422c-8156-848b708ce193
# ╟─a6cd5113-eb4d-445a-a646-15458d2b8177
# ╟─5ef2eb0d-1884-4cef-8f00-781f9f164941
# ╟─096df29b-42ef-4b44-9a54-145f84a9e06b
# ╟─97f56fc2-bbb0-4cde-8d55-751160dea9a1
# ╟─7158a6ea-48ec-4b19-81db-1317198cc980
# ╟─ea183591-cc73-44cc-b1d0-572cf24d5b6b
