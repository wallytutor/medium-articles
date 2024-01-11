+++
title   = "Parte 4 - Estruturas de dados II"
tags    = ["programming"]
showall = true
+++

# Parte 4 - Estruturas de dados II

Neste notebook estudamos a sequência de estruturas de dados básicas iniciada no
precedente. O foco aqui são tipos úteis em cálculo numérico e álgebra linear,
embora suas aplicação vaiam muito além.

## *Arrays*

A estrutura `Array` se diferencia de `Tuple` pelo fato de ser mutável e de
`Dict` pela noção de ordem. Dadas essas características não é surpreendente que
seja esse o tipo de base sobre o qual Julia constrói vetores e matrizes, embora
um `Array` seja mais genérico que esses conceitos matemáticos. Podemos, por
exemplo, construir um `Array` contendo sub-`Array`'s de tamanho variável, o que
não constituiria uma matriz. Ou então misturar tipos de dados nos elementos de
um `Array`, como mostramos ser possível com `Tuple`.

Em termos de sintaxe, usamos nesse caso colchetes `[]` para limitar a sequência.

Considere por exemplo a seguinte lista de países...

```julia:output
countries = ["France", "Brazil", "Germany"]
```

...ou então de números,...

```julia:output
numbers = [1, 2, 3.1]
```

..., ou simplesmente informações pessoais.

```julia:output
personal_info = ["Walter", 34, "Lyon"]
```

O acesso a elementos se faz através de índices, como em `Tuple`.

```julia:output
personal_info[2]
```

Como essa estrutura é mutável ela suporta -- [entre muitos
outros](https://docs.julialang.org/en/v1/base/arrays/) -- o método `push!()`
para se adicionar um elemento após o último.

```julia:output
push!(personal_info, "Engineer")
```

De maneira similar ao que vimos para `Dict`, uma implementação de `pop!()` é
disponível para o tipo `Array`, realizando a operação inversa de `push!()`.

```julia:output
pop!(personal_info)
```

O exemplo de uma *não-matriz* citado na introdução é apresentado a seguir.

```julia:output
not_a_matrix = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]
```

Usando `typeof()` descobrimos que se trata de um `Vector` de `Vector` e que na
verdade Julia usa `Vector` com um *alias* para um `Array{T, 1}`, aonde `T`
denota o tipo de dado.

```julia:output
typeof(not_a_matrix)
```

A função [`rand()`](https://docs.julialang.org/en/v1/stdlib/Random/#Base.rand)
pode ser usada para criar uma matriz de números aleatórios -- e outras
estruturas de ordem superior -- como se segue. Observe o tipo `Matrix{Float64}`
indicado.

```julia:output
a_matrix = rand(3, 3)
```

Repetindo a verificação de tipo como fizemos para of *vetor de vetores*
anteriormente, descobrimos que uma `Matrix` em Julia não é interpretada da mesma
maneira, mas como um `Array` com duas dimensões. Isso é a forma que a linguagem
emprega para assegurar as dimensões constantes segundo cada direção da matriz.

```julia:output
typeof(a_matrix)
```

Vamos agora atribuir nossa `a_matrix` à uma outra variável e então modificar a
matrix original.

```julia:output
maybe_another_matrix = a_matrix
a_matrix[1, 1] = 999
a_matrix
```

Tal como para a `Tuple` com objetos mutáveis, atribuir um novo nome à uma matriz
não cria uma nova matriz, apenas referencia o seu endereço de memória:
observamos abaixo que a tentativa de cópia `maybe_another_matriz` também é
modificada em razão da operação sobre `a_matrix`.

```julia:output
maybe_another_matrix
```

Quando uma cópia da matriz é necessária devemos utilizar `copy()`. Nas próximas
células criamos uma matriz e então uma cópia, a qual é modificada, e verificamos
não haver impacto na matriz original, validando a cópia em um novo endereço de
memória.

```julia:output
another_matrix = rand(2, 2)
again_a_matrix = copy(another_matrix)
again_a_matrix[1, 2] = 0
again_a_matrix
another_matrix
```

## *Ranges*

Julia implementa uma variedade de tipos de *ranges*, iteradores para enumerações
ou números espaçados segundo uma regra definida. Os tipos existentes
encontram-se documentados em
[collections](https://docs.julialang.org/en/v1/base/collections/). O leitor pode
interessar-se também pela função mais genérica
[range](https://docs.julialang.org/en/v1/base/math/#Base.range) da biblioteca
padrão.

Vamos começar com a declaração de um `UnitRange` de números 1 à 10 que pode ser
construido com a sintaxe simplificada abaixo.

```julia:output
range_of_numbers = 1:10
```

Confirmamos que trata-se de um `UnitRange` especializado para o tipo inteiro da
arquitetura do computador, 64-bits, tal como o tipo dos elementos usados na
construção.

```julia:output
typeof(range_of_numbers)
```

Essa sintaxe mostrada acima é simplesmente um *syntatic sugar* para a chamada do
construtor padrão deste tipo, como averiguamos na próxima célula.

```julia:output
UnitRange(1, 10)
```

Uma particularidade da sequência criada é que ela não é expandida na memória,
mas tão somente a regra de construção para iteração é definida. Verificamos na
próxima célula que esta sequência não possui os elementos que esperaríamos.

```julia:output
range_of_numbers
```

Isso é fundamental para se permitir laços de tamanhos enormes, frequentes em
computação científica; pode-se, por exemplo, criar uma sequência inteira entre 1
e o máximo valor possível para o tipo `Int64`:

```julia:output
1:typemax(Int64)
```

Para se expandir a sequência devemos *coletar* seus valores com `collect`:

```julia:output
arr = collect(range_of_numbers)
```

O resultado dessa operação é um `Vector` especializado no tipo usado para a
sequência.

```julia:output
typeof(arr)
```

A inserção de um elemento adicional na sintaxe do tipo `start:step:end` permite
a criação de sequências com um passo determinado. Abaixo usamos um passo de tipo
`Float64` que por razões de precedência numérica vai gerar uma sequência de tipo
equivalente, como verificamos no que se segue.

```julia:output
float_range = 0:0.6:10
typeof(float_range)
```

Acima utilizamos um passo de `0.6` para ilustrar uma particularidade do tipo
`StepRangeLen` que não inclui o último elemento da sequência caso esse não seja
um múltiplo inteiro do passo utilizado, de maneira a assegurar que todos os
elementos sejam igualmente espaçados.

```julia:output
collect(float_range)
```

Finalmente, Julia provê `LinRange`, que será bastante útil para aqueles
interessados em métodos numéricos de tipo diferenças finitas ou volumes finitos.
Criamos um `LinRange` fornecendo os limites do intervalo e o número de elementos
igualmente espaçados a retornar.

```julia:output
LinRange(1.0, 10.0, 10)
```

## Atribuição de tipos

Até o momento criamos objetos em Julia sem *anotar* os tipos de dados
requeridos. O compilador de Julia realiza inferência de tipos de maneira
bastante avançada para determinar como especializar funções para as entradas
dadas. Prover explicitamente tipos, principalmente em interfaces de funções,
como veremos no futuro, é altamente recomendável e evita dores de cabeça quanto
a validação de um programa quando este ganha em complexidade. Ademais, para
computação numérica e aprendizado de máquina, a especificação de tipos tem
implicação direta sobre a precisão e performance dos cálculos. É comum, por
exemplo, treinar-se redes neurais com dados truncados à `Float32`, tipo que
apresenta performance optimizada nas GPU's específicas deste ramo, enquanto um
cálculo DEM (Discrete Element Method) de colisão de partículas necessida dados
`Float64` (e uma carta gráfica de alto nível adaptada) para prover resultados
realistas.

Em Julia especificamos tipos com a sintaxe `a::TipoDeA`. Isso é valido para
variáveis quaisquer, elementos de estruturas de dados, interfaces de funções,
etc. Por exemplo, declaremos a seguinte variável:

```julia:output
a::Float32 = 1
typeof(a)
```

Anotamos o tipo `Float32` para a variável `a`. No entanto o argumento à direita
do sinal de atribuição é um inteiro `1`. Se deixássemos a *descoberta* de tipos
ao compilador, neste caso obteríamos:

```julia:output
a = 1
typeof(a)
```

Esse resultado pode ser indesejável e incompatível com a interface de alguma
função aonde desejamos empregar o valor de `a`.

Vejamos agora alguns exemplos do impacto no tempo de execução de se prover
valores ao lado *direito da igualdade* adaptados aos tipos esperados na
especificação de dados. Vamos usar os *ranges* que aprendemos logo acima e
`collect` para criar um `Vector{Int64}`.

\note{Uso de macros}{A *macro* `@benchmark` vai executar o código algumas vezes
e retornar estatísticas de execução. Não se preocupe com ela por agora, vamos
voltar na temática de *benchmarking* muito em breve.}

```julia:output
using BenchmarkTools, Statistics
@benchmark a::Vector{Int64} = collect(1:10)
```

Vemos que o tempo de execução é da ordem de 30 ns. Abaixo repetimos essa
avaliação para algumas ordens de grandeza de tamanho de *arrays*. Vemos que o
tempo de execução para a criação dos objetos escala com o logaritmo na base 10
do número de elementos.

```julia:output
scalability = [
    mean((@benchmark a::Vector{Int64} = collect(1:10^1)).times)
    mean((@benchmark a::Vector{Int64} = collect(1:10^2)).times)
    mean((@benchmark a::Vector{Int64} = collect(1:10^3)).times)
    mean((@benchmark a::Vector{Int64} = collect(1:10^4)).times)
]
log10.(scalability)
```

Tentemos agora criar um vetor de `Float64` usando o mesmo método.


```julia:output
@benchmark a::Vector{Float64} = collect(1:10)
```

O tempo de execução mais que dobrou e a memória estimada foi multiplicada por
dois! Isso ocorre porque ao lado direito da expressão fornecemos números
inteiros e o compilador é *obrigado* a incluir uma etapa de conversão de tipos,
o que adiciona operações e alocações de memória.

Se na criação do *range* utilizarmos o tipo esperado de dados voltamos a linha
de base da alocação do vetor de inteiros, da ordem de 30 ns e 144 bytes.

```julia:output
@benchmark b::Vector{Float64} = collect(1.0:10.0)
```

Repetimos o *benchmark* para comparar a criação de vetores de dupla-precisão
inicializados por inteiros e números de dupla precisão. Incluímos no novo
*benchmark* um vetor com um único elemento para entendermos um pouco mais do
processo.

```julia:output
with_conversion = let
    scalability = [
        mean((@benchmark a::Vector{Float64} = collect(1:10^0)).times)
        mean((@benchmark a::Vector{Float64} = collect(1:10^1)).times)
        mean((@benchmark a::Vector{Float64} = collect(1:10^2)).times)
        mean((@benchmark a::Vector{Float64} = collect(1:10^3)).times)
    ]
    scalability
end
```

```julia:output
without_conversion = let
    scalability = [
        mean((@benchmark a::Vector{Float64} = collect(1.0:10.0^0)).times)
        mean((@benchmark a::Vector{Float64} = collect(1.0:10.0^1)).times)
        mean((@benchmark a::Vector{Float64} = collect(1.0:10.0^2)).times)
        mean((@benchmark a::Vector{Float64} = collect(1.0:10.0^3)).times)
    ]
    scalability
end
```

O vetor `with_conversion` contém os tempos de execução para a criação de vetores
de 1, 10, 100, 1000 e 10000 elementos com conversão de valores de inteiros para
dupla-precisão. Observe que os dois primeiros elementos levaram um tempo (aqui
em nano-segundos) quase idênticos: existe uma constante de tempo da criação do
vetor propriamente dito, a criação dos 10 primeiros elementos é quase negligível
nesse caso.

Abaixo calculamos a diferença de tempo entre os dois processos e nos deparamos
com mais uma surpresa: para 100 elementos, o tempo de alocação COM conversão é
MENOR que o tempo SEM conversão. Ainda é muito cedo e fora de contexto para
entrarmos no código LLVM gerado por Julia para entendermos a razão dessa
*anomalia*. O importante a reter aqui é que para vetores de tamanhos importantes
(> 1000 elementos) um tempo adicional de execução é adicionado por elemento e
isso deve ser levado em conta quando escrevendo código científico.

```julia:output
time_diff = (without_conversion - with_conversion)
time_diff_per_element = time_diff ./ [10^k for k = 0:3]
```

Espero que a decisão de incluir essas divagações um pouco cedo no aprendizado
não sejam deletérias para a motivação do estudante, mas que criem curiosidade
quanto aos tópicos mais avançados que veremos mais tarde.

Ainda falta muito para se concluir a introdução à atribuição de tipos, mas esse
primeiro contato era necessário para que as próximos tópicos avancem de maneira
mais fluida.

Isso é tudo para esta sessão de estudo! Até a próxima!
