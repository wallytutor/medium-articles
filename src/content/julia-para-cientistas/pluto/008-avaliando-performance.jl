### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    import PlutoUI
    PlutoUI.TableOfContents(title="Tópicos")
end

# ╔═╡ e4428ffe-6180-4145-bed6-08ca5bd2f179
begin
    using BenchmarkTools
    using PythonCall
    using CondaPkg
    # CondaPkg.add("numpy")
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 8 - Avaliando performance
"""

# ╔═╡ d0cba36d-01b0-425d-9677-dd188cedbd04
md"""
## Seção
"""

# ╔═╡ 31a3a32d-0cff-4df2-abbd-d06f638cb2ee
npsum = pyimport("numpy").sum

# ╔═╡ 78444e7a-adac-467f-bed1-046c2df7db28
function jlsum(a)
    val = 0.0;
    for v in a
        val += v;
    end
    return val
end

# ╔═╡ 80e8aef2-d6a2-41ce-94c6-7668ab39c2f7
function jlsumsimd(A)
    s = 0.0 # s = zero(eltype(A))
    @simd for a in A
        s += a
    end
    s
end

# ╔═╡ 2282cd85-04cd-45ea-b78f-0893307ca745
arands = rand(10^7);

# ╔═╡ 405903fe-9cb6-47a5-8eae-f353204640b2
@benchmark $pybuiltins.sum($arands)

# ╔═╡ 52ca8e37-f794-46fe-90fe-4fc69050ad53
@benchmark $npsum($arands)

# ╔═╡ db104cd4-e89a-4643-afe0-03f8a65e076c
@benchmark jlsum($arands)

# ╔═╡ 5f91c530-7042-45c6-b4ea-9f0aee1b0c43
@benchmark jlsumsimd($arands)

# ╔═╡ d6df3de1-3e28-47f4-b305-e85eaab855c7
@benchmark sum($arands)

# ╔═╡ ea8696b6-3c36-44e7-8fce-52ce12c7e054
@which sum(arands)

# ╔═╡ 44ddc5ed-bca2-43a0-bfbe-6452f4491dcb
sum(arands) ≈ jlsum(arands)

# ╔═╡ 0bc3727a-edb0-4183-ade3-ef3771a8dcb4
sum(arands) ≈ pyconvert(Float64, npsum(arands))

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─d0cba36d-01b0-425d-9677-dd188cedbd04
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╠═31a3a32d-0cff-4df2-abbd-d06f638cb2ee
# ╠═78444e7a-adac-467f-bed1-046c2df7db28
# ╠═80e8aef2-d6a2-41ce-94c6-7668ab39c2f7
# ╠═2282cd85-04cd-45ea-b78f-0893307ca745
# ╠═405903fe-9cb6-47a5-8eae-f353204640b2
# ╠═52ca8e37-f794-46fe-90fe-4fc69050ad53
# ╠═db104cd4-e89a-4643-afe0-03f8a65e076c
# ╠═5f91c530-7042-45c6-b4ea-9f0aee1b0c43
# ╠═d6df3de1-3e28-47f4-b305-e85eaab855c7
# ╠═ea8696b6-3c36-44e7-8fce-52ce12c7e054
# ╠═44ddc5ed-bca2-43a0-bfbe-6452f4491dcb
# ╠═0bc3727a-edb0-4183-ade3-ef3771a8dcb4
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
