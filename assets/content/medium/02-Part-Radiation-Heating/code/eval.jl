# This file was generated, do not modify it. # hide
T = [1273.0u"K", Ta, Ta]
τ = 1.0u"s"

K = buildlhsmatrix(τ, h, A)
B = buildrhsvector(τ, h, A, Ta, ϵp, ϵw)

# Because of factorization this does not works with Unitful.
# Units are stripped and system becomes inconsistent.
# Tnew = K(T) \ (B(T) .+ T)

Tnew = inv(K(T)) * (B(T) .+ T)