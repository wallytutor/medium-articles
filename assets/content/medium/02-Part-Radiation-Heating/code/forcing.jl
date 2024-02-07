# This file was generated, do not modify it. # hide
function forcing(T, h, A, Ta, ϵp, ϵw)
    f1 = -ϵp*σ*A[1]*(T[1]^4-T[3]^4)
    f3 = h[3]*A[3]*Ta - f1 - ϵw*σ*A[3]*(T[3]^4 - Ta^4)
    return [ f1; 0u"W"; f3 ]
end
nothing; #hide