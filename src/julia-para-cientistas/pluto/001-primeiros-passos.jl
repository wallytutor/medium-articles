### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ e50ea7f1-a3ed-40ff-8ad6-86de59faf721
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    import PlutoUI
    PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ 2e1fa6ce-5258-11ee-1103-a714acd93977
md"""
# Parte 1 - Primeiros passos
"""

# ╔═╡ 51fed706-d453-4144-97e3-04e2b45ed203
md"""
Tradicionalmente, o primeiro contato com uma linguagem de programação se faz através da implementação se seu programa `Hello, World!` que nada mas faz que imprimir esta sentença em um terminal. Em Julia usamos a função `println()` contendo o texto a ser apresentado entre aspas duplas (veremos mais sobre texto na próxima seção) para implementar este *programa*, como se segue:
"""

# ╔═╡ c41d15b4-c653-4553-b99b-809f1850d2c5
println("Olá, Mundo!")

# ╔═╡ a1d076a9-b7f4-403c-94b5-69fafab14fcf
md"""
## Tipos básicos

O interesse principal de programação é o fato de podermos *atribuir* valores à *nomes* e em seguida realizar a manipulação necessária. Uma vez implementado o *algoritmo*, podemos simplesmente modificar os valores e *reutilizá-lo*.

Esse processo chama-se *atribuição de variáveis* e é realizado utilizando o símbolo de igualdade `=` com o nome da variável à esquerda e seu valor a direita.

!!! warning "Atenção"

    Veremos mais tarde que a comparação de igualdade se faz com um duplo sinal `==` e que devemos tomar cuidado com isso quando estamos tendo um primeiro contato com programação. A igualdade simples `=` é, na maioria das linguagens modernas, um símbolo de atribuição de valor.

Vamos criar uma variávei `favorite_number_1` e atribuir seu valor:
"""

# ╔═╡ 9e2e30c6-4fec-4eea-9e78-b4763550edb9
favorite_number_1 = 13

# ╔═╡ 7d4b119b-de08-4b4a-9aec-0b7b9551f55c
md"""
Agora poderíamos realizar operações com `favorite_number_1`. Faremos isso mais tarde com outras variáveis porque antes é importante de introduzirmos o conceito de *tipos*. Toda variável é de um dado tipo de dado, o que implica o tamanho (fixo ou variável) de sua representação na memória do computador. Com a função `typeof()` inspecionamos o tipo de uma variável.

Vemos que o tipo de 13 -- um número inteiro -- é representado em Julia por `Int64`.
"""

# ╔═╡ f7363883-5915-48dd-8f16-d2336fedd766
typeof(favorite_number_1)

# ╔═╡ 92600f53-6b78-44c5-8afb-e45b8ababbd0
md"""
Existem diversos [tipos numéricos suportados por Julia](https://docs.julialang.org/en/v1/base/numbers/), mas aqui vamos ver somente os tipos básicos utilizados mais comumente em computação numérica. Atribuindo um valor aproximado de π a `favorite_number_2` obtemos um *objeto* de tipo `Float64`, utilizado para representar números reais em *dupla precisão*.

!!! nota "Aritmética de ponto flutuante de dupla precisão"

    A maioria dos números reais não podem ser representados com precisão arbitrária em um computador. Um número real em dupla precisão é representado com 64 bits na memória. Representações de precisão arbitrária são hoje em dia disponíveis mas tem um custo de operação proibitivo para a maioria das aplicações. A matemática necessária para a compreensão da representação na memória é discutida no livro texto.
"""

# ╔═╡ 43715af2-4a56-4d2a-9f3b-ac0768a4efbc
begin
    favorite_number_2 = 3.141592
    typeof(favorite_number_2)
end

# ╔═╡ ebf1808c-3227-46cb-97f6-58192d605444
md"""
Uma particularidade de Julia dado o seu caráter científico é o suporte à números irracionais. Podemos assim representar `π` de maneira otimizada como discutiremos num momento oportuno.

!!! tip "Caractéres especiais"

    Julia suporta progração usando quaisquer caractéres UNICODE. Isso inclui letras gregas, subscritos, símbolos matemáticos... Em *notebooks* Pluto ou em editores conectados à um *Julia Language Server* podemos entrar esses símbolos digitando seu equivalente em ``\LaTeX`` e pressionando a tecla <TAB>. Uma lista detalhada de caracteres suportados é apresentada [aqui](https://docs.julialang.org/en/v1/manual/unicode-input/).
"""

# ╔═╡ 8c34b2d1-dba3-45f8-8f43-536294e4d12d
begin
    favorite_number_3 = π
    typeof(favorite_number_3)
end

# ╔═╡ 41330e05-c1b9-477f-aee1-58c43af5e20c
md"""
Por exemplo, também temos o número de Euler representado como irracional. Como este número é representado pela letra `e`, para evitar conflitos com outras variáveis ele precisa ser acessado pelo caminho completo do [módulo definindo](https://docs.julialang.org/en/v1/base/numbers/#Base.MathConstants.%E2%84%AF) as constantes matemáticas.
"""

# ╔═╡ 8cb44883-b5e8-431a-9505-e354822f75da
begin
    favorite_number_4 = MathConstants.e
    typeof(favorite_number_4)
end

# ╔═╡ c25d18a7-8c8e-408a-8e92-0d531d0d78e0
md"""
Outro exemplo de constante irracional é a proporção áurea.
"""

# ╔═╡ 857ba47d-dbec-4ebc-982b-1746f1de5158
Base.MathConstants.golden

# ╔═╡ 3cc676a2-0eaa-420b-a672-8cb204b80696
md"""
A lista completa pode ser acessada com `names(module)` como se segue:
"""

# ╔═╡ 46b90978-cc93-45f3-9c62-40761a4ff69b
names(MathConstants)

# ╔═╡ 53b19e61-26a0-4e33-9c9b-5dd75192aa5e
md"""
O nome de variáveis também pode ser um emoji -- evite isso em programas, evidentemente.
"""

# ╔═╡ 2db5936a-da59-4378-a4ea-e6ada3882c6e
begin
    🥰 = "Julia"
    typeof(🥰)
end

# ╔═╡ 3ac270cc-d519-449e-9426-e773969618be
md"""
Usando essa possibilidade podemos brincar com o conceito como abaixo:
"""

# ╔═╡ 34f2ed3b-8317-4f2f-995d-dcecb39d2244
begin
    🐶 = 1
    😀 = 0
    😞 = -1

    # Vamos ver se a expressão a seguir é avaliada como verdadeira.
    # Todo texto após um `#` é considerado um comentário por Julia.
    # Abaixo vemos um novo operador de comparação de igualdade `==`.
    🐶 + 😞 == 😀
end

# ╔═╡ 31cf13c4-38e0-4d7a-a122-8a89cff94833
md"""
## Comentários

Vimos no bloco acima o primeiro bloco de comentários identificado por linhas iniciando com `#`. Como comentários não são expressões, vemos abaixo que múltiplas linhas são aceitas em uma única célula contando que haja apenas uma expressão no contexto. Comentários são desejáveis para que entendamos mais tarde qual era o objetivo de uma dada operação. Confie em mim, anos mais tarde um código que parecia evidente no momento da sua escritura, quando você tem o conceito a ser expresso fresco na cabeça, pode parecer um texto em [basco](https://pt.wikipedia.org/wiki/L%C3%ADngua_basca).
"""

# ╔═╡ 44768be4-581f-43b9-91ee-835c2ba15ee2
# Em Julia, toda linha começando por um `#` é considerada um
# comentário. Comentários após declarações também são possíveis:

comment = 1;  # Um comentário após uma declaração.

#=
Comentários de multiplas linhas também podem ser escritos usando
o par `#=` seguido de texto e então `=#` no lugar de iniciar
diversas linhas com `#`, o que torna sua edição mais fácil.
=#

# ╔═╡ 534f3980-0ba1-44f3-b566-f6216ac7f71f
md"""
## Aritmética básica

Podemos usar Julia em modo interativo como uma calculadora.

Vemos abaixo a adição `+` e subtração `-`,...
"""

# ╔═╡ 296330f0-673e-4cda-aad0-55aee60f9069
1 + 3, 1 - 3

# ╔═╡ 8e87cde1-573d-430b-a2c2-83993aebbfdd
md"""
... multiplicação `*` e divisão `/`, ...
"""

# ╔═╡ 560375c0-2f8a-49c9-95ec-51ef722962c1
2 * 5, 2 / 3

# ╔═╡ aa5fc3cf-163c-4001-b90e-29b2a46191c2
md"""
... e uma comparação entre a divisão racional e normal.
"""

# ╔═╡ 6d67bc8e-707e-4d36-90f6-af65ea235822
2 // 3 * 3, 2 / 3 * 3

# ╔═╡ b6f7c522-8391-43f8-b9d7-da49acc66e16
md"""
Julia possui suporte incluso a números racionais, o que pode ser útil para evitar propagação de erros em vários contextos aonde frações de números inteiros podem eventualmente ser simplificadas. Verificamos o tipo da variável com `typeof()`.
"""

# ╔═╡ d052be84-604c-4c0d-a7ea-4a55131a3794
typeof(2 // 3)

# ╔═╡ a6d41cc3-a8c1-498a-9fc9-cf464d27f181
md"""
O quociente de uma divisão inteira pode ser calculado com a função `div()`. Para aproximar essa expressão da notação matemática é também possível utilizar `2 ÷ 3`.
"""

# ╔═╡ 6207e05e-545d-419a-bc1a-8e6cb7b2fe48
div(2, 3)

# ╔═╡ 4203496e-7ddd-4fb8-a23a-1b8a84c93514
md"""
O resto de uma divisão pode ser encontrado com `mod()`. Novamente essa função possui uma sintaxe alternativa -- como em diversas outras linguagem nesse caso -- utilizando o símbolo de percentual como em `11 % 3`.
"""

# ╔═╡ 24404675-085a-488c-8e3b-d276bd1f2e26
mod(11, 3)

# ╔═╡ c76a906e-bef9-4a44-b32a-6e211450d994
md"""
Para concluir as operações básicas, incluímos ainda a expoenciação `^`.
"""

# ╔═╡ ed24a9ed-d821-4ad4-9b09-281b67364d58
2^5

# ╔═╡ 8a43397f-3f16-4e59-9bef-232437edf90a
md"""
Outra particularidade de Julia é o suporte à multiplicação implícita -- use essa funcionalidade com cuidado, erros estranhos podem ocorrer em programas complexos.
"""

# ╔═╡ 6e482723-609f-4ac7-9f2d-fd833a6a9251
begin
    a_number = 234.0
    2a_number
end

# ╔═╡ b8c8c94d-2bb5-463f-81c1-e10876efda68
md"""
O valor de π também pode ser representado por `pi`. Observe que a multiplicação de um inteiro `2` por `pi` (de tipo $(typeof(pi))) produz como resultado um número `Float64`.
"""

# ╔═╡ b15f5c36-4ede-4ecb-9247-c7726329eb0c
typeof(2pi)

# ╔═╡ 7b1666b8-0a0a-4109-9e6f-61807dd16501
md"""
## Conversão explícita

Se um número real pode ser representado por um tipo inteiro, podemos utilizar a função `convert()` para a transformação desejada. Caso a representação integral não seja possível, talvez você possa obter o resultado almejado usando uma das funções `round()`, `floor()`, ou `ceil()`, as quais você pode verificar na documentação da linguagem.
"""

# ╔═╡ 910e6a75-9fdb-4333-8c32-7a1fdca0b6bb
convert(Int64, a_number) == 234

# ╔═╡ 5b690d31-20e6-49a4-99a6-63e1377966ef
md"""
Funções em Julia também podem ser aplicadas a múltiplos argumentos de maneira sequencial em se adicionando um ponto entre o nome da função e o parêntesis de abertura dos argumentos. Por exemplo, para trabalhar com cores RGB é usual empregar-se o tipo `UInt8` que é limitado à 255, reduzindo a sua representação em memória.

A conversão abaixo se aplica a sequência de números `color` individualmente.
"""

# ╔═╡ 74232fe5-3f71-4733-a283-bdab7194c02b
begin
    color = (255.0, 20.0, 21.0)
    convert.(UInt8, color)
end

# ╔═╡ f9213fc8-e881-4d3b-9437-a5cc3093dae1
md"""
Finalmente, formas textuais podem ser interpretadas como números usando `parse()`.
"""

# ╔═╡ 96cb2bdc-8bcf-4b48-91d0-dad5fe035999
parse(Int64, "1")

# ╔═╡ 186bc64c-230b-440b-ac40-68ad33aa9333
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─2e1fa6ce-5258-11ee-1103-a714acd93977
# ╠═e50ea7f1-a3ed-40ff-8ad6-86de59faf721
# ╟─51fed706-d453-4144-97e3-04e2b45ed203
# ╠═c41d15b4-c653-4553-b99b-809f1850d2c5
# ╟─a1d076a9-b7f4-403c-94b5-69fafab14fcf
# ╠═9e2e30c6-4fec-4eea-9e78-b4763550edb9
# ╟─7d4b119b-de08-4b4a-9aec-0b7b9551f55c
# ╠═f7363883-5915-48dd-8f16-d2336fedd766
# ╟─92600f53-6b78-44c5-8afb-e45b8ababbd0
# ╠═43715af2-4a56-4d2a-9f3b-ac0768a4efbc
# ╟─ebf1808c-3227-46cb-97f6-58192d605444
# ╠═8c34b2d1-dba3-45f8-8f43-536294e4d12d
# ╟─41330e05-c1b9-477f-aee1-58c43af5e20c
# ╠═8cb44883-b5e8-431a-9505-e354822f75da
# ╟─c25d18a7-8c8e-408a-8e92-0d531d0d78e0
# ╠═857ba47d-dbec-4ebc-982b-1746f1de5158
# ╟─3cc676a2-0eaa-420b-a672-8cb204b80696
# ╠═46b90978-cc93-45f3-9c62-40761a4ff69b
# ╟─53b19e61-26a0-4e33-9c9b-5dd75192aa5e
# ╠═2db5936a-da59-4378-a4ea-e6ada3882c6e
# ╟─3ac270cc-d519-449e-9426-e773969618be
# ╠═34f2ed3b-8317-4f2f-995d-dcecb39d2244
# ╟─31cf13c4-38e0-4d7a-a122-8a89cff94833
# ╠═44768be4-581f-43b9-91ee-835c2ba15ee2
# ╟─534f3980-0ba1-44f3-b566-f6216ac7f71f
# ╠═296330f0-673e-4cda-aad0-55aee60f9069
# ╟─8e87cde1-573d-430b-a2c2-83993aebbfdd
# ╠═560375c0-2f8a-49c9-95ec-51ef722962c1
# ╟─aa5fc3cf-163c-4001-b90e-29b2a46191c2
# ╠═6d67bc8e-707e-4d36-90f6-af65ea235822
# ╟─b6f7c522-8391-43f8-b9d7-da49acc66e16
# ╠═d052be84-604c-4c0d-a7ea-4a55131a3794
# ╟─a6d41cc3-a8c1-498a-9fc9-cf464d27f181
# ╠═6207e05e-545d-419a-bc1a-8e6cb7b2fe48
# ╟─4203496e-7ddd-4fb8-a23a-1b8a84c93514
# ╠═24404675-085a-488c-8e3b-d276bd1f2e26
# ╟─c76a906e-bef9-4a44-b32a-6e211450d994
# ╠═ed24a9ed-d821-4ad4-9b09-281b67364d58
# ╟─8a43397f-3f16-4e59-9bef-232437edf90a
# ╠═6e482723-609f-4ac7-9f2d-fd833a6a9251
# ╟─b8c8c94d-2bb5-463f-81c1-e10876efda68
# ╠═b15f5c36-4ede-4ecb-9247-c7726329eb0c
# ╟─7b1666b8-0a0a-4109-9e6f-61807dd16501
# ╠═910e6a75-9fdb-4333-8c32-7a1fdca0b6bb
# ╟─5b690d31-20e6-49a4-99a6-63e1377966ef
# ╠═74232fe5-3f71-4733-a283-bdab7194c02b
# ╟─f9213fc8-e881-4d3b-9437-a5cc3093dae1
# ╠═96cb2bdc-8bcf-4b48-91d0-dad5fe035999
# ╟─186bc64c-230b-440b-ac40-68ad33aa9333
