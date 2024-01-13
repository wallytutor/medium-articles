# -*- coding: utf-8 -*-
using DocStringExtensions
using Polynomials
using SparseArrays: SparseMatrixCSC

include("util-residuos.jl")

"Constante dos gases ideais [J/(mol.K)]."
const GAS_CONSTANT = 8.314_462_618_153_24

"Tipo abstrato para domínios em FVM."
abstract type AbstractDomainFVM end

"Tipo abstrato para um modelo de reator pistão."
abstract type AbstractPFRModel end

"Método dos volumes finitos com condição limite imersa."
struct ImmersedConditionsFVM <: AbstractDomainFVM
    "Coordenadas dos centros das células [m]."
    z::Vector{Float64}

    "Coordenadas dos limites das células [m]."
    w::Vector{Float64}

    "Comprimento de uma célula [m]."
    δ::Float64

    function ImmersedConditionsFVM(; L::Float64, N::Int64)
        δ = L / N
        z = collect(0.0:δ:L)
        w = collect(0.5δ:δ:L-0.5δ)
        return new(z, w, δ)
    end
end

"Contém dados do sistema linear ``Ax=b(a)`` de um modelo.

$(TYPEDFIELDS)
"
struct SparseLinearProblemData
    "Matriz do problema."
    A::SparseMatrixCSC{Float64, Int64}

    "Vetor do problema."
    b::Vector{Float64}

    "Coeficientes do problema."
    c::Vector{Float64}

    "Solução do problema."
    x::Vector{Float64}

    "Tamanho do problema linear."
    n::Int64

    function SparseLinearProblemData(;
            A::SparseMatrixCSC{Float64, Int64},
            b::Vector{Float64},
            c::Vector{Float64},
            extended::Bool = true
        )
        n = length(b)
        x = zeros(extended ? n+1 : n)
        return new(A, b, c, x, n)
    end
end

"Estrutura com memória do estado de um reator.

$(TYPEDFIELDS)
"
struct IncompressibleEnthalpyPFRModel <: AbstractPFRModel
    "Estrutura de discretização espacial."
    mesh::ImmersedConditionsFVM

    "Dados para a solução do problema."
    fvdata::SparseLinearProblemData

    "Entalpia em função da temperatura [J/kg]."
    enthalpy::Function

    "Fluxo mássico através do reator [kg/s]."
    ṁ::Float64

    "Coeficiente de troca térmica convectiva [W/(m².K)]."
    ĥ::Float64

    """	Construtor interno dos dados de reatores.

    - `N`  : Número de células no sistema, incluindo limites.
    - `L`  : Comprimento do reator [m].
    - `P`  : Perímetro da seção [m].
    - `A`  : Área da seção [m²].
    - `T`  : Temperatura inicial do fluido [K].
    - `u`  : Velocidade do fluido [m/s].
    - `ĥ`  : Coeficiente de troca convectiva [W/(m².K)].
    - `ρ`  : Densidade do fluido [kg/m³].
    - `h`  : Entalpia em função da temperatura [J/kg]
    """
    function IncompressibleEnthalpyPFRModel(;
            N::Int64,
            L::Float64,
            P::Float64,
            A::Float64,
            T::Float64,
            u::Float64,
            ĥ::Float64,
            ρ::Float64,
            h::Function,
        )
        ṁ = ρ * u * A

        mesh = ImmersedConditionsFVM(; L = L, N = N)

        fvdata = SparseLinearProblemData(
            A = 2spdiagm(0=>ones(N), -1=>-ones(N-1)),
            b = ones(N),
            c = zeros(1),
            extended = true
        )

        fvdata.x[1:end] .= T
        fvdata.c[1] = (ĥ * P * mesh.δ) / ṁ

        return new(mesh, fvdata, h, ṁ, ĥ)
    end
end

"Representa um par de reatores em contrafluxo."
struct CounterFlowPFRModel
    this::IncompressibleEnthalpyPFRModel
    that::IncompressibleEnthalpyPFRModel
end

"Macro para capturar erro dada uma condição invalida."
macro warnonly(ex)
    quote
        try
            $(esc(ex))
        catch e
            @warn e
        end
    end
end

"Estima coeficiente de troca convectiva do escoamento."
function computehtc(; L, D, u, ρ, μ, cₚ, Pr,
                      method = :g, verbose = false)
    Re = ρ * u * D / μ

    Nug = gnielinski_Nu(Re, Pr)
    Nud = dittusboelter_Nu(Re, Pr, L, D)

    if Re > 3000
        Nu = (method == :g) ? Nug : Nub
    else
        Nu = 3.66
    end

    k = cₚ * μ / Pr
    h = Nu * k / D

    if verbose
        println("""\
            Reynolds ................... $(Re)
            Nusselt (Gnielinsk) ........ $(Nug)
            Nusselt (Dittus-Boelter) ... $(Nud)
            Nusselt (usado aqui) ....... $(Nu)
            k .......................... $(k) W/(m.K)
            h .......................... $(h) W/(m².K)\
            """)
    end

    return h
end

"Equação de Gnielinski para número de Nusselt."
function gnielinski_Nu(Re, Pr)
    function validate(Re, Pr)
        @assert 3000.0 <= Re <= 5.0e+06 "Re=$(Re) ∉ [3.0e+03, 5.0e+06]"
        @assert 0.5 <= Pr <= 2000.0     "Pr=$(Pr) ∉ [5.0e-01, 2.0e+03]"
    end

    @warnonly validate(Re, Pr)

    f = (0.79 * log(Re) - 1.64)^(-2)
    g = f / 8

    num = g * (Re - 1000) * Pr
    den = 1.0 + 12.7 * (Pr^(2 / 3) - 1) * g^(1 / 2)
    return num / den
end

"Equação de Dittus-Boelter para número de Nusselt."
function dittusboelter_Nu(Re, Pr, L, D; what = :heating)
    function validate(Re, Pr, L, D)
        @assert 10000.0 <= Re       "Re=$(Re) ∉ [0.0e+00, 1.0e+04]"
        @assert 0.6 <= Pr <= 160.0  "Pr=$(Pr) ∉ [6.0e-01, 1.6e+02]"
        @assert 10.0 <= L / D       "L/D=$(L/D) < 10.0"
    end

    @warnonly validate(Re, Pr, L, D)

    n = (what == :heating) ? 0.4 : 0.4
    return 0.023 * Re^(4 / 5) * Pr^n
end

"Cria o par inverso de reatores em contra-fluxo."
function swap(cf::CounterFlowPFRModel)
    return CounterFlowPFRModel(cf.that, cf.this)
end

"Acesso as coordenadas espaciais do reator."
function coordinates(cf::CounterFlowPFRModel)
    return cf.this.mesh.z
end

"Acesso ao perfil de temperatura do primeiro reator em um par."
function thistemperature(cf::CounterFlowPFRModel)
    return cf.this.fvdata.x |> identity
end

"Acesso ao perfil de temperatura do segundo reator em um par."
function thattemperature(cf::CounterFlowPFRModel)
    return cf.that.fvdata.x |> reverse
end

"Perfil de temperatura na parede entre dois fluidos respeitando fluxo."
function surfacetemperature(cf::CounterFlowPFRModel)
    T1 = thistemperature(cf)
    T2 = thattemperature(cf)

    ĥ1 = cf.this.ĥ
    ĥ2 = cf.that.ĥ

    Tw1 = 0.5 * (T1[1:end-1] + T1[2:end])
    Tw2 = 0.5 * (T2[1:end-1] + T2[2:end])

    return (ĥ1 * Tw1 + ĥ2 * Tw2) / (ĥ1 + ĥ2)
end

"Conservação de entalpia entre dois reatores em contra-corrente."
function enthalpyresidual(cf::CounterFlowPFRModel)
    function enthalpyrate(r)
        T₁, T₀ = r.fvdata.x[[1, end]]
        return r.ṁ * (r.enthalpy(T₁) - r.enthalpy(T₀))
    end

    Δha = enthalpyrate(cf.this)
    Δhb = enthalpyrate(cf.that)
    return abs(Δhb + Δha) / abs(Δha)
end

"Produz função para inverter solução em entalpia."
function getrootfinder(h::Function)::Function
    return (Tₖ, hₖ) -> find_zero(t -> h(t) - hₖ, Tₖ)
end

"Método de relaxação baseado na entalpia."
function relaxenthalpy!(Tm, hm, h̄, α, f)
    # Calcula erro e atualização antes!
    Δ = (1-α) * (h̄ - hm[2:end])
    ε = maximum(abs.(Δ)) / abs(maximum(hm))

    # Autaliza solução antes de resolver NLP.
    hm[2:end] += Δ

    # Solução das temperaturas compatíveis com hm.
    Tm[2:end] = map(f, Tm[2:end], hm[2:end])

    return ε
end

"Método de relaxação baseado na temperatura."
function relaxtemperature!(Tm, hm, h̄, α, f)
    # XXX: manter hm na interface para compabilidade com relaxenthalpy!
    # Solução das temperaturas compatíveis com h̄.
    Um = map(f, Tm[2:end], h̄)

    # Calcula erro e atualização depois!
    Δ = (1-α) * (Um - Tm[2:end])
    ε = maximum(abs.(Δ)) / abs(maximum(Tm))

    # Autaliza solução com resultado do NLP.
    Tm[2:end] += Δ

    return ε
end

"Laço interno da solução de reatores em contra-corrente."
function innerloop(
        residual::ResidualsRaw;
        cf::CounterFlowPFRModel,
        M::Int64 = 1,
        α::Float64 = 0.95,
        ε::Float64 = 1.0e-08,
        relax::Symbol = :h
    )::Int64
    relax = (relax == :h) ? relaxenthalpy! : relaxtemperature!

    r = cf.this

    S = surfacetemperature(cf)
    f = getrootfinder(r.enthalpy)

    T = r.fvdata.x
    A = r.fvdata.A
    b = r.fvdata.b
    a = r.fvdata.c[1]
    h = r.enthalpy

    Tm = T
    hm = h.(Tm)

    b[1:end] = 2a * S
    b[1] += 2h(Tm[1])

    for niter in 1:M
        h̄ = A \ (b - a * (Tm[1:end-1] + Tm[2:end]))
        εm = relax(Tm, hm, h̄, α, f)
        feedinnerresidual(residual, εm)

        if (εm <= ε)
            return niter
        end
    end

    @warn "Não convergiu após $(M) passos"
    return M
end

"Laço externo da solução de reatores em contra-corrente."
function outerloop(
        cf::CounterFlowPFRModel;
        inner::Int64 = 5,
        outer::Int64 = 500,
        relax::Float64 = 0.95,
        Δhmax::Float64 = 1.0e-08,
        rtol::Float64 = 1.0e-08,
    )::Tuple{ResidualsProcessed, ResidualsProcessed}
    ra = cf
    rb = swap(ra)

    resa = ResidualsRaw(inner, outer)
    resb = ResidualsRaw(inner, outer)

    @time for nouter in 1:outer
        shared = (M = inner, α = relax, ε = rtol)

        ca = innerloop(resa; cf = ra, shared...)
        cb = innerloop(resb; cf = rb, shared...)

        resa.innersteps[nouter] = ca
        resb.innersteps[nouter] = cb

        if enthalpyresidual(cf) < Δhmax
            @info("Laço externo convergiu após $(nouter) iterações")
            break
        end
    end

    @info("Conservação da entalpia = $(enthalpyresidual(cf))")
    return ResidualsProcessed(resa), ResidualsProcessed(resb)
end

"Dados usados nos notebooks da série."
const notedata = (
    c01 = (
        reactor = (
            L = 10.0,    # Comprimento do reator [m]
            D = 0.01     # Diâmetro do reator [m]
        ),
        fluid = (
            ρ = 1000.0,  # Mass específica do fluido [kg/m³]
            μ = 0.001,   # Viscosidade do fluido [Pa.s]
            cₚ = 4182.0, # Calor específico do fluido [J/(kg.K)]
            Pr = 6.9     # Número de Prandtl do fluido
        ),
        operations = (
            u = 1.0,     # Velocidade do fluido [m/s]
            Tₚ = 300.0,  # Temperatura de entrada do fluido [K]
            Tₛ = 400.0   # Temperatura da parede do reator [K]
        )
    ),
    c03 = (
        reactor = (
            L = 10.0,    # Comprimento do reator [m]
            D = 0.01     # Diâmetro do reator [m]
        ),
        fluid1 = (
            ρ = 1000.0,  # Mass específica do fluido [kg/m³]
            μ = 0.001,   # Viscosidade do fluido [Pa.s]
            cₚ = 4182.0, # Calor específico do fluido [J/(kg.K)]
            Pr = 6.9     # Número de Prandtl do fluido
        ),
        fluid3 = (
            # Viscosidade do fluido [Pa.s]
            μpoly = Polynomial([
                1.7e-05 #TODO copy good here!
            ], :T),
            # Calor específico do fluido [J/(kg.K)]
            cₚpoly = Polynomial([
                    959.8458126240355,
                    0.3029051601580761,
                    3.988896105280984e-05,
                    -6.093647929461819e-08,
                    1.0991100692950414e-11
                ], :T),
            # Número de Prandtl do fluido
            Pr = 0.70
        ),
        operations1 = (
            u = 1.0,     # Velocidade do fluido [m/s]
            Tₚ = 300.0,  # Temperatura de entrada do fluido [K]
        ),
        operations2 = (
            u = 2.0,     # Velocidade do fluido [m/s]
            Tₚ = 400.0,  # Temperatura de entrada do fluido [K]
        ),
        operations3 = (
            u = 2.5,      # Velocidade do fluido [m/s]
            Tₚ = 380.0,   # Temperatura de entrada do fluido [K]
        )
    ),
)

@info("Verifique `util-reator-pistao.jl` para mais detalhes...")
