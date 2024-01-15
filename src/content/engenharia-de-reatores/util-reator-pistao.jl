# -*- coding: utf-8 -*-
using DocStringExtensions
using Polynomials
using SparseArrays: SparseMatrixCSC


"Estrutura com memória do estado de um reator.

$(TYPEDFIELDS)
"
struct IncompressibleEnthalpyPFRModel
    "Estrutura de discretização espacial."
    mesh::ImmersedConditionsFVM

    "Dados para a solução do problema."
    fvdata::SparseLinearProblemData







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

end

"Dados usados nos notebooks da série."
const notedata = (
    c03 = (
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
        operations3 = (
            u = 2.5,      # Velocidade do fluido [m/s]
            Tₚ = 380.0,   # Temperatura de entrada do fluido [K]
        )
    ),
)

"Calcula a potência de `x` mais próxima de `v`."
function closestpowerofx(v::Number; x::Number = 10)::Number
    rounder = x^floor(log(x, v))
    return convert(Int64, rounder * ceil(v/rounder))
end

"Gestor de resíduos durante uma simulação."
mutable struct ResidualsRaw
    inner::Int64
    outer::Int64
    counter::Int64
    innersteps::Vector{Int64}
    residuals::Vector{Float64}
    function ResidualsRaw(inner::Int64, outer::Int64)
        innersteps = -ones(Int64, outer)
        residuals = -ones(Float64, outer * inner)
        return new(inner, outer, 0, innersteps, residuals)
    end
end

"Resíduos de uma simulação processados."
struct ResidualsProcessed
    counter::Int64
    innersteps::Vector{Int64}
    residuals::Vector{Float64}
    finalsteps::Vector{Int64}
    finalresiduals::Vector{Float64}

    function ResidualsProcessed(r::ResidualsRaw)
        innersteps = r.innersteps[r.innersteps .> 0.0]
        residuals = r.residuals[r.residuals .> 0.0]

        finalsteps = cumsum(innersteps)
        finalresiduals = residuals[finalsteps]

        return new(r.counter, innersteps, residuals,
                   finalsteps, finalresiduals)
    end
end

"Alimenta resíduos da simulação no laço interno."
function feedinnerresidual(r::ResidualsRaw, ε::Float64)
    # TODO: add resizing test here!
    r.counter += 1
    r.residuals[r.counter] = ε
end

@info("Verifique `util-reator-pistao.jl` para mais detalhes...")
