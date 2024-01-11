# This file was generated, do not modify it. # hide
tend = 24*3600

T = [1273.0u"K", Ta, Ta]
t = range(0, tend, convert(Int64, tend / 8))
τ = step(t) * 1u"s"

K = buildlhsmatrix(τ, h, A)
B = buildrhsvector(τ, h, A, Ta, ϵp, ϵw)

maxiter = 80
rtol = 1.0e-12
β = 0.99

@time solution = integrate(t, T, K, B; maxiter, rtol, β);