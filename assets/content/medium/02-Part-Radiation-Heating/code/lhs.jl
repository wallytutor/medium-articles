# This file was generated, do not modify it. # hide
function buildlhsmatrix(τ, h, A)
    K = stiffness(h, A)
    I = diagm([1, 1, 1] * 1u"1")
    return (Tₖ) -> I + τ * inertiainv(Tₖ) * K
end
nothing; # hide