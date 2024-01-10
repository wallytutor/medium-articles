# Parte 9 - Álgebra linear

using LinearAlgebra


A₁ = rand(1:4, 3, 3)


x = fill(1.0, 3)


A₁ * x


A₁'


transpose(A₁)


A₁'A₁


A₁' * A₁


A₁ \ x


Atall = rand(3, 2)


A\b gives us the least squares solution if we have an overdetermined linear system (a "tall" matrix) and the minimum norm least squares solution if we have a rank-deficient least squares problem


Atall \ x


begin
    v₁ = rand(3)
    rankdef = hcat(v₁, v₁)
end


rankdef \ x


Julia also gives us the minimum norm solution when we have an underdetermined solution (a "short" matrix)


begin
    bshort = rand(2)
    Ashort = rand(2, 3)
    Ashort, bshort
end


Ashort\bshort


# https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/#LinearAlgebra.cross
LinearAlgebra.dot([1 1], [1 1])


LinearAlgebra.kron(v₁', v₁)


u = [1, 2, 3]


kron(u', u)


cross(u, u)


Isso é tudo para esta sessão de estudo! Até a próxima!
