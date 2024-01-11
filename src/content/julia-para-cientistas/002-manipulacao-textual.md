+++
title   = "Parte 2 - Manipulação textual"
tags    = ["programming"]
showall = true
+++

# Parte 2 - Manipulação textual

Uma habilidade frequentemente negligenciada pelo grande público de computação
científica nos seus primeiros passos é a capacidade de manipulação textual. Não
podemos esquecer que programas necessitam interfaces pelas quais alimentamos as
condições do problema a ser solucionado e resultados são esperados ao fim da
computação. Para problemas que tomam um tempo computacional importante, é
extremamente útil ter mensagens de estado de progresso. Nessa seção introduzimos
os primeiros elementos necessários para a manipulação textual em Julia.

Uma variável do tipo `String` declara-se com aspas duplas, como vimos
inicialmente no programa `Hello, World!`. Deve-se tomar cuidado em Julia pois
caracteres individuais (tipo `Char`) tem um significado distinto de uma coleção
de caracteres `String`.

Por exemplo, avaliando o tipo de `'a'` obtemos:

```julia:output
typeof('a')
```

## Declaração de Strings

Estudaremos caracteres mais tarde. Por enquanto nos interessamos por expressões
como:

```julia:output
text1 = "Olá, eu sou uma String"

typeof(text1)
```

Eventualmente necessitamos utilizar aspas duplas no interior do texto. Neste
caso, a primeira solução provida por Julia é utilizar três aspas duplas para a
abertura e fechamento do texto. Observamos abaixo que o texto é transformado
para adicionar uma barra invertida antes das aspas que estão no corpo do texto.

```julia:output
text2 = """Eu sou uma String que pode incluir "aspas duplas"."""
```

Neste caso, Julia aplicou automaticamente um *caractere de escape* no símbolo a
ser interpretado de maneira especial. Existem diversos casos aonde a aplicação
manual pode ser útil, por exemplo quando entrando texto em UNICODE por códigos.
No exemplo abaixo utilizamos a técnica manual com o texto precedente.

```julia:output
text3 = "Eu sou uma String que pode incluir \"aspas duplas\"."
```

Para averiguar o funcionamento correto, testamos de imprimir `text3` no
terminal.

```julia:output
println(text3)
```

O exemplo a seguir ilustra o uso do caracter de escape para representar UNICODE.

```julia:output
pounds = "\U000A3"
```

## Interpolação de Strings

Para gerar mensagens automáticas frequentemente dispomos de um texto que deve
ter partes substituidas. Ilustramos abaixo o uso de um símbolo de dólar \$
seguido de parêntesis com a variável de substituição para realizar o que
chamamos de *interpolação textual*.

\note{Múltiplas variáveis em uma linha}{Observe aqui a introdução da declaração
de múltiplas variáveis em uma linha.}

```julia:output
name, age = "Walter", 34
println("Olá, $(name), você tem $(age) anos!")
```

\warn{Prática não recomendada}{Para nomes simples de variáveis e sem formatação
explícita, o código a seguir também é valido, mas é pode ser considerado uma má
prática de programação.}

```julia:output
println("Olá, $name, você tem $age anos!")
```

Em alguns casos, como na contagem de operações em um laço, podemos também
realizar operações e avaliação de funções diretamente na `String` sendo
interpolada.

```julia:output
println("Também é possível realizar operações, e.g 2³ = $(2^3).")
```

## Formatação de números

```julia:output
using Printf

println(@sprintf("%g", 12.0))

println(@sprintf("%.6f", 12.0))

println(@sprintf("%.6e", 12.0))

println(@sprintf("%15.8e %15.8E", 12.0, 13))

println(@sprintf("%6d", 12.0))

println(@sprintf("%06d", 12))
```

## Concatenação de Strings

Na maioria das linguagens de programação a concatenação textual se faz com o
símbolo de adição `+`. Data suas origens já voltadas para a computação numérica,
Julia adota para esta finalidade o asterísco `*` utilizado para multiplicação, o
que se deve à sua utilização em álgebra abstrata para indicar operações
não-comutativas, como clarificado no
[manual](https://docs.julialang.org/en/v1/manual/strings/#man-concatenation).

```julia:output
bark = "Au!"

bark * bark * bark
```

O circunflexo `^` utilizado para a exponenciação também pode ser utilizado para
uma repetição múltipla de uma data `String`.

```julia:output
bark^10
```

Finalmente o construtor `string()` permite de contactenar não somente `Strings`,
mas simultanêamente `Strings` e objetos que suportam conversão textual.

```julia:output
string("Unido um número ", 10, " ou ", 12.0, " a outro ", "texto!")
```

## Funções básicas

Diversos outros [métodos](https://docs.julialang.org/en/v1/base/strings/) são
disponíveis para Strings. Dado o suporte UNICODE de Julia, devemos enfatizar com
o uso de `length()` e `sizeof()` que o comprimento textual de uma `String` pode
não corresponder ao seu tamanho em *bytes*, o que pode levar ao usuário
desavisado a erros numa tentativa de acesso à caracteres por índices.

```julia:output
length("∀"), sizeof("∀")
```

Uma função que é bastante útil é `startswith()` que permite verificar se uma
`String` inicia por um outro bloco de caracteres visado. Testes mais complexos
podem ser feitos com [expressões
regulares](https://docs.julialang.org/en/v1/base/strings/#Base.Regex), como
veremos mais tarde.

```julia:output
startswith("align", "al")
```

Isso é tudo para esta sessão de estudo! Até a próxima!
