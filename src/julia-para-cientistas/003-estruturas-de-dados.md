---
title  : Estruturas de dados - I
author : Walter Dal'Maz Silva
date   : `j import Dates; Dates.Date(Dates.now())`
weave_options:
  error: false
  term: false
  wrap: true
  line_width: 100
---

# Parte 3 - Estruturas de dados I

Nesta seção vamos estudar alguns tipos de estruturas de dados. Essas formas *compostas* são construídas sobre elementos que já vimos mas podem também ir além destes. Abordaremos apenas as características básicas de cada uma das estruturas apresentadas e os casos de aplicação se tornarão evidentes. Os diversos métodos comuns à essas coleções é descrito [nesta página](https://docs.julialang.org/en/v1/base/collections/).

## *Tuples*

Uma *tuple* é constituída de uma sequência de elementos, que podem ser de tipos diferentes, declarada entre parêntesis. A característica de base de uma *tuple* é sua imutabilidade: uma vez declarada, seus elementos não podem ser alterados.

!!! note "Já vimos isso antes"

    Voltando a seção aonde realizamos a conversão explícita de tipos acima, você pode verificar que na realidade já utilizamos uma tuple de números indicando as intensidades RGB de uma cor.

Declaremos uma sequência fixa de linguagens de programação dadas por seus nomes como `Strings`:

```julia
languages = ("Julia", "Python", "Octave")
```

Inspecionando o tipo desta variável aprendemos mais uma característica importante inerente a definição de `Tuple` feita acima quanto ao seu caráter imutável: o tipo de uma `Tuple` inclui individualmente o tipo de cada um de seus elementos. Dito de outra maneira, uma sequência composta de um número definido de objetos de dados tipos caracteriza por ela mesmo um novo tipo de dados.

```julia
typeof(languages)
```

Os elementos de uma `Tuple` podem ser acessados por seus índices.

!!! warning "Indices em Julia"

    É o momento de mencionar que em Julia a indexação inicia com `1`.

```julia
@show languages[1]
```

Vamos tentar modificar o segundo elemento da `Tuple`.

!!! tip "Sintaxe de controle de erros"

    Ainda é cedo para entrar nos detalhes, mas aproveite o bloco abaixo para ter um primeiro contato com a gestão de erros em Julia.

```julia
try
    languages[2] = "C++"
catch err
    println("Erro: $(err)")
end
```

Existem certas subtilidades que você precisa saber sobre a imutabilidade. Observe o exemplo abaixo, aonde declaramos duas variáveis que são utilizadas para construir uma `Tuple` e então modificamos uma das variáveis: a `Tuple` continua com os valores originais do momento da sua construção.

```julia
let
    a = 1
    b = 2

    test_tuple = (a, b)

    a = 5
    test_tuple
end
```

!!! danger "Isso nem sempre é verdade!"

    Se o elemento compondo a `Tuple` for de um tipo mutável, como é o caso de `Array`'s, como veremos no que se segue, os elementos desta variável podem ser modificados e impactam a `Tuple` diretamente. Isso se dá porque neste caso a `Tuple` conserva a referência ao objeto em questão, e não uma cópia dos valores, como é o caso para tipos de base.

```julia
let
    a = 1
    b = [1, 2]

    test_tuple = (a, b)

    b[1] = 999
    test_tuple
end
```

## *Named tuples*

Esta extensão à `Tuples` adiciona a possibilidade de acesso aos componentes por um *nome* no lugar de um simples índice -- que continua funcional como veremos abaixo. Esse tipo de estrutura é bastante útil quando necessitamos criar abstrações de coisas bastante simples para as quais a criação de um novo tipo não se justifica. Discutiremos mais tarde quando vamos estudar a criação de *novos tipos*.

```julia
named_languages = (julia = "Julia", python = "Python")
```

Observe o fato de que agora os nomes utilizados no índex fazem parte do tipo.

```julia
typeof(named_languages)
```

Abaixo verificamos que além do acesso por nomes, `NamedTuples` também respeitam a ordem de declaração dos elementos: `:julia` é o primeiro índice. A sintaxe de acesso aos elementos neste caso é com a notação típica utilizando um ponto, comum a diversas linguages de programação.

```julia
named_languages[1] == named_languages.julia
```

## Dicionários

Objetos do tipo `Dict` possuem a similaridade com `NamedTuples` em que seus elementos podem ser acessados por nome. No entanto a sintaxe é diferente e os valores desta estrutura são mutáveis.

```julia
organs = Dict("brain" => "🧠", "heart" => "❤")
```

O acesso a elementos se faz com colchetes contendo o índex como se segue:

```julia
organs["brain"]
```

E como dissemos, os elementos são mutáveis: vamos atribuir um burrito ao cérebro.

```julia
organs["brain"] = "🌯"
```

Não só os elementos, mas o dicionário como um todo, pode ser alterado. Para adicionar novos elementos simplesmente *acessamos* a palavra-chave e atribuímos um valor:

```julia
organs["eyes"] = "👀"
```

Internamente para evitar nova alocação de memória a cada tentativa de se adicionar um novo elemento, um dicionário realiza a alocação de `slots` que são renovados cada vez que sua capacidade é ultrapassada. Observe que a lista retornada abaixo é composta majoritariamente de `0x00`, que é o endereço de memória nulo, enquanto 3 elementos indicam um valor não-nulo, correspondendo aos elementos já adicionados ao dicionário. Disto vemos que adicionalmente um dicionário não preserva necessariamente uma sequência ordenada. Esses detalhes ultrapassam o presente escopo mas vão abrindo as portas para assuntos mais complexos.

```julia
organs.slots
organs
```

Para remover elementos utilizamos a função `pop!`. Por convenção em Julia, funções que terminam por um ponto de exclamação modificam os argumentos que são passados. No caso de `pop!` o dicionário é modificado e o valor de retorno é aquele do elemento removido.

```julia
pop!(organs, "brain")
```

A tentativa de remover um elemento inexistente obviamente conduz à um erro:

```julia
try
    pop!(organs, "leg")
catch err
    println("Erro: $(err)")
end
organs
```

Para evitar essa possibilidade podemos usar a função `haskey()`.

```julia
haskey(organs, "liver")
```

Uma última coisa a notar é que *praticamente* qualquer tipo básico pode ser empregado como a chave de um dicionário em Julia. Veja o exemplo à seguir:

```julia
music = Dict(:violin => "🎻", 1 => 2)
```

Como as chaves são de tipos diferentes (um `Symbol` e um `Int64`), assim como os valores (uma `String` e um `Int64`), a função `typeof()` nos retorna tipos `Any`.

```julia
typeof(music)
```

Ainda nos restam alguns detalhes e tipos de dados, mas o tutorial começa a ficar longo... e não queremos te perder por aqui!

Isso é tudo para esta sessão de estudo! Até a próxima!
