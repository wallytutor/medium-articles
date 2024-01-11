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
    PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ e4428ffe-6180-4145-bed6-08ca5bd2f179
using Colors

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 7 - Pacotes e ecossistema
"""

# ╔═╡ 20ce639c-5d04-4696-a381-ff652bf7ef3b
md"""
Antes de começarmos este tutorial, é interessante navegar [esta página](https://julialang.org/packages/)
"""

# ╔═╡ d0cba36d-01b0-425d-9677-dd188cedbd04
md"""
## Instalação clássica

Julia provê na biblioteca padrão da linguagem o pacote [`Pkg`](https://docs.julialang.org/en/v1/stdlib/Pkg/) que é usado para gestão de instalação de pacotes, entre outras funcionalidades. Em uma sessão terminal de Julia você pode installar o pacote [`Colors`](https://github.com/JuliaGraphics/Colors.jl) com

```julia
using Pkg

Pkg.add("Colors")
```

ou alternativamente pressionando `]` para entrar em uma sessão de gestão de pacotes

```julia-repl
] add Colors
```

Aqui no ambiente de Pluto, um *package manager* automático é disponível, então cada vez que você listar um novo pacote ele é automaticamente installado num ambiente específico ao documento. Abaixo simplesmente tentamos utilisar `Colors` e o pacote é automaticamente instalado.
"""

# ╔═╡ afb35ba5-f20f-45a9-90fc-539df17eed90
palette = distinguishable_colors(50)

# ╔═╡ c835f315-a84b-49a4-bbfd-d869dbcbe782
rand(palette, 3, 3)

# ╔═╡ 04ce2efe-f8e1-4b54-b08c-dc807850e3f7
# TO BE CONTINUED...

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─20ce639c-5d04-4696-a381-ff652bf7ef3b
# ╟─d0cba36d-01b0-425d-9677-dd188cedbd04
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╠═afb35ba5-f20f-45a9-90fc-539df17eed90
# ╠═c835f315-a84b-49a4-bbfd-d869dbcbe782
# ╠═04ce2efe-f8e1-4b54-b08c-dc807850e3f7
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
