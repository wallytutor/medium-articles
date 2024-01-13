### A Pluto.jl notebook ###
# v0.19.30

using Markdown
using InteractiveUtils

# ╔═╡ 05b06ee0-b1e5-11ee-018d-73ad26daf458
md"""
# Reator pistão - introdução

Este é o primeiro notebook de uma série abordando reatores do tipo *pistão*
(*plug-flow*) no qual os efeitos advectivos são preponderantes sobre o
comportamento difusivo, seja de calor, massa, ou espécies. O estudo e modelagem
desse tipo de reator apresentar diversos interesses para a pesquisa fundamental
e na indústria. Muitos reatores tubulares de síntese laboratorial de materiais
apresentam aproximadamente um comportamento como tal e processos nas mais
diversas indústrias podem ser aproximados por um ou uma rede de reatores pistão
e reatores agitados interconectados.

Começaremos por um caso simples considerando um fluido incompressível e ao longo
da série aumentaremos progressivamente a complexidade dos modelos. Os notebooks
nessa série vão utilizar uma estratégia focada nos resultados, o que indica que
o código será na maior parte do tempo ocultado e o estudante interessado deverá
executar o notebook por si mesmo para estudar as implementações.

Nesta *Parte 1* vamos estuda a formulação na temperatura da equação de
conservação de energia.
"""

# ╔═╡ Cell order:
# ╟─05b06ee0-b1e5-11ee-018d-73ad26daf458
