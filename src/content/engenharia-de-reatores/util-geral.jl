# -*- coding: utf-8 -*-

"Calcula a potência de `x` mais próxima de `v`."
function closestpowerofx(v::Number; x::Number = 10)::Number
    rounder = x^floor(log(x, v))
    return convert(Int64, rounder * ceil(v/rounder))
end

@info("Verifique `util-geral.jl` para mais detalhes...")
