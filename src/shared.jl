# -*- coding: utf-8 -*-
using CairoMakie
using LinearAlgebra
using Printf
using Unitful

# This is required because the default `\` does not support units.
# https://github.com/PainterQubits/Unitful.jl/issues/46#issuecomment-1338712249
function LinearAlgebra.:\(A::Matrix{Q}, b::Vector{V}
    ) where {Q<:Quantity{Float64}, V<:Quantity{Float64}}
  ustrip(A)\ustrip(b) * (unit(b[1]) / unit(A[1,1]))
end

# Stefan-Boltzmann constant.
const σ = 5.67e-08u"W/(m^2*K^4)"
