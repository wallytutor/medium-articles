# This file was generated, do not modify it. # hide
residual(Tᵢ, Tⱼ) = maximum(abs.(Tⱼ .- Tᵢ) ./ Tᵢ)
nothing; # hide