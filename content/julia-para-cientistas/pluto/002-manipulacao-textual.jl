### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 54b47b10-94a7-4745-b8e2-ce033d9b4aa1
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    using Printf
    using PlutoUI: TableOfContents
    TableOfContents(title = "Tópicos")
end

# ╔═╡ 82fadcf2-0710-413e-9be1-3054d8a55fca
md"""
# Parte 2 - Manipulação textual
"""

# ╔═╡ ec8d6dd0-525a-11ee-3551-07f2ed0e3cd9
md"""
Uma habilidade frequentemente negligenciada pelo grande público de computação científica nos seus primeiros passos é a capacidade de manipulação textual. Não podemos esquecer que programas necessitam interfaces pelas quais alimentamos as condições do problema a ser solucionado e resultados são esperados ao fim da computação. Para problemas que tomam um tempo computacional importante, é extremamente útil ter mensagens de estado de progresso. Nessa seção introduzimos os primeiros elementos necessários para a manipulação textual em Julia.

Uma variável do tipo `String` declara-se com aspas duplas, como vimos inicialmente no programa `Hello, World!`. Deve-se tomar cuidado em Julia pois caracteres individuais (tipo `Char`) tem um significado distinto de uma coleção de caracteres `String`.

Por exemplo, avaliando o tipo de `'a'` obtemos:
"""

# ╔═╡ 794e2cd4-ee49-4f8c-91fa-7f5f8e225988
typeof('a')

# ╔═╡ ecbabb44-906a-4912-a808-20c6d0c92db6
md"""
## Declaração de Strings

Estudaremos caracteres mais tarde. Por enquanto nos interessamos por expressões como:
"""

# ╔═╡ 4b026ca7-d945-40f3-ac01-426b233e6ae6
text1 = "Olá, eu sou uma String"

# ╔═╡ 548cb583-eff4-44d0-afc9-4d317c9199b5
typeof(text1)

# ╔═╡ 6c074e35-ac22-4b39-a156-26030a680cf0
md"""
Eventualmente necessitamos utilizar aspas duplas no interior do texto. Neste caso, a primeira solução provida por Julia é utilizar três aspas duplas para a abertura e fechamento do texto. Observamos abaixo que o texto é transformado para adicionar uma barra invertida antes das aspas que estão no corpo do texto.
"""

# ╔═╡ 4d6afa66-bd15-4125-b012-0647983ffb6a
text2 = """Eu sou uma String que pode incluir "aspas duplas"."""

# ╔═╡ 5432a596-842a-4529-9c94-e940279c4099
md"""
Neste caso, Julia aplicou automaticamente um *caractere de escape* no símbolo a ser interpretado de maneira especial. Existem diversos casos aonde a aplicação manual pode ser útil, por exemplo quando entrando texto em UNICODE por códigos. No exemplo abaixo utilizamos a técnica manual com o texto precedente.
"""

# ╔═╡ be426c2e-39dd-4d3d-b5cb-dc668ff98d2e
text3 = "Eu sou uma String que pode incluir \"aspas duplas\"."

# ╔═╡ e6fb3d10-dca8-45c9-8476-ed5281535bf9
md"""
Para averiguar o funcionamento correto, testamos de imprimir `text3` no terminal.
"""

# ╔═╡ 163135ca-1218-4ae2-b3cc-e0e02d83ead7
println(text3)

# ╔═╡ d62e951b-0fab-49ab-b9ee-3173ebfa117a
md"""
O exemplo a seguir ilustra o uso do caracter de escape para representar UNICODE.
"""

# ╔═╡ 3b26710e-2782-40f2-b414-76903a909460
pounds = "\U000A3"

# ╔═╡ 109337f5-758b-4578-870c-15134be44262
md"""
## Interpolação de Strings

Para gerar mensagens automáticas frequentemente dispomos de um texto que deve ter partes substituidas. Ilustramos abaixo o uso de um símbolo de dólar $ seguido de parêntesis com a variável de substituição para realizar o que chamamos de *interpolação textual*.

!!! tip "Múltiplas variáveis em uma linha"

    Observe aqui a introdução da declaração de múltiplas variáveis em uma linha.
"""

# ╔═╡ c57cff4e-c144-42ff-a2bf-dd9a0ff44305
begin
    name, age = "Walter", 34
    println("Olá, $(name), você tem $(age) anos!")
end

# ╔═╡ ad75f4d4-4c39-49c3-892c-3977b52f77ba
md"""
!!! warning "Prática não recomendada"

    Para nomes simples de variáveis e sem formatação explícita, o código a seguir também é valido, mas é pode ser considerado uma má prática de programação.
"""

# ╔═╡ d3ba5e50-3a8a-4fb2-a59b-0cf5e30739b2
println("Olá, $name, você tem $age anos!")

# ╔═╡ 31429329-bd9b-4422-8afc-1b7e84d4d889
md"""
Em alguns casos, como na contagem de operações em um laço, podemos também realizar operações e avaliação de funções diretamente na `String` sendo interpolada.
"""

# ╔═╡ 864e53f2-6d21-4934-aad5-a880cdff920d
println("Também é possível realizar operações, e.g 2³ = $(2^3).")

# ╔═╡ 16f92129-7642-4e9b-bd28-715567eb5f14
md"""
## Formatação de números
"""

# ╔═╡ 2c84fb97-67fa-478f-8261-603faf317795
@sprintf("%g", 12.0)

# ╔═╡ 37fce998-102c-4dcd-9e7e-270875cb3206
@sprintf("%.6f", 12.0)

# ╔═╡ e789b407-e99c-460c-8a3d-02233dddf13c
@sprintf("%.6e", 12.0)

# ╔═╡ 09fc99c8-f083-4446-a76b-e777e6d5344b
@sprintf("%15.8e %15.8E", 12.0, 13)

# ╔═╡ a42f4ca7-2f05-43e1-8dbb-f7c2a1910635
@sprintf("%6d", 12.0)

# ╔═╡ 16c4da7b-7662-48fb-a5ed-924ea38946e2
@sprintf("%06d", 12)

# ╔═╡ 10b5affc-a1d0-4fef-a384-7e34926768fa
md"""
## Concatenação de Strings

Na maioria das linguagens de programação a concatenação textual se faz com o símbolo de adição `+`. Data suas origens já voltadas para a computação numérica, Julia adota para esta finalidade o asterísco `*` utilizado para multiplicação, o que se deve à sua utilização em álgebra abstrata para indicar operações não-comutativas, como clarificado no [manual](https://docs.julialang.org/en/v1/manual/strings/#man-concatenation).
"""

# ╔═╡ df66434b-24d9-4ed8-bac9-36c27256c464
bark = "Au!"

# ╔═╡ 896325c1-2e20-4fd1-bc12-61e4a1529c03
bark * bark * bark

# ╔═╡ 10fe8692-3213-4c54-b7cd-7948a0ada44c
md"""
O circunflexo `^` utilizado para a exponenciação também pode ser utilizado para uma repetição múltipla de uma data `String`.
"""

# ╔═╡ af6a5902-c4fb-42b4-a3fd-35e6f0f849e3
bark^10

# ╔═╡ a7cde7b1-4025-43a9-b506-72ed164e3213
md"""
Finalmente o construtor `string()` permite de contactenar não somente `Strings`, mas simultanêamente `Strings` e objetos que suportam conversão textual.
"""

# ╔═╡ 24a3311b-7196-44c2-bad8-520d6536d1a8
string("Unido um número ", 10, " ou ", 12.0, " a outro ", "texto!")

# ╔═╡ 65937ef7-de46-4449-a077-024a680e049f
md"""
## Funções básicas

Diversos outros [métodos](https://docs.julialang.org/en/v1/base/strings/) são disponíveis para Strings. Dado o suporte UNICODE de Julia, devemos enfatizar com o uso de `length()` e `sizeof()` que o comprimento textual de uma `String` pode não corresponder ao seu tamanho em *bytes*, o que pode levar ao usuário desavisado a erros numa tentativa de acesso à caracteres por índices.
"""

# ╔═╡ 7904de54-7459-4a8a-b3f3-c54ebe820c5c
length("∀"), sizeof("∀")

# ╔═╡ 8ad7e9bc-572b-4ccd-b283-88e3477c1e6c
md"""
Uma função que é bastante útil é `startswith()` que permite verificar se uma `String` inicia por um outro bloco de caracteres visado. Testes mais complexos podem ser feitos com [expressões regulares](https://docs.julialang.org/en/v1/base/strings/#Base.Regex), como veremos mais tarde.
"""

# ╔═╡ 2963aaae-bd1d-4ab0-beb2-277a59b05757
startswith("align", "al")

# ╔═╡ cdf074bb-38af-4522-b32c-2247572cd451
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─82fadcf2-0710-413e-9be1-3054d8a55fca
# ╠═54b47b10-94a7-4745-b8e2-ce033d9b4aa1
# ╟─ec8d6dd0-525a-11ee-3551-07f2ed0e3cd9
# ╠═794e2cd4-ee49-4f8c-91fa-7f5f8e225988
# ╟─ecbabb44-906a-4912-a808-20c6d0c92db6
# ╠═4b026ca7-d945-40f3-ac01-426b233e6ae6
# ╠═548cb583-eff4-44d0-afc9-4d317c9199b5
# ╟─6c074e35-ac22-4b39-a156-26030a680cf0
# ╠═4d6afa66-bd15-4125-b012-0647983ffb6a
# ╟─5432a596-842a-4529-9c94-e940279c4099
# ╠═be426c2e-39dd-4d3d-b5cb-dc668ff98d2e
# ╟─e6fb3d10-dca8-45c9-8476-ed5281535bf9
# ╠═163135ca-1218-4ae2-b3cc-e0e02d83ead7
# ╟─d62e951b-0fab-49ab-b9ee-3173ebfa117a
# ╠═3b26710e-2782-40f2-b414-76903a909460
# ╟─109337f5-758b-4578-870c-15134be44262
# ╠═c57cff4e-c144-42ff-a2bf-dd9a0ff44305
# ╟─ad75f4d4-4c39-49c3-892c-3977b52f77ba
# ╠═d3ba5e50-3a8a-4fb2-a59b-0cf5e30739b2
# ╟─31429329-bd9b-4422-8afc-1b7e84d4d889
# ╠═864e53f2-6d21-4934-aad5-a880cdff920d
# ╟─16f92129-7642-4e9b-bd28-715567eb5f14
# ╠═2c84fb97-67fa-478f-8261-603faf317795
# ╠═37fce998-102c-4dcd-9e7e-270875cb3206
# ╠═e789b407-e99c-460c-8a3d-02233dddf13c
# ╠═09fc99c8-f083-4446-a76b-e777e6d5344b
# ╠═a42f4ca7-2f05-43e1-8dbb-f7c2a1910635
# ╠═16c4da7b-7662-48fb-a5ed-924ea38946e2
# ╟─10b5affc-a1d0-4fef-a384-7e34926768fa
# ╠═df66434b-24d9-4ed8-bac9-36c27256c464
# ╠═896325c1-2e20-4fd1-bc12-61e4a1529c03
# ╟─10fe8692-3213-4c54-b7cd-7948a0ada44c
# ╠═af6a5902-c4fb-42b4-a3fd-35e6f0f849e3
# ╟─a7cde7b1-4025-43a9-b506-72ed164e3213
# ╠═24a3311b-7196-44c2-bad8-520d6536d1a8
# ╟─65937ef7-de46-4449-a077-024a680e049f
# ╠═7904de54-7459-4a8a-b3f3-c54ebe820c5c
# ╟─8ad7e9bc-572b-4ccd-b283-88e3477c1e6c
# ╠═2963aaae-bd1d-4ab0-beb2-277a59b05757
# ╟─cdf074bb-38af-4522-b32c-2247572cd451
