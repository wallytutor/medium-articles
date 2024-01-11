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
using LinearAlgebra

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 9 - Álgebra linear
"""

# ╔═╡ d0cba36d-01b0-425d-9677-dd188cedbd04
md"""
## Seção
"""

# ╔═╡ d95ed609-0603-4593-bb64-13e06f0ee8ce
A₁ = rand(1:4, 3, 3)

# ╔═╡ db45a565-00cd-435a-a358-c9bb7af78beb
x = fill(1.0, 3)

# ╔═╡ a55a149c-c258-4acb-8ef6-5b02cce4b833
A₁ * x

# ╔═╡ c5e8ec55-4a15-4fbd-8812-513d8f91d2e0
A₁'

# ╔═╡ b33a115d-c2a7-4af0-b9ff-fc67cd198f06
transpose(A₁)

# ╔═╡ f45fc5bc-be55-4b95-b8be-fa05bae532e4
A₁'A₁

# ╔═╡ f8fbbe23-3439-46df-be92-eb987cd0cd13
A₁' * A₁

# ╔═╡ cfc27773-40e7-4738-9cab-520023758a16
A₁ \ x

# ╔═╡ 61970ac4-a1a3-4f96-a22c-1e873c410c52
Atall = rand(3, 2)

# ╔═╡ 1d396217-b3e5-4d49-badb-9c4c49f80dea
md"""
A\b gives us the least squares solution if we have an overdetermined linear system (a "tall" matrix) and the minimum norm least squares solution if we have a rank-deficient least squares problem
"""

# ╔═╡ 2610729f-5f82-494f-a540-898b24728490
Atall \ x

# ╔═╡ dc30f959-1955-4f2e-b866-918e7fded8b8
begin
    v₁ = rand(3)
    rankdef = hcat(v₁, v₁)
end

# ╔═╡ 0ff93867-e63d-42ea-ad73-585e327b6908
rankdef \ x

# ╔═╡ 66a4c0c7-36c9-4aa2-8502-e11b59a49725
md"""
Julia also gives us the minimum norm solution when we have an underdetermined solution (a "short" matrix)
"""

# ╔═╡ 8d5ff575-0d1d-4133-9be3-9c3fe7acd50d
begin
    bshort = rand(2)
    Ashort = rand(2, 3)
    Ashort, bshort
end

# ╔═╡ 976798c8-936e-419f-978c-587c815188c3
Ashort\bshort

# ╔═╡ ee0e2a44-99aa-486c-be54-15772f7f9295
# https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/#LinearAlgebra.cross
LinearAlgebra.dot([1 1], [1 1])

# ╔═╡ d37206c4-93d0-47e5-95a1-91366b4d4ca4
LinearAlgebra.kron(v₁', v₁)

# ╔═╡ 57662f1f-8894-49eb-b9d0-12691f1450f0
u = [1, 2, 3]

# ╔═╡ 9f8f31fe-7b70-47ce-b2df-82c1cb7348d3
kron(u', u)

# ╔═╡ 02c66aef-26b2-47c0-b842-06657a96ae61
cross(u, u)

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─d0cba36d-01b0-425d-9677-dd188cedbd04
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╠═d95ed609-0603-4593-bb64-13e06f0ee8ce
# ╠═db45a565-00cd-435a-a358-c9bb7af78beb
# ╠═a55a149c-c258-4acb-8ef6-5b02cce4b833
# ╠═c5e8ec55-4a15-4fbd-8812-513d8f91d2e0
# ╠═b33a115d-c2a7-4af0-b9ff-fc67cd198f06
# ╠═f45fc5bc-be55-4b95-b8be-fa05bae532e4
# ╠═f8fbbe23-3439-46df-be92-eb987cd0cd13
# ╠═cfc27773-40e7-4738-9cab-520023758a16
# ╠═61970ac4-a1a3-4f96-a22c-1e873c410c52
# ╠═1d396217-b3e5-4d49-badb-9c4c49f80dea
# ╠═2610729f-5f82-494f-a540-898b24728490
# ╠═dc30f959-1955-4f2e-b866-918e7fded8b8
# ╠═0ff93867-e63d-42ea-ad73-585e327b6908
# ╠═66a4c0c7-36c9-4aa2-8502-e11b59a49725
# ╠═8d5ff575-0d1d-4133-9be3-9c3fe7acd50d
# ╠═976798c8-936e-419f-978c-587c815188c3
# ╠═ee0e2a44-99aa-486c-be54-15772f7f9295
# ╠═d37206c4-93d0-47e5-95a1-91366b4d4ca4
# ╠═57662f1f-8894-49eb-b9d0-12691f1450f0
# ╠═9f8f31fe-7b70-47ce-b2df-82c1cb7348d3
# ╠═02c66aef-26b2-47c0-b842-06657a96ae61
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
