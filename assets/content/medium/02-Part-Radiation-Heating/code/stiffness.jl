# This file was generated, do not modify it. # hide
function stiffness(h, A)
    p = @. h * A
    q = -1 * p[1:end-1]
    p[2:end] -= q
    return diagm(0=>p, -1=>q, 1=>q)
end
nothing; # hide