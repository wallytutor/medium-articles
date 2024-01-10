---
title  : Primeiros Passos
author : Walter Dal'Maz Silva
date   : `j import Dates; Dates.Date(Dates.now())`
weave_options:
  error: false
  term: false
  wrap: true
  line_width: 100
---

# Parte 1 - Primeiros passos

Tradicionalmente, o primeiro contato com uma linguagem de programação se faz através da implementação se seu programa `Hello, World!` que nada mas faz que imprimir esta sentença em um terminal. Em Julia usamos a função `println()` contendo o texto a ser apresentado entre aspas duplas (veremos mais sobre texto na próxima seção) para implementar este *programa*, como se segue:

```julia
println("Olá, Mundo!")
```

## Tipos básicos

O interesse principal de programação é o fato de podermos *atribuir* valores à *nomes* e em seguida realizar a manipulação necessária. Uma vez implementado o *algoritmo*, podemos simplesmente modificar os valores e *reutilizá-lo*.

Esse processo chama-se *atribuição de variáveis* e é realizado utilizando o símbolo de igualdade `=` com o nome da variável à esquerda e seu valor a direita.

!!! warning "Atenção"

    Veremos mais tarde que a comparação de igualdade se faz com um duplo sinal `==` e que devemos tomar cuidado com isso quando estamos tendo um primeiro contato com programação. A igualdade simples `=` é, na maioria das linguagens modernas, um símbolo de atribuição de valor.

Vamos criar uma variávei `favorite_number_1` e atribuir seu valor:

```julia
favorite_number_1 = 13
```

Agora poderíamos realizar operações com `favorite_number_1`. Faremos isso mais tarde com outras variáveis porque antes é importante de introduzirmos o conceito de *tipos*. Toda variável é de um dado tipo de dado, o que implica o tamanho (fixo ou variável) de sua representação na memória do computador. Com a função `typeof()` inspecionamos o tipo de uma variável.

Vemos que o tipo de 13 -- um número inteiro -- é representado em Julia por `Int64`.

```julia
typeof(favorite_number_1)
```

Existem diversos [tipos numéricos suportados por Julia](https://docs.julialang.org/en/v1/base/numbers/), mas aqui vamos ver somente os tipos básicos utilizados mais comumente em computação numérica. Atribuindo um valor aproximado de π a `favorite_number_2` obtemos um *objeto* de tipo `Float64`, utilizado para representar números reais em *dupla precisão*.

!!! note "Aritmética de ponto flutuante de dupla precisão"

    A maioria dos números reais não podem ser representados com precisão arbitrária em um computador. Um número real em dupla precisão é representado com 64 bits na memória. Representações de precisão arbitrária são hoje em dia disponíveis mas tem um custo de operação proibitivo para a maioria das aplicações. A matemática necessária para a compreensão da representação na memória é discutida no livro texto.


```julia
favorite_number_2 = 3.141592
typeof(favorite_number_2)
```

Uma particularidade de Julia dado o seu caráter científico é o suporte à números irracionais. Podemos assim representar `π` de maneira otimizada como discutiremos num momento oportuno.

!!! tip "Caractéres especiais"

    Julia suporta progração usando quaisquer caractéres UNICODE. Isso inclui letras gregas, subscritos, símbolos matemáticos... Em *notebooks* Pluto ou em editores conectados à um *Julia Language Server* podemos entrar esses símbolos digitando seu equivalente em ``\LaTeX`` e pressionando a tecla <TAB>. Uma lista detalhada de caracteres suportados é apresentada [aqui](https://docs.julialang.org/en/v1/manual/unicode-input/).


```julia
favorite_number_3 = π
typeof(favorite_number_3)
```

Por exemplo, também temos o número de Euler representado como irracional. Como este número é representado pela letra `e`, para evitar conflitos com outras variáveis ele precisa ser acessado pelo caminho completo do [módulo definindo](https://docs.julialang.org/en/v1/base/numbers/#Base.MathConstants.%E2%84%AF) as constantes matemáticas.

```julia
favorite_number_4 = MathConstants.e
typeof(favorite_number_4)
```

Outro exemplo de constante irracional é a proporção áurea.

```julia
Base.MathConstants.golden
```

A lista completa pode ser acessada com `names(module)` como se segue:

```julia
names(MathConstants)
```

O nome de variáveis também pode ser um emoji -- evite isso em programas, evidentemente.

```julia
🥰 = "Julia"
typeof(🥰)
```

Usando essa possibilidade podemos brincar com o conceito como abaixo:

```julia
begin
🐶 = 1
😀 = 0
😞 = -1
# Vamos ver se a expressão a seguir é avaliada como verdadeira.
# Todo texto após um `#` é considerado um comentário por Julia.
# Abaixo vemos um novo operador de comparação de igualdade `==`.
🐶 + 😞 == 😀
end
```

## Comentários

Vimos no bloco acima o primeiro bloco de comentários identificado por linhas iniciando com `#`. Como comentários não são expressões, vemos abaixo que múltiplas linhas são aceitas em uma única célula contando que haja apenas uma expressão no contexto. Comentários são desejáveis para que entendamos mais tarde qual era o objetivo de uma dada operação. Confie em mim, anos mais tarde um código que parecia evidente no momento da sua escritura, quando você tem o conceito a ser expresso fresco na cabeça, pode parecer um texto em [basco](https://pt.wikipedia.org/wiki/L%C3%ADngua_basca).

```julia
begin
# Em Julia, toda linha começando por um `#` é considerada um
# comentário. Comentários após declarações também são possíveis:

comment = 1;  # Um comentário após uma declaração.

#=
Comentários de multiplas linhas também podem ser escritos usando
o par `#=` seguido de texto e então `=#` no lugar de iniciar
diversas linhas com `#`, o que torna sua edição mais fácil.
=#
end;
```

## Aritmética básica

Podemos usar Julia em modo interativo como uma calculadora.

Vemos abaixo a adição `+` e subtração `-`,...

```julia
1 + 3, 1 - 3
```

... multiplicação `*` e divisão `/`, ...

```julia
2 * 5, 2 / 3
```

... e uma comparação entre a divisão racional e normal.

```julia
2 // 3 * 3, 2 / 3 * 3
```

Julia possui suporte incluso a números racionais, o que pode ser útil para evitar propagação de erros em vários contextos aonde frações de números inteiros podem eventualmente ser simplificadas. Verificamos o tipo da variável com `typeof()`.

```julia
typeof(2 // 3)
```

O quociente de uma divisão inteira pode ser calculado com a função `div()`. Para aproximar essa expressão da notação matemática é também possível utilizar `2 ÷ 3`.

```julia
div(2, 3)
```

O resto de uma divisão pode ser encontrado com `mod()`. Novamente essa função possui uma sintaxe alternativa -- como em diversas outras linguagem nesse caso -- utilizando o símbolo de percentual como em `11 % 3`.

```julia
mod(11, 3)
```

Para concluir as operações básicas, incluímos ainda a expoenciação `^`.

```julia
2^5
```

Outra particularidade de Julia é o suporte à multiplicação implícita -- use essa funcionalidade com cuidado, erros estranhos podem ocorrer em programas complexos.

```julia
a_number = 234.0;
2a_number
```

O valor de π também pode ser representado por `pi`. Observe que a multiplicação de um inteiro `2` por `pi` (de tipo `Irrational{:π}`) produz como resultado um número `Float64`.

```julia
typeof(2pi)
```

## Conversão explícita

Se um número real pode ser representado por um tipo inteiro, podemos utilizar a função `convert()` para a transformação desejada. Caso a representação integral não seja possível, talvez você possa obter o resultado almejado usando uma das funções `round()`, `floor()`, ou `ceil()`, as quais você pode verificar na documentação da linguagem.

```julia
a_number = 234.0;
convert(Int64, a_number) == 234
```

Funções em Julia também podem ser aplicadas a múltiplos argumentos de maneira sequencial em se adicionando um ponto entre o nome da função e o parêntesis de abertura dos argumentos. Por exemplo, para trabalhar com cores RGB é usual empregar-se o tipo `UInt8` que é limitado à 255, reduzindo a sua representação em memória.

A conversão abaixo se aplica a sequência de números `color` individualmente.

```julia
color = (255.0, 20.0, 21.0)
convert.(UInt8, color)
```

Finalmente, formas textuais podem ser interpretadas como números usando `parse()`.

```julia
parse(Int64, "1")
```

Isso é tudo para esta sessão de estudo! Até a próxima!
