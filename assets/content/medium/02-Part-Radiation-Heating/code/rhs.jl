# This file was generated, do not modify it. # hide
function buildrhsvector(τ, h, A, Ta, ϵp, ϵw)
    F(T) = τ * forcing(T, h, A, Ta, ϵp, ϵw)
    return (Tₖ) -> inertiainv(Tₖ) * F(Tₖ)
end
nothing; # hide