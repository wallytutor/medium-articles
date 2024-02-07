---
title  : Laços e condicionais
author : Walter Dal'Maz Silva
date   : `j import Dates; Dates.Date(Dates.now())`
weave_options:
  error: false
  term: false
  wrap: true
  line_width: 100
---

# Parte 5 - Laços e condicionais

Até o momento introduzimos alguns tipos fundamentais e compostos de dados e elementos de operações sobre estes. Acontece que grande parte dos processos encontrados em ciência computacional são iterativos: seja um percurso de busca em um grafo, solução aproximada de um sistema linear, ou integração de uma equação diferencial. Para agregar esses elementos intrínsicos de algoritmos vamos agora abordar a temática de laços de iteração e expressões condicionais. A abordagem será bastante densificada e demandará prática pela parte do leitor para o domínio completo das sintaxes e técnicas.

## Laços predeterminados

Esses constituem laços que executarão um número definido e conhecido de vezes. O caso clássico é de um laço `for` que recupera sequencialmente os elementos de um *range* fornecido. Observe que em implementações do *mundo real* o *range* em questão é frequentemente fornecido pelo usuário e não programado em *duro* como `1:5` provido abaixo.

No laço abaixo percorremos os elementos da sequência provida, imprimindo-os em ordem.


for k = 1:5
    println("k = $(k)")
end


Alternativamente podemos usar uma sintaxe com a expressão `in`.


for k in 1:5
    println("k = $(k)")
end


Como Julia é compatível com diversos símbolos matemáticos, o código abaixo também é válido e provê os mesmos resultados. Para entrar o símbolo ∈ digitamos seu valor em ``\LaTeX`` que é dado por `\in` e pressionamos <TAB> para realizar automaticamente a conversão.


for k ∈ 1:5
    println("k = $(k)")
end


Um elemento importante do laço `for` é que a variável `k` do laço não é visível fora de seu escopo (fechado pelo termo `end`). Verificamos abaixo que tentar acessar `k` produz um erro:


k


## Laços condicionais

Neste caso o termo *condicional* indica um critério de parada da execução do laço. Como dito na introdução, tomaremos uma abordagem densa. Para introduzir o laço `while` que repete um *bloco de execução enquanto* uma condição seja válida, vamos aproveitar e aprender de uma vez por todas sobre condicionais (`if elseif else`), continuação (`continue`) e saída (`break`) de laço.

Na maioria dos casos um laço `while` testa sobre uma variável já inicializada. Aqui criamos `count = 0`, variável que será em seguida usada no teste

```julia
while count < 100
    ...
end
```

Observe que a cada repetição incrementamos `count += 2`. Deve-se salienta aqui que o teste `count < 10` é avaliado antes da execução do bloco completo, ou seja, na ordem de leitura do código. Tente modificar `count = 10` na primeira linha do bloco e verá que o laço não executa. Verifique o **Exemplo 1** abaixo para confirmar o entendimento.


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



**Exemplo 1:** o laço nunca executa.


let
    x = 2
    while x < 2
        x += 1
        println(x)
    end
    x
end


**Exemplo 2:** o segundo ramo não executa.


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


Em Julia, como na maioria das linguagens, um teste `if` sem ramificações é possível.


let
    x = 1
    if x > 0
        println(x)
    end
end


Um bloco `if-elseif` também é possível sem o `else` com uma ação padrão.


let
    x = -1
    if x > 0
        println(x)
    elseif x < 0
        println(abs(x))
    end
end


Finalmente o caso trivial `if-else` também é possível.


let
    x = -1
    if x > 0
        println(x)
    else
        println(π)
    end
end


## Exemplos com matrizes

Nesta seção vamos ilustrar algumas variantes do uso de laços usando matrizes. Comecemos criando uma matrix densa de dimensões `nrows` linhas e `ncols` colunas. Uma maneira de se alocar a memória necessária é com a função `fill` como se segue. Alternativamente poderíamos usar `zeros(Int64, (nrows, ncols))` como o mesmo resultado aqui.


begin
    nrows = 3
    ncols = 4
    A = fill(0, (nrows, ncols))
end


Vamos agora trabalhar para que cada elemento da matriz seja igual a soma do seus índices de linha e coluna, ou seja, ``a_{ij} = i + j``. Não citamos anteriormente, mais laços podem ser imbricados. Para ilustar, abaixo escrevemos um laço que itera sobre os índices `j` das colunas e no seu interior outro que avança `i` sobre as linhas.

Como vemos no resultado da execução o laço opera da seguinte maneira: fixa-se um valor de `j`, então se acessa o laço interno sobre `i` o qual toma todos os valores possíveis sequencialmente, então se avança o laço externo.


let
    for j in 1:ncols
        for i in 1:nrows
            A[i, j] = i + j
            println("A[$(i), $(j)] = $(A[i, j])")
        end
    end
    A
end


As ideias por trás da sintaxe acima não são exclusivas de Julia, laços similares sendo encontrados em grande parte das linguagens de programação. Uma especificidade de Julia é a possibilidade de se escrever de maneira mais compacta os laços acima como:


let
    for j in 1:ncols, i in 1:nrows
        A[i, j] = i + j
    end
    A
end


Essa sintaxe sucinta aliada ao conceito de *comprehensions* permite se criar uma matriz `B` identica a `A` em uma linha:


B = [i + j for i in 1:nrows, j in 1:ncols]


## Operador ternário


begin
    iamtrue = (1 < 2)
    iamfalse = (2 > 1)
end

answer1 = (1 < 2) ? iamtrue : iamfalse

answer2 = if (1 < 2) iamtrue else iamfalse end


## Avaliação em curto-circuito


(2 > 0) && println("2 é maior que 0")

(2 < 0) && println("esse código não executa")

iamtrue || print("não será avaliado")

iamfalse || print("será avaliado")


Isso é tudo para esta sessão de estudo! Até a próxima!
