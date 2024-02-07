# This file was generated, do not modify it. # hide
specificheat(T) = [cp(T[1]); cg(T[2]); cw(T[3])]

inertiainv(T) = diagm(1 ./ specificheat(T))
nothing; # hide