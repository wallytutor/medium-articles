# This file was generated, do not modify it. # hide
function steptime(T₀, K, B; maxiter = 50, rtol = 1.0e-12, β = 1.0)
    Tᵢ = copy(T₀)
    Tⱼ = copy(T₀)
    Δ = 9.0e+100

    for j in range(1, maxiter)
        Tⱼ[:] = inv(K(Tⱼ)) * (B(Tⱼ) .+ T₀)
        Tⱼ[:] = relaxation(Tᵢ, Tⱼ, β)
        Δ = residual(Tᵢ, Tⱼ)
        Tᵢ[:] = Tⱼ[:]

        if Δ < rtol
            return Tᵢ, j, Δ
        end
    end

    @warn("No convergence during step @ $(@sprintf("%.6e", Δ))")
    return Tᵢ, maxiter, Δ
end
nothing; # hide