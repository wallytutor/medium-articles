# -*- coding: utf-8 -*-

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

@info("Verifique `util-residuos.jl` para mais detalhes...")
