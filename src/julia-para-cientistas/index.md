---
title  : Julia para Cientistas
author : Walter Dal'Maz Silva
date   : `j import Dates; Dates.Date(Dates.now())`
weave_options:
  error: false
  term: false
  wrap: true
  line_width: 100
---

# Julia para Cientistas

Julia *from zero to hero* com uma abordagem para computação científica.

Antes de entrar realmente nos tópicos de estudo listados abaixo, vamos falar um pouco sobre alguns elementos básicos para se seguir a série em relação a linguagem de programação [Julia](https://julialang.org/). Os conteúdos aqui apresentados são uma extensão daqueles providos pela [JuliaAcademy](https://juliaacademy.com/) em seu [curso introdutório](https://github.com/JuliaAcademy/Introduction-to-Julia). O objetivo desta extensão é apresentar alguns elementos suplementares para a prática de computação científica. A temática de gráficos em Julia, será abordada em um tutorial distinto do curso no qual nos baseamos dada a necessidade de ir um pouco além na qualidade gráfica para publicações em *journals*.

Julia é uma linguagem sintaticamente similar à [Python](https://www.python.org/) mas o estilo de programação tipicamente adotado tende a ser procedural com uso de estruturas e métodos para processar dados contidos nestas. Esta nova linguagem publicada pela primeira vez em 2012 vem ganhando grante *momentum* e uma comunidade bastante interessante na sua diversidade científica. Após alguns anos hesitando em me engajar no seu uso para aplicações em pesquisa em desenvolvimento, em 2023 fui convencido que é chegada hora de transferir parte dos estudos em Julia e então adaptar todos os conteúdos que produzo nesta linguagem.

Recomenda-se o estudo do presente tutorial de forma interativa em uma longa seção de aproximadamente 4 horas de estudo. Após este primeiro contato, os tutorials mais complexos que se seguem se tornarão acessíveis mesmo para aqueles que estão tendo seu primeiro contato com computação. Este tutorial pode ao longo do estudo ser consultado para clarificar elementos da linguagem. Uma vez que se encontre confortável com o conteúdo aqui apresentado, recomenda-se estudar o [manual](https://docs.julialang.org/en/v1/manual/getting-started/) da linguagem, o qual apresenta detalhes omitidos nesta introdução almejada para um primeiro contato.

!!! tip "Dica"

    Julia possui um largo ecossistema de pacotes implementado uma vasta gama de funcionalidades. Para conhecer mais não deixe de visitar [Julia Packages](https://juliapackages.com/).

## Conteúdos

1. [Primeiros Passos](001-primeiros-passos.html)
1. [Manipulacao Textual](002-manipulacao-textual.html)
1. [Estruturas De Dados](003-estruturas-de-dados.html)
1. [Estruturas De Dados](004-estruturas-de-dados.html)

```julia; echo = false
# 1. [Lacos E Condicionais](005-lacos-e-condicionais.md)
# 1. [Funcoes E Despacho](006-funcoes-e-despacho.md)
# 1. [Pacotes E Ecossistema](007-pacotes-e-ecossistema.md)
# 1. [Avaliando Performance](008-avaliando-performance.md)
# 1. [Algebra Linear](009-algebra-linear.md)
# 1. [Expressoes Regulares](010-expressoes-regulares.md)
# 1. [Execucao Concorrente](011-execucao-concorrente.md)
# 1. [Trabalhando Com Arquivos](012-trabalhando-com-arquivos.md)
# 1. [Bibliotecas Graficas](013-bibliotecas-graficas.md)
# 1. [Graficos Para Publicacoes](014-graficos-para-publicacoes.md)
# 1. [Tipos De Dados E Estruturas](015-tipos-de-dados-e-estruturas.md)
# 1. [Metaprogramacao E Macros](016-metaprogramacao-e-macros.md)
# 1. [Interoperacao Com C](017-interoperacao-com-c.md)
# 1. [Equações diferenciais ordinárias](index.md)
# 1. [Equações diferenciais parciais](index.md)
# 1. [Redes neuronais clássicas](index.md)
# 1. [Aprendizado com suporte físico](index.md)
# 1. [Análise quantitativa de imagens](index.md)
# 1. [Criando seus próprios pacotes](index.md)
```

## Seguindo os materiais

Os conteúdos são majoritariamente sequenciais: exceto para os tópicos mais avançados (para aqueles que já programam em Julia), é necessário seguir os notebooks na ordem provida.

Um canal YouTube do curso está em fase de concepção para abordar os detalhes entre-linhas, involvendo aspectos que não necessariamente estão escritos.

Etapas à seguir para começar os estudos:

1. Ler sobre *ciência colaborativa* abaixo para se familiarizar com alguns elementos que vamos abordar no que se segue.

1. [Instalar Julia](https://julialang.org/downloads/) na versão estável para seu sistema operacional.

1. [Instalar Pluto](https://github.com/fonsp/Pluto.jl) para visualizar e editar os notebooks do curso.

1. Clonar este repositório com todos os materiais usando a seguinte ordem de prioridade:

    - Usando Git à través da linha de comando, forma recomendada com `git clone https://github.com/DryTooling/DryTooling.jl.git`

    - Com a interface gráfica de [GitHub Desktop](https://desktop.github.com/)

    - Usando o botão de [Download](https://github.com/DryTooling/DryTooling.jl/archive/refs/heads/main.zip)

Caso a última opção de download tenha sido a sua escolha, observe que o arquivo `.zip` não contem os elementos de *repositório git* para controle de versão, implicando que as suas modificações e notas tomadas deverão ser geridas localmente, o que não é recomendável. Para estudantes ainda não familiarizados com *git*, a opção de utilizar GitHub Desktop é a mais apropriada.

## Ciência colaborativa

Uma dificuldade recorrente encontrada em projetos científicos contendo uma componente numérica é o despreparo dos colaboradores para a gestão de dados e documentos. Essa dificuldade não é somente técnica, mas frequentemente a origem de discórdias nos projetos.

O estudo de Julia ou qualquer outra ferramenta para suporte computacional em ciência não tem sentido sem o caráter aplicativo no contexto de um projeto, seja ele acadêmico ou industrial. Neste anexo vamos abordar algumas ferramentas complementares ao uso de Julia úteis para o cientista e apontar os caminhos para encontrá-las e aprender mais sobre elas sem entrar nos detalhes de seus usos. A lista provida não é exaustiva mas contém um esqueleto mínimo que toda pesquisa séria deveria adotar para prover materiais com controle de qualidade e versionagem adequada.

Para estudar aspectos computacionais em ciência você precisa de alguns componentes de suporte à linguagem de programação usada, em nosso caso Julia. No que se segue vamos apresentar:

- O editor de texto recomendado VS Code e a extensão requerida.
- A linguagem ``\LaTeX`` usada para a entrada de equações nos notebooks e artigos.
- As ferramentas necessárias para editar ``\LaTeX`` fora do contexto de Julia.
- E finalmente o sistema de versionagem Git.
- Outras ferramentas de suporte.

### VS Code

Nos últimos anos [VSCode](https://code.visualstudio.com/) se tornou o editor mais popular da comunidade *open source* e com toda razão. A qualidade da ferramenta provida pela Microsoft chegou a um nível que é difícil justificar o uso de um editor de código comercial. Aliado a isso, com a extensão [Julia VSCode](https://www.julia-vscode.org/) um suporte avançado a edição de código e documentação da linguagem é disponível. Além disso, a ferramenta provê [integração com o sistema de controle de versões Git](https://code.visualstudio.com/docs/sourcecontrol/overview) que vamos discutir no que se segue.

### ``\LaTeX``

Para a entrada de equações nos notebooks, [Julia markdown](https://docs.julialang.org/en/v1/stdlib/Markdown/) provê suporte à renderização de ``\LaTeX``. É fundamental ter algum domínio desta linguagem para a elaborção de documentos científicos. As distribuições mais populares são [MiKTeX](https://miktex.org/) para Windows e [TeX Live](https://tug.org/texlive/) para os demais sistemas operacionais. Ademais, artigos escritos usando a linguagem são aceitos pelas publicações mais relevantes em várias áreas do conhecimento. Outra razão para o uso de ``\LaTeX`` é a estocagem de documentos em formato de texto bruto, o que permite um controle de versões com Git.

### TeXStudio

Em complemento à distribuição de ``\LaTeX`` é necessário um editor de texto adaptado. Embora existam extensões excelentes para realizar a compilação dos documentos [^1] para VS Code, elas não são muito fáceis de se compreender para um iniciante. Por isso recomendamos [TeXStudio](https://www.texstudio.org/) para editar e compilar documentos escritos em ``\LaTeX``.

[^1]: Por compilação entende-se em nossos dias transformar o documento em PDF.

### JabRef

Embora as referências bibliográficas possam ser inseridas diretamente em documentos ``\LaTeX``, o ideal é utilizar uma base de dados comum que possa ser reutilizada ao longo da carreira de pesquisa. [JabRef](https://www.jabref.org/) é um gestor de bibliografia para o formato ``BibTeX`` suportado por ``\LaTeX`` que estoca dados diretamente em formato textual. A interface gráfica é fácil de interagir e dado o formato de documento, as bases *.bib* são compatíveis com Git. 

### Git

Falamos bastante em [Git](https://git-scm.com/downloads) até o momento sem entrar em mais detalhes de que é uma ferramenta de controle de versões. Git elimina a prática insana de se salvar manualmente várias cópias de um mesmo documento para gerir versões. O sistema basea-se na comparação de conteúdos e propõe de se salvar unicamente os documentos modificados em um projeto. Embora seu uso básico seja bastante simples e plausível de se aprender em uma tarde de estudo, a ferramenta é bastante complexa e complexa, permitindo de voltar em pontos históricos de um projeto, publicar *releases*, etc. Para uma pesquisa sã e durável, o uso de documentos em formatos aceitando texto bruto em conjunto com Git é ideal.

### Python

Embora esse seja um curso de Julia, é importante que o cientista também tenha conhecimento de [Python](https://www.python.org/). Python é uma linguagem generalista que também é bastante rica em termos de pacotes para aplicações científicas. Em termos de aprendizado é relativamente mais simples que Julia, com o porém que código nativo em Python é extremamente lento, requerindo sempre o uso de bibliotecas que na verdade são implementadas em C, Fortran, Rust, etc. Para a concepção de aplicações web especialmente a linguagem encontra-se num estado de maturidade bastante superior à Julia e não deve ser negligenciada. Ademais, encontra-se entre as linguagens mais utilizadas no mundo, enquanto Julia é uma linguagem de nicho.

### GNUPlot

Embora tratemos da temática de gráficos para publicações no curso, uma alternativa sempre é interessante. [GNUPlot](http://www.gnuplot.info/) é uma ferramenta *open source* contando com sua própria linguagem para geração de gráficos. É uma ferramenta interessante principalmente quando se deseja padronizar todas as figuras em um projeto através de arquivos de configuração.

## Para aonde ir depois?

### Para aprender mais

[Julia Academy](https://juliaacademy.com/): nesta página encontram-se cursos abertos em várias temáticas comumente abordadas com a linguagem Julia. Você encontrará cursos parcialmente equivalentes aos materiais tratados aqui, mas também vários conteúdos que não são abordados nesta introdução, especialmente em tópicos ligados a Ciência de Dados.

[Introduction to Computational Thinking](https://computationalthinking.mit.edu/Fall23/): esse é provavelmente o melhor curso generalista para aplicações científicas da linguagem. O curso é ministrado inclusive pelo [Pr. Dr. Alan Edelman](https://en.wikipedia.org/wiki/Alan_Edelman) um dos criadores de Julia. Os tópicos abordados vão de tratamento de imagens, séries temporais, a resolução de equações diferenciais parciais.

[*SciML Book*](https://book.sciml.ai/): este livro é o resultado dos materiais de suporte do curso *Parallel Computing and Scientific Machine Learning (SciML): Methods and Applications* no MIT. Os tópicos são suportados por vídeo aulas e entram em mais profundidade nos assuntos avançados que tratamos aqui.

[Exercism Julia Track](https://exercism.org/tracks/julia): a plataforma  *Exercism* propõe no percurso de Julia vários exercícios de algoritmos de nível fácil à intermediário-avançado. Minha recomendação é que essa prática venha a complementar os materiais propostos acima como forma de sedimentar o aprendizado da linguagem.

[Julia Data Science](https://juliadatascience.io/): este livro complementa tópicos mais operacionais de análise de dados, especialemente técnicas básicas de Ciência de Dados, que omitimos neste curso. Um bom material complementar aos estudos.

### Comunidade Julia

[Julia Community Zulipchat](https://julialang.zulipchat.com/): precisando de ajuda ou buscando um projeto para contribuir? Este chat aberto da comunidade Julia é o ponto de encontro para discutir acerca dos diferenter projetos e avanços na linguagem.

[Julia Packages](https://juliapackages.com/): o repositório mestre do índice de pacotes escritos na linguagem Julia ou provendo interfaces à outras ferramentas. A página contém um sistema de busca e um índice por temas.

[JuliaHub](https://juliahub.com/): esta plataforma comercial provê tudo que é necessário para se passar da prototipagem à escala industrial de soluções concebidas em Julia. Atualmente é a norma em termos de escalabilidade para a linguagem.

### Organizações recomendadas

[SciML](https://sciml.ai/): pacotes para *Machine Learning* científico.

[JuMP](https://jump.dev/): uma linguagem de optimização matemática em Julia.

[JuliaData](https://github.com/JuliaData): pacotes para *Data Science* em geral.

[JuliaMolSim](https://juliamolsim.github.io/): simulação de dinâmica molecular em Julia.
