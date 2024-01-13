+++
title   = "Reator pistão - introdução"
tags    = ["simulation", "physics"]
showall = true
outpath = "/assets/content/medium/01-Composite-Conduction/code/output"
+++

# Reator pistão - introdução

<!-- let
    z = ImmersedConditionsFVM(; L = reactor.L, N = 10000).z
    ĥ = computehtc(; reactor..., fluid..., u = operations.u, verbose = true)

    pars = (z = z, ĥ = ĥ, P = P, A = A, ρ = fluid.ρ, cₚ = fluid.cₚ, operations...)
    Tₐ = analyticalthermalpfr(; pars...)

    standardplot(quote
        lines!(ax, $z, $Tₐ, color = :red, linewidth = 5, label = "Analítica")
        Tend = @sprintf("%.2f", $Tₐ[end])
    end)
end -->

### Integração numérica da EDO

Neste exemplo tivemos *sorte* de dispor de uma solução analítica. Esse problema
pode facilmente tornar-se intratável se considerarmos uma dependência arbitrária
do calor específico com a temperatura ou se a parede do reator tem uma
dependência na coordenada axial. É importante dispor de meios numéricos para o
tratamento deste tipo de problema.

No caso de uma equação diferencial ordinária (EDO) como no presente caso, a
abordagem mais simples é a de se empregar um integrador numérico. Para tanto é
prática comum estabelecer uma função que representa o *lado direito* do problema
isolando a(s) derivada(s) no lado esquerdo. Em Julia dispomos do *framework* de
`ModelingToolkit` que provê uma forma simbólica de representação de problemas e
interfaces com diversos integradores. A estrutura `DifferentialEquationPFR`
abaixo implementa o problema diferencial desta forma.

<!-- """
Representação em forma EDO do reator pistão.

$(TYPEDFIELDS)
"""
struct DifferentialEquationPFR
    "Perímetro transversal do reator [m]"
    P::Num

    "Área transversal do reator [m²]"
    A::Num

    "Temperatura de superfície do reator [K]"
    Tₛ::Num

    "Coeficient convectivo de troca de calor [W/(m².K)]"
    ĥ::Num

    "Velocidade do fluido [m/s]"
    u::Num

    "Densidade do fluido [kg/m³]"
    ρ::Num

    "Calor específico do fluido [J/(kg.K)]"
    cₚ::Num

    "Coordenada axial do reator [m]"
    z::Num

    "Temperatura axial do reator [K]"
    T::Num

    "Sistema diferencial ordinário à simular"
    sys::ODESystem

    function DifferentialEquationPFR()
        # Variável independente.
        @variables z

        # Variável dependente.
        @variables T(z)

        # Parâmetros.
        pars = @parameters P A Tₛ ĥ u ρ cₚ

        # Operador diferencial em z.
        D = Differential(z)

        # Sistema de equações.
        eqs = [D(T) ~ ĥ * P * (Tₛ - T) / (ρ * u * A * cₚ)]

        # Criação do sistema.
        @named sys = ODESystem(eqs, z, [T], pars)

        return new(P, A, Tₛ, ĥ, u, ρ, cₚ, z, T, sys)
    end
end -->

Para integração do modelo simbólico necessitamos substituir os parâmetros por
valores numéricos e fornecer a condição inicial e intervalo de integração ao
integrador que vai gerir o problema. A interface `solveodepfr` realiza essas
etapas. É importante mencionar aqui que a maioria dos integradores numéricos vai
*amostrar* pontos na coordenada de integração segundo a *rigidez numérica* do
problema, de maneira que a solução retornada normalmente não está sobre pontos
equi-espaçados. Podemos fornecer um parâmetro opcional para recuperar a solução
sobre os pontos desejados, o que pode facilitar, por exemplo, comparação com
dados experimentais.

<!-- "Integra o modelo diferencial de reator pistão"
function solveodepfr(;
    model::DifferentialEquationPFR,
    P::T,
    A::T,
    Tₛ::T,
    Tₚ::T,
    ĥ::T,
    u::T,
    ρ::T,
    cₚ::T,
    z::Vector{T},
) where {T}
    T₀ = [model.T => Tₚ]

    p = [
        model.P => P,
        model.A => A,
        model.Tₛ => Tₛ,
        model.ĥ => ĥ,
        model.u => u,
        model.ρ => ρ,
        model.cₚ => cₚ,
    ]

    zspan = (0, z[end])
    prob = ODEProblem(model.sys, T₀, zspan, p)
    return solve(prob; saveat = z)
end -->

Uma funcionalidade bastante interessante de `ModelingToolkit` é sua capacidade
de representar diretamente em com $\LaTeX$ as equações implementadas. Antes de
proceder a solução verificamos na célula abaixo que a equação estabelecida no
modelo está de acordo com a formulação que derivamos para o problema
diferencial. Verifica-se que a ordem dos parâmetros pode não ser a mesma, mas o
modelo é equivalente.

<!-- let
    DifferentialEquationPFR().sys
end -->

Com isso podemos proceder à integração com ajuda de `solveodepfr` concebida
acima e aproveitamos para traçar o resultado em conjunto com a solução
analítica.

<!-- let
    z = ImmersedConditionsFVM(; L = reactor.L, N = 10000).z
    ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    pars = (z = z, ĥ = ĥ, P = P, A = A, ρ = fluid.ρ, cₚ = fluid.cₚ, operations...)

    model = DifferentialEquationPFR()
    Tₐ = analyticalthermalpfr(; pars...)
    Tₒ = solveodepfr(; model = model, pars...)[:T]

    standardplot(quote
        lines!(ax, $z, $Tₐ, color = :red, linewidth = 5, label = "Analítica")
        lines!(ax, $z, $Tₒ, color = :black, linewidth = 2, label = "EDO")
        Tend = @sprintf("%.2f", $Tₒ[end])
    end)
end -->

### Método dos volumes finitos

Quando integrando apenas um reator, o método de integração numérica da equação é
geralmente a escolha mais simples. No entanto, em situações nas quais desejamos
integrar trocas entre diferentes reatores aquela abordagem pode se tornar
proibitiva. Uma dificuldade que aparece é a necessidade de solução iterativa até
convergência dados os fluxos pelas paredes do reator, o que demandaria um código
extremamente complexo para se gerir em integração direta. Outro caso são
trocadores de calor que podem ser representados por conjutos de reatores em
contra-corrente, um exemplo que vamos tratar mais tarde nesta série. Nestes
casos podemos ganhar em simplicidade e tempo de cálculo empregando métodos que
*linearizam* o problema para então resolvê-lo por uma simples *álgebra linear*.

Na temática de fênomenos de transporte, o método provavelmente mais
frequentemente utilizado é o dos volumes finitos (em inglês abreviado FVM). Note
que em uma dimensão com coeficientes constantes pode-se mostrar que o método é
equivalente à diferenças finitas (FDM), o que é nosso caso neste problema. No
entanto vamos insistir na tipologia empregada com FVM para manter a consistência
textual nos casos em que o problema não pode ser reduzido à um simples FDM.

No que se segue vamos usar uma malha igualmente espaçada de maneira que nossas
coordenadas de solução estão em $z\in\{0,\delta,2\delta,\dots,N\delta\}$ e as
interfaces das células encontram-se nos pontos intermediários. Isso dito, a
primeira e última célula do sistema são *meias células*, o que chamaremos de
*condição limite imersa*, contrariamente à uma condição ao limite com uma célula
fantasma na qual o primeiro ponto da solução estaria em $z=\delta/2$. Trataremos
esse caso em outra ocasião.

O problema de transporte advectivo em um reator pistão é essencialmente
*upwind*, o que indica que a solução em uma célula $E$ *a leste* de uma célula
$P$ depende exclusivamente da solução em $P$. Veremos o impacto disto na forma
matricial trivial que obteremos na sequência. Para a sua construção, começamos
pela integração do problema entre $P$ e $E$, da qual se segue a separação de
variáveis

$$
\int_{T_P}^{T_E}\rho{}u{}c_{p}A_{c}dT=
\int_{0}^{\delta}\hat{h}{P}(T_{s}-T^{\star})dz
$$

Observe que introduzimos a variável $T^{\star}$ no lado direito da equação e não
sob a integral em $dT$. Essa escolha se fez porque ainda não precisamos definir
qual a temperatura mais representativa deve-se usar para o cálculo do fluxo
térmico. Logo vamos interpretá-la como uma constante que pode ser movida para
fora da integral

$$
\rho{}u{}c_{p}A_{c}\int_{T_P}^{T_E}dT=
\hat{h}{P}(T_{s}-T^{\star})\int_{0}^{\delta}dz
$$

Realizando-se a integração definida obtemos a forma paramétrica

$$
\rho{}u{}c_{p}A_{c}(T_{E}-T_{P})=
\hat{h}{P}\delta(T_{s}-T^{\star})
$$

Para o tratamento com FVM agrupamos parâmetros para a construção matricial, o
que conduz à

$$
aT_{E}-aT_{P}=
T_{s}-T^{\star}
$$

No método dos volumes finitos consideramos que a solução é constante através de
uma célula. Essa hipótese é a base para construção de um modelo para o parâmetro
$T^{\star}$ na presente EDO. Isso não deve ser confundido com os esquemas de
interpolaçãO que encontramos em equações diferenciais parciais.

A ideia é simples: tomemos um par de células $P$ e $E$ com suas respectivas
temperaturas $T_{P}$ e $T_{E}$. O limite dessas duas células encontra-se no
ponto médio entre seus centros, que estão distantes de um comprimento $\delta$.
Como a solução é constante em cada célula, entre $P$ e a parede o fluxo de calor
total entre seu centro e a fronteira $e$ com a célula $E$ é

$$
\dot{Q}_{P-e} = \hat{h}{P}(T_{s}-T_{P})\delta_{P-e}=\frac{\hat{h}{P}\delta}{2}(T_{s} - T_{P})
$$

De maneira análoga, o fluxo entre a fronteira $e$ e o centro de $E$ temos

$$
\dot{Q}_{e-E} = \hat{h}{P}(T_{s}-T_{E})\delta_{e-E}=\frac{\hat{h}{P}\delta}{2}(T_{s}-T_{E})
$$

Nas expressões acima usamos a notação em letras minúsculas para indicar
fronteiras entre células. A célula de *referência* é normalmente designada $P$,
e logo chamamos a fronteira pela letra correspondendo a célula vizinha em
questão, aqui $E$. O fluxo convectivo total entre $P$ e $E$ é portanto

$$
\dot{Q}_{P-E}=\dot{Q}_{P-e}+\dot{Q}_{e-E}=\hat{h}{P}\left[T_{s}-\frac{(T_{E}+T_{P})}{2}\right]
$$

de onde adotamos o modelo

$$
T^{\star}=\frac{T_{E}+T_{P}}{2}
$$

A troca convectiva com a parede não seria corretamente representada se
escolhessemos $T_{P}$ como referência para o cálculo do fluxo (o que seria o
caso em FDM). Obviamente aproximações de ordem superior são possíveíveis
empregando-se mais de duas células mas isso ultrapassa o nível de complexidade
que almejamos entrar no momento.

Aplicando-se esta expressão na forma numérica precedente, após manipulação
chega-se à

$$
(2a + 1)T_{E}=
(2a - 1)T_{P} + 2T_{w}
$$

Com algumas manipulações adicionais obtemos a forma que será usada na sequência

$$
-A^{-}T_{P} + A^{+}T_{E}=1\quad\text{aonde}\quad{}A^{\pm} = \frac{2a \pm 1}{2T_{w}}
$$

A expressão acima é válida entre todos os pares de células $P\rightarrow{}E$ no
sistema, exceto pela primeira. Como se trata de uma EDO, a primeira célula do
sistema contém a condição inicial $T_{0}$ e não é precedida por nenhuma outra
célula e evidentemente não precisamos resolver uma equação adicional para esta.
Considerando o par de vizinhos $P\rightarrow{}E\equiv{}0\rightarrow{}1$,
substituindo o valor da condição inicial obtemos a modificação da equação para a
condição inicial imersa

$$
A^{+}T_{1}=1 + A^{-}T_{0}
$$

Como não se trata de um problema de condições de contorno, nada é necessário
para a última célula do sistema. Podemos agora escrever a forma matricial do
problema que se dá por

$$
\begin{bmatrix}
 A^{+}  &  0     &  0     & \dots  &  0      &  0      \\
-A^{-}  &  A^{+} &  0     & \dots  &  0      &  0      \\
 0      & -A^{-} &  A^{+} & \ddots &  0      &  0      \\
\vdots  & \ddots & \ddots & \ddots & \ddots  & \vdots  \\
 0      &  0     &  0     & -A^{-} &  A^{+}  &   0     \\
 0      &  0     &  0     &  0     & -A^{-}  &   A^{+} \\
\end{bmatrix}
\begin{bmatrix}
T_{1}    \\
T_{2}    \\
T_{3}    \\
\vdots   \\
T_{N-1}  \\
T_{N}    \\
\end{bmatrix}
=
\begin{bmatrix}
1 + A^{-}T_{0}  \\
1               \\
1               \\
\vdots          \\
1               \\
1               \\
\end{bmatrix}
$$

A dependência de $E$ somente em $P$ faz com que tenhamos uma matriz diagonal
inferior, aonde os $-A^{-}$ são os coeficientes de $T_{P}$ na formulação
algébrica anterior. A condição inicial modifica o primeiro elemento do vetor
constante à direita da igualdade. A construção e solução deste problema é
provida em `solvethermalpfr` abaixo.

<!-- "Integra reator pistão circular no espaço das temperaturas."
function solvethermalpfr(;
    mesh::AbstractDomainFVM,
    P::T,
    A::T,
    Tₛ::T,
    Tₚ::T,
    ĥ::T,
    u::T,
    ρ::T,
    cₚ::T,
    vars...,
) where {T}
    N = length(mesh.z) - 1
    a = (ρ * u * cₚ * A) / (ĥ * P * mesh.δ)

    A⁺ = (2a + 1) / (2Tₛ)
    A⁻ = (2a - 1) / (2Tₛ)

    b = ones(N)
    b[1] = 1 + A⁻ * Tₚ

    M = spdiagm(-1 => -A⁻ * ones(N - 1), 0 => +A⁺ * ones(N + 0))
    U = similar(mesh.z)

    U[1] = Tₚ
    U[2:end] = M \ b

    return U
end -->

Abaixo adicionamos a solução do problema sobre malhas grosseiras sobre as
soluções desenvolvidas anteriormente. A ideia de se representar sobre malhas
grosseiras é simplesmente ilustrar o caráter discreto da solução, que é
representada como constante no interior de uma célula. Adicionalmente
representamos no gráfico um resultado interpolado de uma simulação CFD 3-D de um
reator tubular em condições *supostamente identicas* as representadas aqui, o
que mostra o bom acordo de simulações 1-D no limite de validade do modelo.

<!-- let
    case = "fluent-reference"
    data = readdlm("c01-reator-pistao/$(case)/postprocess.dat", Float64)
    x, Tₑ = data[:, 1], data[:, 2]

    mesh = ImmersedConditionsFVM(; L = reactor.L, N = 10000)

    z = mesh.z
    ĥ = computehtc(; reactor..., fluid..., u = operations.u)

    pars = (z = z, ĥ = ĥ, P = P, A = A, ρ = fluid.ρ, cₚ = fluid.cₚ, operations...)

    model = DifferentialEquationPFR()
    Tₐ = analyticalthermalpfr(; pars...)
    Tₒ = solveodepfr(; model = model, pars...)[:T]

    standardplot(quote
        lines!(ax, $z, $Tₐ, color = :red, linewidth = 5, label = "Analítica")
        lines!(ax, $z, $Tₒ, color = :black, linewidth = 2, label = "EDO")
        lines!(ax, $x, $Tₑ, color = :blue, linewidth = 2, label = "CFD")

        for N in [20, 100]
            meshN = ImmersedConditionsFVM(; L = $reactor.L, N = N)
            T = solvethermalpfr(; mesh = meshN, $pars...)
            stairs!(ax, meshN.z, T; label = "N = $(N)", step = :center)
            # Experimente substituir a linha acima pelo código abaixo:
            # lines!(ax, meshN.z, T; label = "N = $(N)")
        end

        Tend = @sprintf("%.2f", $Tₐ[end])
    end)
end -->

Com isso encerramos essa primeira introdução a modelagem de reatores do tipo
pistão. Estamos ainda longe de um modelo generalizado para estudo de casos de
produção, mas os principais blocos de construção foram apresentados. Os pontos
principais a reter deste estudo são:

- A equação de conservação de massa é o ponto chave para a expansão e
  simplificação das demais equações de conservação. Note que isso é uma
  consequência de qua a massa corresponde à aplicação do [Teorema de Transporte
  de Reynolds](https://pt.wikipedia.org/wiki/Teorema_de_transporte_de_Reynolds)
  sobre a *unidade 1*. 

- Sempre que a implementação permita, é mais fácil de se tratar o problema como
  uma EDO e pacotes como ModelingToolkit proveem o ferramental básico para a
  construção deste tipo de modelos facilmente.

- Uma implementação em volumes finitos será desejável quando um acoplamento com
  outros modelos seja envisajada. Neste caso a gestão da solução com uma EDO a
  parâmetros variáveis pode se tornar computacionalmente proibitiva, seja em
  complexidade de código ou tempo de cálculo.

<!-- Isso é tudo para esta sessão de estudo! Até a próxima!

"Paramêtros do reator."
const reactor = notedata.c01.reactor

"Parâmetros do fluido"
const fluid = notedata.c01.fluid

"Parâmetros de operação."
const operations = notedata.c01.operations

"Perímetro da seção circular do reator [m]."
const P = π * reactor.D

"Área da seção circula do reator [m²]."
const A = π * (reactor.D / 2)^2

"Gráficos padronizados para este notebook."
function standardplot(toplot, yrng = (300, 400))
    ex = quote
        let
            fig = Figure(resolution = (720, 500))
            ax = Axis(fig[1, 1])
            $toplot
            xlims!(ax, (0, $reactor.L))
            ax.title = "Temperatura final = $(Tend) K"
            ax.xlabel = "Posição [m]"
            ax.ylabel = "Temperatura [K]"
            ax.xticks = range(0.0, $reactor.L, 6)
            ax.yticks = range($yrng..., 6)
            ylims!(ax, $yrng)
            axislegend(position = :rb)
            fig
        end
    end

    return eval(ex)
end -->
