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

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 5 - Laços e condicionais
"""

# ╔═╡ fa7a1a97-fde9-4b1a-884f-bf478b07b389
md"""
Até o momento introduzimos alguns tipos fundamentais e compostos de dados e elementos de operações sobre estes. Acontece que grande parte dos processos encontrados em ciência computacional são iterativos: seja um percurso de busca em um grafo, solução aproximada de um sistema linear, ou integração de uma equação diferencial. Para agregar esses elementos intrínsicos de algoritmos vamos agora abordar a temática de laços de iteração e expressões condicionais. A abordagem será bastante densificada e demandará prática pela parte do leitor para o domínio completo das sintaxes e técnicas.
"""

# ╔═╡ 265edda4-ea89-45c9-a0aa-11bf40091e73
md"""
## Laços predeterminados

Esses constituem laços que executarão um número definido e conhecido de vezes. O caso clássico é de um laço `for` que recupera sequencialmente os elementos de um *range* fornecido. Observe que em implementações do *mundo real* o *range* em questão é frequentemente fornecido pelo usuário e não programado em *duro* como `1:5` provido abaixo.

No laço abaixo percorremos os elementos da sequência provida, imprimindo-os em ordem.
"""

# ╔═╡ f4ab06d0-fb1f-4779-af64-6bcb37bf5cba
for k = 1:5
    println("k = $(k)")
end

# ╔═╡ aeb82d47-7999-4641-b3a8-6e0fd4a3d3c6
md"""
Alternativamente podemos usar uma sintaxe com a expressão `in`.
"""

# ╔═╡ fb0e0a6a-b5ff-4218-8f83-a0a0f5733e41
for k in 1:5
    println("k = $(k)")
end

# ╔═╡ 903c5cc5-09a5-49ab-81f6-d7034560f9ea
md"""
Como Julia é compatível com diversos símbolos matemáticos, o código abaixo também é válido e provê os mesmos resultados. Para entrar o símbolo ∈ digitamos seu valor em ``\LaTeX`` que é dado por `\in` e pressionamos <TAB> para realizar automaticamente a conversão.
"""

# ╔═╡ f0d96360-02ba-426d-bf0f-e6e7ce49b95c
for k ∈ 1:5
    println("k = $(k)")
end

# ╔═╡ 8e934606-43f2-4cf5-bc38-77e288a7bf29
md"""
Um elemento importante do laço `for` é que a variável `k` do laço não é visível fora de seu escopo (fechado pelo termo `end`). Verificamos abaixo que tentar acessar `k` produz um erro:
"""

# ╔═╡ 91050f2e-1eb8-46f6-b262-a57775ae1178
k

# ╔═╡ 0171741a-3e4b-4dc0-aea5-32cc0370290f
md"""
## Laços condicionais

Neste caso o termo *condicional* indica um critério de parada da execução do laço. Como dito na introdução, tomaremos uma abordagem densa. Para introduzir o laço `while` que repete um *bloco de execução enquanto* uma condição seja válida, vamos aproveitar e aprender de uma vez por todas sobre condicionais (`if elseif else`), continuação (`continue`) e saída (`break`) de laço.

Na maioria dos casos um laço `while` testa sobre uma variável já inicializada. Aqui criamos `count = 0`, variável que será em seguida usada no teste

```julia
while count < 100
    ...
end
```

Observe que a cada repetição incrementamos `count += 2`. Deve-se salienta aqui que o teste `count < 10` é avaliado antes da execução do bloco completo, ou seja, na ordem de leitura do código. Tente modificar `count = 10` na primeira linha do bloco e verá que o laço não executa. Verifique o **Exemplo 1** abaixo para confirmar o entendimento.
"""

# ╔═╡ 16c26354-f42f-4f64-85f0-c0ef63934b9a
begin
    count = 0

    while count < 10
        println("first line count ... $(count)")
        count += 2

        if count > 7
            println("leaving at ......... $(count)")
            break
        elseif count > 5
            continue
        else
            println("else count ......... $(count)")
        end

        count += 1
    end

    println("\nconfirm that $(count) is 8")
end

# ╔═╡ 95f92ac0-3975-4af8-bdce-208050822858
md"""
Dentro do corpo do laço temos um bloco `if-elseif-else` como

```julia
if condition
    break
elseif condition
    continue
else
    ...
end
```

Num tal bloco apenas a *primeira* condição avaliada como verdadeira é executada. Verifique o **Exemplo 2** abaixo para confirmar o entendimento.

Se a primeira condição no `if` for avaliada como verdadeira, a palavra-chave `break` força a saída do laço independentemente da avaliação da condição de `while count < 10`. Em computação numérica isso é usado para sair de um laço dado o encontro de uma condição de convergência, por exemplo.

No caso de se avaliar a condição de `elseif` como `true`, então o termo `continue` força o laço a retornar avaliar a primeira linha do bloco. Uma aplicação em que isso pode ser utilizado é quando uma condição intermediária de um cálculo não foi atendida e algum refino adicional é necessário antes de se perder tempo com a execução do que vem na sequência.

Se nenhuma das condições dos `if` ou `elseif` for atendida, a execução padrão de `else` é executada.
"""

# ╔═╡ d1ece605-704f-497c-b44d-aea32ee4fc07
md"""
**Exemplo 1:** o laço nunca executa.
"""

# ╔═╡ 6058f476-9849-4374-a5d2-9031e09f9d6a
let
    x = 2
    while x < 2
        x += 1
        println(x)
    end
    x
end

# ╔═╡ c1416c04-c963-4318-8911-e1f47c922175
md"""
**Exemplo 2:** o segundo ramo não executa.
"""

# ╔═╡ d8bf9c3a-bdd2-47c3-bb7a-86da59bd4b39
let
    x = 5.0
    if x > 1.0
        x = 1π
    elseif x > 2.0
        x = 2π
    else
        x = 0
    end
    x
end

# ╔═╡ 8bdea159-807f-4efd-b0b1-5909451ea4ce
md"""
Em Julia, como na maioria das linguagens, um teste `if` sem ramificações é possível.
"""

# ╔═╡ 6784ec8e-3479-4f8b-bb92-2f274a5a25e9
let
    x = 1
    if x > 0
        println(x)
    end
end

# ╔═╡ 08c06168-e6ec-413e-bac4-df6f2da51c85
md"""
Um bloco `if-elseif` também é possível sem o `else` com uma ação padrão.
"""

# ╔═╡ 0cc8eab0-c58e-4a33-b835-70e6ef934e21
let
    x = -1
    if x > 0
        println(x)
    elseif x < 0
        println(abs(x))
    end
end

# ╔═╡ d399025e-d1e7-4e8f-b05f-180f3acbaa12
md"""
Finalmente o caso trivial `if-else` também é possível.
"""

# ╔═╡ b6bfb58d-eebe-45ec-ad97-5b3551649699
let
    x = -1
    if x > 0
        println(x)
    else
        println(π)
    end
end

# ╔═╡ 417adb28-3380-44e1-a393-285256b4d6d9
md"""
## Exemplos com matrizes

Nesta seção vamos ilustrar algumas variantes do uso de laços usando matrizes. Comecemos criando uma matrix densa de dimensões `nrows` linhas e `ncols` colunas. Uma maneira de se alocar a memória necessária é com a função `fill` como se segue. Alternativamente poderíamos usar `zeros(Int64, (nrows, ncols))` como o mesmo resultado aqui.
"""

# ╔═╡ 6d100024-12fd-472a-a054-ca839bd746f6
begin
    nrows = 3
    ncols = 4
    A = fill(0, (nrows, ncols))
end

# ╔═╡ c7b18cf3-d1e5-4c99-882c-e87f7c2bda86
md"""
Vamos agora trabalhar para que cada elemento da matriz seja igual a soma do seus índices de linha e coluna, ou seja, ``a_{ij} = i + j``. Não citamos anteriormente, mais laços podem ser imbricados. Para ilustar, abaixo escrevemos um laço que itera sobre os índices `j` das colunas e no seu interior outro que avança `i` sobre as linhas.

Como vemos no resultado da execução o laço opera da seguinte maneira: fixa-se um valor de `j`, então se acessa o laço interno sobre `i` o qual toma todos os valores possíveis sequencialmente, então se avança o laço externo.
"""

# ╔═╡ 270c3239-209c-4b57-83d7-275896d977b5
let
    for j in 1:ncols
        for i in 1:nrows
            A[i, j] = i + j
            println("A[$(i), $(j)] = $(A[i, j])")
        end
    end
    A
end

# ╔═╡ 4ce872a9-d435-47d6-a6fe-7cfe16be6e8d
md"""
As ideias por trás da sintaxe acima não são exclusivas de Julia, laços similares sendo encontrados em grande parte das linguagens de programação. Uma especificidade de Julia é a possibilidade de se escrever de maneira mais compacta os laços acima como:
"""

# ╔═╡ e4428ffe-6180-4145-bed6-08ca5bd2f179
let
    for j in 1:ncols, i in 1:nrows
        A[i, j] = i + j
    end
    A
end

# ╔═╡ 0d333c12-d1e6-415f-a059-84e701ae722d
md"""
Essa sintaxe sucinta aliada ao conceito de *comprehensions* permite se criar uma matriz `B` identica a `A` em uma linha:
"""

# ╔═╡ 95114075-a01d-431a-8a28-1201768abb95
B = [i + j for i in 1:nrows, j in 1:ncols]

# ╔═╡ 8efe6053-a499-4967-a807-79a40fad994e
md"""
## Operador ternário
"""

# ╔═╡ 6ee8f21c-80c2-4807-adf8-adb0cba2c6ad
begin
    iamtrue = (1 < 2)
    iamfalse = (2 > 1)
end

# ╔═╡ e096e80a-c111-498a-b956-e69539d5c84a
answer1 = (1 < 2) ? iamtrue : iamfalse

# ╔═╡ 814a05d0-43cf-47a6-989b-c745805ce356
answer2 = if (1 < 2) iamtrue else iamfalse end

# ╔═╡ 9a2095f1-dff3-4aa7-b06d-d14e4f16213d
md"""
## Avaliação em curto-circuito
"""

# ╔═╡ d2be3957-13b2-4bf0-9b23-6b0406bdc070
(2 > 0) && println("2 é maior que 0")

# ╔═╡ 0cd7abb2-f06a-4ac7-bcde-dea4e5915c3e
(2 < 0) && println("esse código não executa")

# ╔═╡ a5324ed8-f1dd-4846-9340-cb09cebf9640
iamtrue || print("não será avaliado")

# ╔═╡ 50e2a402-af30-408d-9714-ee444fd072d5
iamfalse || print("será avaliado")

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─fa7a1a97-fde9-4b1a-884f-bf478b07b389
# ╟─265edda4-ea89-45c9-a0aa-11bf40091e73
# ╠═f4ab06d0-fb1f-4779-af64-6bcb37bf5cba
# ╟─aeb82d47-7999-4641-b3a8-6e0fd4a3d3c6
# ╠═fb0e0a6a-b5ff-4218-8f83-a0a0f5733e41
# ╟─903c5cc5-09a5-49ab-81f6-d7034560f9ea
# ╠═f0d96360-02ba-426d-bf0f-e6e7ce49b95c
# ╟─8e934606-43f2-4cf5-bc38-77e288a7bf29
# ╠═91050f2e-1eb8-46f6-b262-a57775ae1178
# ╟─0171741a-3e4b-4dc0-aea5-32cc0370290f
# ╠═16c26354-f42f-4f64-85f0-c0ef63934b9a
# ╟─95f92ac0-3975-4af8-bdce-208050822858
# ╟─d1ece605-704f-497c-b44d-aea32ee4fc07
# ╠═6058f476-9849-4374-a5d2-9031e09f9d6a
# ╟─c1416c04-c963-4318-8911-e1f47c922175
# ╠═d8bf9c3a-bdd2-47c3-bb7a-86da59bd4b39
# ╟─8bdea159-807f-4efd-b0b1-5909451ea4ce
# ╠═6784ec8e-3479-4f8b-bb92-2f274a5a25e9
# ╟─08c06168-e6ec-413e-bac4-df6f2da51c85
# ╠═0cc8eab0-c58e-4a33-b835-70e6ef934e21
# ╟─d399025e-d1e7-4e8f-b05f-180f3acbaa12
# ╠═b6bfb58d-eebe-45ec-ad97-5b3551649699
# ╟─417adb28-3380-44e1-a393-285256b4d6d9
# ╠═6d100024-12fd-472a-a054-ca839bd746f6
# ╟─c7b18cf3-d1e5-4c99-882c-e87f7c2bda86
# ╠═270c3239-209c-4b57-83d7-275896d977b5
# ╟─4ce872a9-d435-47d6-a6fe-7cfe16be6e8d
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╟─0d333c12-d1e6-415f-a059-84e701ae722d
# ╠═95114075-a01d-431a-8a28-1201768abb95
# ╟─8efe6053-a499-4967-a807-79a40fad994e
# ╠═6ee8f21c-80c2-4807-adf8-adb0cba2c6ad
# ╠═e096e80a-c111-498a-b956-e69539d5c84a
# ╠═814a05d0-43cf-47a6-989b-c745805ce356
# ╟─9a2095f1-dff3-4aa7-b06d-d14e4f16213d
# ╠═d2be3957-13b2-4bf0-9b23-6b0406bdc070
# ╠═0cd7abb2-f06a-4ac7-bcde-dea4e5915c3e
# ╠═a5324ed8-f1dd-4846-9340-cb09cebf9640
# ╠═50e2a402-af30-408d-9714-ee444fd072d5
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
