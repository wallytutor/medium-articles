# Parte 8 - Avaliando performance

using BenchmarkTools
using PythonCall
using CondaPkg
# CondaPkg.add("numpy")


npsum = pyimport("numpy").sum


function jlsum(a)
    val = 0.0;
    for v in a
        val += v;
    end
    return val
end


function jlsumsimd(A)
    s = 0.0 # s = zero(eltype(A))
    @simd for a in A
        s += a
    end
    s
end


arands = rand(10^7);


@benchmark $pybuiltins.sum($arands)


@benchmark $npsum($arands)


@benchmark jlsum($arands)


@benchmark jlsumsimd($arands)


@benchmark sum($arands)


@which sum(arands)


sum(arands) ≈ jlsum(arands)


sum(arands) ≈ pyconvert(Float64, npsum(arands))


Isso é tudo para esta sessão de estudo! Até a próxima!
