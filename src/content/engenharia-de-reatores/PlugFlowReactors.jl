# -*- coding: utf-8 -*-
module PlugFlowReactors

"Constante dos gases ideais [J/(mol.K)]."
const GAS_CONSTANT::Float64 = 8.314_462_618_153_24

"Função auxiliar para avaliação exaustiva de critérios de validação."
function testall(tests)
    messages = []

    for (evaluation, message) in tests
        !evaluation && push!(messages, message)
    end
    
    if !isempty(messages)
        @error join(messages, "\n")
        throw(ArgumentError("Check previous warnings"))
    end
end

"Equação de Gnielinski para número de Nusselt."
function Nu_gnielinski(Re, Pr)
    testall([
        (3000.0 <= Re <= 5.0e+06, "* Re = $(Re) ∉ [3000, 5×10⁶]"),
        (0.5 <= Pr <= 2000.0,     "* Pr = $(Pr) ∉ [0.5, 2000]")
    ])

    f = (0.79 * log(Re) - 1.64)^(-2)
    g = f / 8

    num = g * (Re - 1000) * Pr
    den = 1.0 + 12.7 * (Pr^(2 / 3) - 1) * g^(1 / 2)
    
    return num / den
end

"Equação de Dittus-Boelter para número de Nusselt."
function Nu_dittusboelter(Re, Pr, L, D; what = :heating)
    testall([
        (Re >= 10000.0,       "* Re = $(Re) < 10000"),
        (0.6 <= Pr <= 160.0,  "* Pr = $(Pr) ∉ [0.6, 160]"),
        (L / D > 10.0,        "* L/D = $(L/D) < 10.0")
    ])

    n = (what == :heating) ? 0.4 : 0.3

    return 0.023 * Re^(4//5) * Pr^n
end

"Avalia número de Nusselt com correlação escolhida."
function Nu(Re, Pr; method = :gnielinski, kw...)
    # Valor para escoamento interno laminar.
    Nu = 3.66

    # Modifica valor com método se turbulento.
    if Re > 3000.0
        if method == :gnielinski
            Nu = Nu_gnielinski(Re, Pr)
        elseif method == :dittusboelter
            what = get(kw, :what, :heating)
            Nu = Nu_dittusboelter(Re, Pr, kw[:L], kw[:D]; what)
        else
            throw(ArgumentError("Unknown method $(method)"))
        end
    end

    return Nu
end

"Estima coeficiente de troca convectiva do escoamento."
function heattransfercoef(L, D, u, ρ, μ, cₚ, Pr; kw...)
    Re_val = ρ * u * D / μ
	Nu_val = Nu(Re_val, Pr; kw...)
	
    k = cₚ * μ / Pr
    h = Nu_val * k / D

    if get(kw, :verbose, false)
        @info("""\
            Reynolds ................... $(Re_val)
            Nusselt .................... $(Nu_val)
            k .......................... $(k) W/(m.K)
            h .......................... $(h) W/(m².K)\
            """)
    end

    return h
end

end # (module PlugFlowReactors)
