### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ b9af06b7-88c7-40fe-8c0d-f2510c5ec36d
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    import PlutoUI
    PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ 5b226140-525d-11ee-2e60-55f9f82f899e
md"""
# Parte 3 - Estruturas de dados I
"""

# ╔═╡ 47fbe810-d30b-4f6a-93d1-2856fed594ca
md"""
Nesta seção vamos estudar alguns tipos de estruturas de dados. Essas formas *compostas* são construídas sobre elementos que já vimos mas podem também ir além destes. Abordaremos apenas as características básicas de cada uma das estruturas apresentadas e os casos de aplicação se tornarão evidentes. Os diversos métodos comuns à essas coleções é descrito [nesta página](https://docs.julialang.org/en/v1/base/collections/).
"""

# ╔═╡ 91d42cd2-1a69-4fbc-9edb-d4d607371c60
md"""
## *Tuples*

Uma *tuple* é constituída de uma sequência de elementos, que podem ser de tipos diferentes, declarada entre parêntesis. A característica de base de uma *tuple* é sua imutabilidade: uma vez declarada, seus elementos não podem ser alterados.

!!! note "Já vimos isso antes"

    Voltando a seção aonde realizamos a conversão explícita de tipos acima, você pode verificar que na realidade já utilizamos uma tuple de números indicando as intensidades RGB de uma cor.

Declaremos uma sequência fixa de linguagens de programação dadas por seus nomes como `Strings`:
"""

# ╔═╡ 692e4a6b-ee30-4ee7-a5ab-1f4ed5271e5a
languages = ("Julia", "Python", "Octave")

# ╔═╡ c750be52-e855-4190-a766-b1c518577965
md"""
Inspecionando o tipo desta variável aprendemos mais uma característica importante inerente a definição de `Tuple` feita acima quanto ao seu caráter imutável: o tipo de uma `Tuple` inclui individualmente o tipo de cada um de seus elementos. Dito de outra maneira, uma sequência composta de um número definido de objetos de dados tipos caracteriza por ela mesmo um novo tipo de dados.
"""

# ╔═╡ 6f88eee0-a1a1-471f-8b28-9e197ae04499
typeof(languages)

# ╔═╡ 6a42cbf3-3e1f-40f9-aefe-c4688ec7c0ec
md"""
Os elementos de uma `Tuple` podem ser acessados por seus índices.

!!! warning "Indices em Julia"

    É o momento de mencionar que em Julia a indexação inicia com `1`.
"""

# ╔═╡ 29698a56-3627-46a2-9c5c-029b2f92b606
@show languages[1]

# ╔═╡ 31b10f62-4e4a-4ab9-a81d-de7d0d9b756f
md"""
Vamos tentar modificar o segundo elemento da `Tuple`.

!!! tip "Sintaxe de controle de erros"

    Ainda é cedo para entrar nos detalhes, mas aproveite o bloco abaixo para ter um primeiro contato com a gestão de erros em Julia.
"""

# ╔═╡ e22b0b9e-813c-4528-aa09-d394c7d37da5
try
    languages[2] = "C++"
catch err
    println("Erro: $(err)")
end

# ╔═╡ c3658afa-1a9b-4cd2-951c-234a6b37c8fe
md"""
Existem certas subtilidades que você precisa saber sobre a imutabilidade. Observe o exemplo abaixo, aonde declaramos duas variáveis que são utilizadas para construir uma `Tuple` e então modificamos uma das variáveis: a `Tuple` continua com os valores originais do momento da sua construção.
"""

# ╔═╡ 0c29046a-2f4a-43b0-a670-2a2cfca22398
let
    a = 1
    b = 2

    test_tuple = (a, b)

    a = 5
    test_tuple
end

# ╔═╡ 245b49a4-c880-4b6e-bc08-99d8494264d6
md"""
!!! danger "Isso nem sempre é verdade!"

    Se o elemento compondo a `Tuple` for de um tipo mutável, como é o caso de `Array`'s, como veremos no que se segue, os elementos desta variável podem ser modificados e impactam a `Tuple` diretamente. Isso se dá porque neste caso a `Tuple` conserva a referência ao objeto em questão, e não uma cópia dos valores, como é o caso para tipos de base.
"""

# ╔═╡ bfc36ed8-9b17-4fbd-bea2-97141c2e83b8
let
    a = 1
    b = [1, 2]

    test_tuple = (a, b)

    b[1] = 999
    test_tuple
end

# ╔═╡ ce0750fd-ff28-4c77-9cd5-e99a6217d1ae
md"""
## *Named tuples*

Esta extensão à `Tuples` adiciona a possibilidade de acesso aos componentes por um *nome* no lugar de um simples índice -- que continua funcional como veremos abaixo. Esse tipo de estrutura é bastante útil quando necessitamos criar abstrações de coisas bastante simples para as quais a criação de um novo tipo não se justifica. Discutiremos mais tarde quando vamos estudar a criação de *novos tipos*.
"""

# ╔═╡ 55737e3e-d1df-4dc5-99bb-4ddc7c33145a
named_languages = (julia = "Julia", python = "Python")

# ╔═╡ 4b1aa7ab-dcdd-4f31-9acb-874293628981
md"""
Observe o fato de que agora os nomes utilizados no índex fazem parte do tipo.
"""

# ╔═╡ 23b805d5-8380-42ec-8750-89175477ac19
typeof(named_languages)

# ╔═╡ 0ff040a3-86cc-4ec7-bcc3-204efdc3bc55
md"""
Abaixo verificamos que além do acesso por nomes, `NamedTuples` também respeitam a ordem de declaração dos elementos: `:julia` é o primeiro índice. A sintaxe de acesso aos elementos neste caso é com a notação típica utilizando um ponto, comum a diversas linguages de programação.
"""

# ╔═╡ f1e6c01f-3b0b-4786-aad1-e2a0315bc989
named_languages[1] == named_languages.julia

# ╔═╡ 8df29d98-4128-4b30-af1b-6a8e4bd1a876
md"""
## Dicionários

Objetos do tipo `Dict` possuem a similaridade com `NamedTuples` em que seus elementos podem ser acessados por nome. No entanto a sintaxe é diferente e os valores desta estrutura são mutáveis.
"""

# ╔═╡ d5cf68d2-9d47-4458-b44c-29629840abba
organs = Dict("brain" => "🧠", "heart" => "❤")

# ╔═╡ d8e2af34-2840-4aae-921f-bc2535ff416c
md"""
O acesso a elementos se faz com colchetes contendo o índex como se segue:
"""

# ╔═╡ c253e7a0-878f-48ce-87e2-9c7d3267b960
organs["brain"]

# ╔═╡ ab4506c1-745d-408c-947a-c688935249fc
md"""
E como dissemos, os elementos são mutáveis: vamos atribuir um burrito ao cérebro.
"""

# ╔═╡ 6ed3740d-ca3b-4714-9dc7-9e08948a88b7
organs["brain"] = "🌯"

# ╔═╡ 8b799f5c-9ce7-4db8-b991-f49d885335d2
md"""
Não só os elementos, mas o dicionário como um todo, pode ser alterado. Para adicionar novos elementos simplesmente *acessamos* a palavra-chave e atribuímos um valor:
"""

# ╔═╡ f6e40b5b-a4e9-4a29-bf5d-81dbee87b18b
organs["eyes"] = "👀"

# ╔═╡ 039ea029-bcc5-4b99-83f8-de9d205c8a76
md"""
Internamente para evitar nova alocação de memória a cada tentativa de se adicionar um novo elemento, um dicionário realiza a alocação de `slots` que são renovados cada vez que sua capacidade é ultrapassada. Observe que a lista retornada abaixo é composta majoritariamente de `0x00`, que é o endereço de memória nulo, enquanto 3 elementos indicam um valor não-nulo, correspondendo aos elementos já adicionados ao dicionário. Disto vemos que adicionalmente um dicionário não preserva necessariamente uma sequência ordenada. Esses detalhes ultrapassam o presente escopo mas vão abrindo as portas para assuntos mais complexos.
"""

# ╔═╡ 0ef39afb-9727-4d0e-a803-aaa7be1c0478
organs.slots

# ╔═╡ 4e4c5a86-4081-439f-bbb2-ff2d7ea677ee
organs

# ╔═╡ 6affc4cc-0bbf-47cf-8b11-53d8b9f589ba
md"""
Para remover elementos utilizamos a função `pop!`. Por convenção em Julia, funções que terminam por um ponto de exclamação modificam os argumentos que são passados. No caso de `pop!` o dicionário é modificado e o valor de retorno é aquele do elemento removido.
"""

# ╔═╡ c82d7896-1b33-48b7-802e-3e257adc4410
pop!(organs, "brain")

# ╔═╡ be1b0abb-124b-40a0-9568-97d67a4593fd
md"""
A tentativa de remover um elemento inexistente obviamente conduz à um erro:
"""

# ╔═╡ 883c21f5-7e99-4807-bd9d-108e3073e025
try
    pop!(organs, "leg")
catch err
    println("Erro: $(err)")
end

# ╔═╡ 930089df-128e-4993-902a-5611b5a6884b
organs

# ╔═╡ e5fefe37-d51d-4dc4-94b2-00a1ade5d7db
md"""
Para evitar essa possibilidade podemos usar a função `haskey()`.
"""

# ╔═╡ c3108d00-657d-4711-8474-e8b22e4c9eeb
haskey(organs, "liver")

# ╔═╡ 5259ed97-19fc-4ee4-b568-ca9ed355eed8
md"""
Uma última coisa a notar é que *praticamente* qualquer tipo básico pode ser empregado como a chave de um dicionário em Julia. Veja o exemplo à seguir:
"""

# ╔═╡ 94a1caa0-153b-4208-a4f4-32bc2eaee2c9
music = Dict(:violin => "🎻", 1 => 2)

# ╔═╡ 2fc1eea1-661f-4b01-8890-d9a9a3157f6f
md"""
Como as chaves são de tipos diferentes (um `Symbol` e um `Int64`), assim como os valores (uma `String` e um `Int64`), a função `typeof()` nos retorna tipos `Any`.
"""

# ╔═╡ 10fb89d7-1401-4962-b740-a7ae858f4604
typeof(music)

# ╔═╡ 058aee92-02b3-4626-b4af-88d80b99f4f1
md"""
Ainda nos restam alguns detalhes e tipos de dados, mas o tutorial começa a ficar longo... e não queremos te perder por aqui!

Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─5b226140-525d-11ee-2e60-55f9f82f899e
# ╟─47fbe810-d30b-4f6a-93d1-2856fed594ca
# ╟─91d42cd2-1a69-4fbc-9edb-d4d607371c60
# ╠═692e4a6b-ee30-4ee7-a5ab-1f4ed5271e5a
# ╟─c750be52-e855-4190-a766-b1c518577965
# ╠═6f88eee0-a1a1-471f-8b28-9e197ae04499
# ╟─6a42cbf3-3e1f-40f9-aefe-c4688ec7c0ec
# ╠═29698a56-3627-46a2-9c5c-029b2f92b606
# ╟─31b10f62-4e4a-4ab9-a81d-de7d0d9b756f
# ╠═e22b0b9e-813c-4528-aa09-d394c7d37da5
# ╟─c3658afa-1a9b-4cd2-951c-234a6b37c8fe
# ╠═0c29046a-2f4a-43b0-a670-2a2cfca22398
# ╟─245b49a4-c880-4b6e-bc08-99d8494264d6
# ╠═bfc36ed8-9b17-4fbd-bea2-97141c2e83b8
# ╟─ce0750fd-ff28-4c77-9cd5-e99a6217d1ae
# ╠═55737e3e-d1df-4dc5-99bb-4ddc7c33145a
# ╟─4b1aa7ab-dcdd-4f31-9acb-874293628981
# ╠═23b805d5-8380-42ec-8750-89175477ac19
# ╟─0ff040a3-86cc-4ec7-bcc3-204efdc3bc55
# ╠═f1e6c01f-3b0b-4786-aad1-e2a0315bc989
# ╟─8df29d98-4128-4b30-af1b-6a8e4bd1a876
# ╠═d5cf68d2-9d47-4458-b44c-29629840abba
# ╟─d8e2af34-2840-4aae-921f-bc2535ff416c
# ╠═c253e7a0-878f-48ce-87e2-9c7d3267b960
# ╟─ab4506c1-745d-408c-947a-c688935249fc
# ╠═6ed3740d-ca3b-4714-9dc7-9e08948a88b7
# ╟─8b799f5c-9ce7-4db8-b991-f49d885335d2
# ╠═f6e40b5b-a4e9-4a29-bf5d-81dbee87b18b
# ╟─039ea029-bcc5-4b99-83f8-de9d205c8a76
# ╠═0ef39afb-9727-4d0e-a803-aaa7be1c0478
# ╠═4e4c5a86-4081-439f-bbb2-ff2d7ea677ee
# ╟─6affc4cc-0bbf-47cf-8b11-53d8b9f589ba
# ╠═c82d7896-1b33-48b7-802e-3e257adc4410
# ╟─be1b0abb-124b-40a0-9568-97d67a4593fd
# ╠═883c21f5-7e99-4807-bd9d-108e3073e025
# ╠═930089df-128e-4993-902a-5611b5a6884b
# ╟─e5fefe37-d51d-4dc4-94b2-00a1ade5d7db
# ╠═c3108d00-657d-4711-8474-e8b22e4c9eeb
# ╟─5259ed97-19fc-4ee4-b568-ca9ed355eed8
# ╠═94a1caa0-153b-4208-a4f4-32bc2eaee2c9
# ╟─2fc1eea1-661f-4b01-8890-d9a9a3157f6f
# ╠═10fb89d7-1401-4962-b740-a7ae858f4604
# ╟─058aee92-02b3-4626-b4af-88d80b99f4f1
# ╟─b9af06b7-88c7-40fe-8c0d-f2510c5ec36d
