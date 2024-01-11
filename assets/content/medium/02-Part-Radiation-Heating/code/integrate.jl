# This file was generated, do not modify it. # hide
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
nothing; # hide