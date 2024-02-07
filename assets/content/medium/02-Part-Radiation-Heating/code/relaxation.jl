# This file was generated, do not modify it. # hide
relaxation(Tᵢ, Tⱼ, β) = @. β * Tⱼ + (1-β) * Tᵢ
nothing; # hide