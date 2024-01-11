### A Pluto.jl notebook ###
# v0.19.30

using Markdown
using InteractiveUtils

# ╔═╡ 6f694879-9008-407c-b3cb-ab0340a0713a
begin
	@info "Ativando ferramentas"
    import Pkg

	if Base.active_project() != Base.current_project()
    	Pkg.activate(Base.current_project())
    	Pkg.instantiate()
	end
	
    using PlutoUI
    TableOfContents(title = "Tópicos")
end

# ╔═╡ 06957190-5207-11ee-34ad-638d21453389
md"""
# Parte 0 - Prêambulo e Pluto
"""

# ╔═╡ 60552cbc-902d-44d1-993c-6133786a810f
md"""
## Sobre Julia e a série

Neste tutorial apresentamos os elementos básicos para se seguir a série em relação a linguagem de programação [Julia](https://julialang.org/) e algumas particularidade do uso de [Pluto](https://plutojl.org/). Os conteúdos aqui apresentados são uma extensão daqueles providos pela [JuliaAcademy](https://juliaacademy.com/) em seu [curso introdutório](https://github.com/JuliaAcademy/Introduction-to-Julia). O objetivo desta extensão é apresentar alguns elementos suplementares para a prática de computação científica. A temática de gráficos em Julia, será abordada em um tutorial distinto do curso no qual nos baseamos dada a necessidade de ir um pouco além na qualidade gráfica para publicações em *journals*.

Julia é sintaticamente uma linguagem similar à [Python](https://www.python.org/) mas o estilo de programação tipicamente adotado tende a ser procedural com uso de estruturas e métodos para processar dados contidos nestas. Esta nova linguagem publicada pela primeira vez em 2012 vem ganhando grante *momentum* e uma comunidade bastante interessante na sua diversidade científica. Após alguns anos hesitando em me engajar no seu uso para aplicações em pesquisa em desenvolvimento, em 2023 fui convencido que é chegada hora de transferir parte dos estudos em Julia e então adaptar todos os conteúdos que produzo nesta linguagem.

Recomenda-se o estudo do presente tutorial de forma interativa em uma longa seção de aproximadamente 4 horas de estudo. Após este primeiro contato, a leitura do livro e seus tutoriais se tornará acessível mesmo para aqueles que estão tendo seu primeiro contato com computação. Este tutorial pode ao longo do estudo ser consultado para clarificar elementos da linguagem. Uma vez que se encontre confortável com o conteúdo aqui apresentado, recomenda-se estudar o [manual](https://docs.julialang.org/en/v1/manual/getting-started/) da linguagem, o qual apresenta detalhes omitidos nesta introdução almejada para um primeiro contato.

!!! tip "Dica"

    Julia possui um largo ecossistema de pacotes implementado uma vasta gama de funcionalidades. Para conhecer mais não deixe de visitar [Julia Packages](https://juliapackages.com/).
"""

# ╔═╡ 17abe3b3-ed55-4bb5-a289-992cd4cebfc0
md"""
## Introdução à Pluto

Pluto é uma ferramenta reativa de programação em Julia permiting a concepção de *notebooks*, *i.e* documentos de programação literada aonde o código e o texto/teoria encontram-se juntos. Por reativa entende-se que há interatividade dos elementos e as atualizações de valores propagam-se diretamente. Por exemplo, com *Pluto*, para facilitar a navegação, na próxima célula usamos `TableOfContents` que produz a lista de tópicos interativa que vemos a direita.

Para quem vem de Python, Pluto é o equivalente à Jupyter e suas variantes, com a vantagem de que os documentos produzidos são código puro em Julia, permitindo o controle de versão com *git* - o que é um problema com Jupyter, que encapsula programas dentro de uma estrutura HTML, podendo mesmo salvar figuras e dados em formato binário, o que produz arquivos de tamanhos eventualmente absurdos, além das vulnerabilidades associadas.
"""

# ╔═╡ b188844b-b73b-4187-bd83-e2c388be5fc3
md"""
Este *notebook* e os diversos que se seguem nesta série são concebidos com a tecnologia [Pluto](https://plutojl.org/). Pluto foi concebido principalmente para o ensino e reproductibilidade de *notebooks*. Duas particularidades são advindas as escolhas de design de Pluto que você precisa saber antes de prosseguir:

1. Uma variável pode ser atribuída em uma única célula no contexto global, o que é na verdade uma boa prática de programação e dá segurança a correta execução do programa. Pluto desativa automaticamente células tentando redefinir variáveis.

1. Dado o caráter educacional e para a apresentação de resultados, somente uma expressão é permitida por célula. Para realizar várias declarações em conjunto, devemos encapsulá-las em um bloco como se segue [^1]:

```julia
begin
...
end
```

ou então

```julia
let
...
end
```

[^1]: Existem outras aplicações deste bloco de [expressões compostas](https://docs.julialang.org/en/v1/manual/control-flow/#man-compound-expressions) na linguagem num contexto de concepção de programas e pacotes, os quais veremos no seu devido tempo.
"""

# ╔═╡ dae96e7b-d193-48aa-9fcf-11ae4bde5561
md"""
Blocos `begin ... end` expõe todas as variáveis de seu contexto ao global e retornam a última expressão avaliada, enquanto `let ... end` retorna unicamente a última expressão avaliada. As definições de *escopo de variáveis*, ou seja, a região do código podendo acessar uma variável, normalmente são introduzidas mais tarde em cursos de programação. Vamos avançar um pouco o conteúdo deste tópico dada sua necessidade para se utilizar Pluto corretamente.

Vejamos os exemplos que se seguem.
"""

# ╔═╡ 40ef4210-35c5-456f-8d67-1733977a2eaf
md"""
### Bloco `begin`

No exemplo abaixo declaramos `a` e `b` dentro de um contexto `begin ... end`. Observe o valor `2` que aparece acima da célula, indicando que a última variável é *retornada* pelo contexto.
"""

# ╔═╡ eda9e357-c68f-4a5c-bdc6-b3c6a3583c64
begin
    a = 1
    b = 2
end

# ╔═╡ 9ba0443e-8cf0-49a1-954c-eb506d266823
md"""
Abaixo podemos averiguar que ambas são visíveis no contexto global, quer dizer, fora do bloco `begin ... end` no qual foram declaradas.
"""

# ╔═╡ 265d2df7-b7a6-4c4a-9f74-e751d7ba6845
a, b

# ╔═╡ 04b6a02a-a1d3-4d7a-a58c-d388a257a98d
md"""
Experimente apagar o indicativo de comentário `#` da célula que segue e executá-la:
"""

# ╔═╡ 206d9224-fb25-4995-b449-cb67fcf87b2d
# a = 3

# ╔═╡ 0f166c7d-be43-4e69-a961-d2e58b873e34
md"""
### Bloco `let`

Vamos fazer um experimento similar com `let ... end` mas usando outros nomes de variáveis para evitar confusão. Novamente encontramos o valor `3` da última variável sobre a célula, indicando seu retorno.
"""

# ╔═╡ 589f2573-1e14-4db8-be63-7cf635f84754
let
    c = 2
    d = 3
end

# ╔═╡ 67440ef5-2731-4acb-ba0b-cf282615ed79
md"""
Tentemos agora acessar `c` e `d` fora do contexto: encontramos um `UndefVarError` indicando que a variável `c` não é definida. O erro encerra a execução da célula por aí, não indicando nada a respeito de `d`, que também é indefinida neste escopo.
"""

# ╔═╡ ba9450ae-628b-46a9-9bae-9276442bc8ef
c, d

# ╔═╡ e52c0aaa-8e37-4f33-9ba0-b4fef4dc5631
md"""
Repetimos o bloco acima com a adição de uma declaração em sua última linha. Observe que *capturamos* os valores empregando outros *nomes* `e` e `f`:
"""

# ╔═╡ 228cb901-f577-4698-88cd-9027e10fb556
e, f = let
    c = 1
    d = 2
    c, d
end

# ╔═╡ 5d89fbc8-3ca1-4328-9dfd-1f2d12e7b1bf
md"""
Verificamos abaixo que ambas as variáveis são visíveis globalmente.
"""

# ╔═╡ 2576f7e6-a890-4e54-babe-895502a1e94f
e, f

# ╔═╡ 0ddb1e39-0c06-4437-aa03-1571bec2cf4e
md"""
### Contexto `local`

Em algumas aplicações bem específicas - por exemplo, quando estamos estudando variantes de um mesmo problema em um notebook - gostaríamos de reusar os nomes de variáveis. Isso é possível graças à palavra-chave `local` que indica que uma variável não deve ser visível fora do bloco de declaração.

Na célula abaixo declaramos `x` como local e atribuímos o resultado à `y1`.
"""

# ╔═╡ cb5e5f4a-528c-4c0f-84f9-ac6aa19fde86
y1 = begin
    local x = 1
    x + 1
end

# ╔═╡ 883ee654-74fa-44ff-b3d6-9d5918122aae
md"""
Não encontramos problemas para declarar um novo `x`. Ao invés de atribuirmos o retorno do bloco, neste caso decidimos de ilustrar a atribuição de `y2` dentro do contexto.
"""

# ╔═╡ 5f7589d6-ce9e-4836-918b-00382d3abf2d
begin
    local x = 2 
	y2 = x + 2
end

# ╔═╡ 7b63d877-25de-44a4-88ab-e9ac97fbec82
md"""
Confirmamos abaixo a inexistência de `x` no contexto global.
"""

# ╔═╡ 10690fa3-6aa8-4791-bf24-f177e956c3cf
x

# ╔═╡ 64e4652b-da49-42ee-abce-d5c3f804c0a8
md"""
Em contrapartida, ambas `y1` e `y2` são acessíveis.
"""

# ╔═╡ 892a900f-a41b-4e72-91d4-252e3f7d01c6
y1, y2

# ╔═╡ 290f062c-02e6-48fb-8d01-3d7acf14682a
md"""
Uma outra aplicação de `local` é para criar localmente uma variável que *talvez* já exista no contexto `global`. Vemos abaixo o valor de `e` criada num exemplo anterior.
"""

# ╔═╡ d2da6172-cca8-443e-8026-c4f712dab624
e

# ╔═╡ 75c28e55-0cc6-40d3-a45b-3421b5c5c5ba
md"""
Usando `local` podemos declarar um novo `e` e mesmo realizar uma operação sobre esta variável. Isso não impacta o valor de `e` global, caso contrário a célula acima seria atualizada pelo caráter reativo de Pluto.
"""

# ╔═╡ 11a5d756-840e-455a-be0a-ae47f15f59db
begin
    local e = 1
    e = e + 2
end

# ╔═╡ a945640d-4097-4ede-bed6-cb39b2aa1864
md"""
### Atalhos importantes

| Ação                          | Atalho                 |
| ----------------------------: | :--------------------- |
| Executar uma célula           | `<Shift> + <Enter>`    |
| Adicionar/remover comentários | `<Ctrl> + /`           |
| Listar todos os atalhos       | `<Ctrl> + <Shift> + ?` |

Para mais operações consulte esta [wiki](https://github.com/fonsp/Pluto.jl/wiki/%F0%9F%94%8E-Basic-Commands-in-Pluto).
"""

# ╔═╡ 10efa2ce-13fc-4aa4-bedd-226f95f9ab8c
md"""
## Ciência colaborativa

Uma dificuldade recorrente encontrada em projetos científicos contendo uma componente numérica é o despreparo dos colaboradores para a gestão de dados e documentos. Essa dificuldade não é somente técnica, mas frequentemente a origem de discórdias nos projetos.

O estudo de Julia ou qualquer outra ferramenta para suporte computacional em ciência não tem sentido sem o caráter aplicativo no contexto de um projeto, seja ele acadêmico ou industrial. Neste anexo vamos abordar algumas ferramentas complementares ao uso de Julia úteis para o cientista e apontar os caminhos para encontrá-las e aprender mais sobre elas sem entrar nos detalhes de seus usos. A lista provida não é exaustiva mas contém um esqueleto mínimo que toda pesquisa séria deveria adotar para prover materiais com controle de qualidade e versionagem adequada.

Para estudar aspectos computacionais em ciência você precisa de alguns componentes de suporte à linguagem de programação usada, em nosso caso Julia. No que se segue vamos apresentar:

- O editor de texto recomendado VS Code e a extensão requerida.
- A linguagem ``\LaTeX`` usada para a entrada de equações nos notebooks e artigos.
- As ferramentas necessárias para editar ``\LaTeX`` fora do contexto de Julia.
- E finalmente o sistema de versionagem Git.
- Outras ferramentas de suporte.
"""

# ╔═╡ f7720cc7-b631-44de-abf7-9f9222fcca42
md"""
#### VS Code

Nos últimos anos [VSCode](https://code.visualstudio.com/) se tornou o editor mais popular da comunidade *open source* e com toda razão. A qualidade da ferramenta provida pela Microsoft chegou a um nível que é difícil justificar o uso de um editor de código comercial. Aliado a isso, com a extensão [Julia VSCode](https://www.julia-vscode.org/) um suporte avançado a edição de código e documentação da linguagem é disponível. Além disso, a ferramenta provê [integração com o sistema de controle de versões Git](https://code.visualstudio.com/docs/sourcecontrol/overview) que vamos discutir no que se segue.
"""

# ╔═╡ 929e4bcd-fbe5-4681-b4fb-f2c8c070c5cc
md"""
#### ``\LaTeX``

Para a entrada de equações nos notebooks, [Julia markdown](https://docs.julialang.org/en/v1/stdlib/Markdown/) provê suporte à renderização de ``\LaTeX``. É fundamental ter algum domínio desta linguagem para a elaborção de documentos científicos. As distribuições mais populares são [MiKTeX](https://miktex.org/) para Windows e [TeX Live](https://tug.org/texlive/) para os demais sistemas operacionais. Ademais, artigos escritos usando a linguagem são aceitos pelas publicações mais relevantes em várias áreas do conhecimento. Outra razão para o uso de ``\LaTeX`` é a estocagem de documentos em formato de texto bruto, o que permite um controle de versões com Git.
"""

# ╔═╡ f35d4bbb-f2ac-4930-bbcc-3a0d575dab57
md"""
#### TeXStudio

Em complemento à distribuição de ``\LaTeX`` é necessário um editor de texto adaptado. Embora existam extensões excelentes para realizar a compilação dos documentos [^1] para VS Code, elas não são muito fáceis de se compreender para um iniciante. Por isso recomendamos [TeXStudio](https://www.texstudio.org/) para editar e compilar documentos escritos em ``\LaTeX``.

[^1]: Por compilação entende-se em nossos dias transformar o documento em PDF.
"""

# ╔═╡ b9280638-50c5-4fcc-8e5f-0aab56ca575c
md"""
#### JabRef

Embora as referências bibliográficas possam ser inseridas diretamente em documentos ``\LaTeX``, o ideal é utilizar uma base de dados comum que possa ser reutilizada ao longo da carreira de pesquisa. [JabRef](https://www.jabref.org/) é um gestor de bibliografia para o formato ``BibTeX`` suportado por ``\LaTeX`` que estoca dados diretamente em formato textual. A interface gráfica é fácil de interagir e dado o formato de documento, as bases *.bib* são compatíveis com Git. 
"""

# ╔═╡ 4f64f8b6-0964-4e4a-b8fe-44bc9b386b3b
md"""
#### Git

Falamos bastante em [Git](https://git-scm.com/downloads) até o momento sem entrar em mais detalhes de que é uma ferramenta de controle de versões. Git elimina a prática insana de se salvar manualmente várias cópias de um mesmo documento para gerir versões. O sistema basea-se na comparação de conteúdos e propõe de se salvar unicamente os documentos modificados em um projeto. Embora seu uso básico seja bastante simples e plausível de se aprender em uma tarde de estudo, a ferramenta é bastante complexa e complexa, permitindo de voltar em pontos históricos de um projeto, publicar *releases*, etc. Para uma pesquisa sã e durável, o uso de documentos em formatos aceitando texto bruto em conjunto com Git é ideal.
"""

# ╔═╡ 9ac647d7-f811-4cfa-8020-2a8e0c211f8f
md"""
#### Python

Embora esse seja um curso de Julia, é importante que o cientista também tenha conhecimento de [Python](https://www.python.org/). Python é uma linguagem generalista que também é bastante rica em termos de pacotes para aplicações científicas. Em termos de aprendizado é relativamente mais simples que Julia, com o porém que código nativo em Python é extremamente lento, requerindo sempre o uso de bibliotecas que na verdade são implementadas em C, Fortran, Rust, etc. Para a concepção de aplicações web especialmente a linguagem encontra-se num estado de maturidade bastante superior à Julia e não deve ser negligenciada. Ademais, encontra-se entre as linguagens mais utilizadas no mundo, enquanto Julia é uma linguagem de nicho.
"""

# ╔═╡ f44000ef-c6e4-419d-a6da-eb809ddb6629
md"""
#### GNUPlot

Embora tratemos da temática de gráficos para publicações no curso, uma alternativa sempre é interessante. [GNUPlot](http://www.gnuplot.info/) é uma ferramenta *open source* contando com sua própria linguagem para geração de gráficos. É uma ferramenta interessante principalmente quando se deseja padronizar todas as figuras em um projeto através de arquivos de configuração.
"""

# ╔═╡ 07a43302-09d5-444c-b215-ad3c6e587762
md"""
Encerramos aqui este preâmbulo, nos vemos nos tutoriais!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─06957190-5207-11ee-34ad-638d21453389
# ╟─60552cbc-902d-44d1-993c-6133786a810f
# ╟─17abe3b3-ed55-4bb5-a289-992cd4cebfc0
# ╟─6f694879-9008-407c-b3cb-ab0340a0713a
# ╟─b188844b-b73b-4187-bd83-e2c388be5fc3
# ╟─dae96e7b-d193-48aa-9fcf-11ae4bde5561
# ╟─40ef4210-35c5-456f-8d67-1733977a2eaf
# ╠═eda9e357-c68f-4a5c-bdc6-b3c6a3583c64
# ╟─9ba0443e-8cf0-49a1-954c-eb506d266823
# ╠═265d2df7-b7a6-4c4a-9f74-e751d7ba6845
# ╟─04b6a02a-a1d3-4d7a-a58c-d388a257a98d
# ╠═206d9224-fb25-4995-b449-cb67fcf87b2d
# ╟─0f166c7d-be43-4e69-a961-d2e58b873e34
# ╠═589f2573-1e14-4db8-be63-7cf635f84754
# ╟─67440ef5-2731-4acb-ba0b-cf282615ed79
# ╠═ba9450ae-628b-46a9-9bae-9276442bc8ef
# ╟─e52c0aaa-8e37-4f33-9ba0-b4fef4dc5631
# ╠═228cb901-f577-4698-88cd-9027e10fb556
# ╟─5d89fbc8-3ca1-4328-9dfd-1f2d12e7b1bf
# ╠═2576f7e6-a890-4e54-babe-895502a1e94f
# ╟─0ddb1e39-0c06-4437-aa03-1571bec2cf4e
# ╠═cb5e5f4a-528c-4c0f-84f9-ac6aa19fde86
# ╟─883ee654-74fa-44ff-b3d6-9d5918122aae
# ╠═5f7589d6-ce9e-4836-918b-00382d3abf2d
# ╟─7b63d877-25de-44a4-88ab-e9ac97fbec82
# ╠═10690fa3-6aa8-4791-bf24-f177e956c3cf
# ╟─64e4652b-da49-42ee-abce-d5c3f804c0a8
# ╠═892a900f-a41b-4e72-91d4-252e3f7d01c6
# ╟─290f062c-02e6-48fb-8d01-3d7acf14682a
# ╠═d2da6172-cca8-443e-8026-c4f712dab624
# ╟─75c28e55-0cc6-40d3-a45b-3421b5c5c5ba
# ╠═11a5d756-840e-455a-be0a-ae47f15f59db
# ╟─a945640d-4097-4ede-bed6-cb39b2aa1864
# ╟─10efa2ce-13fc-4aa4-bedd-226f95f9ab8c
# ╟─f7720cc7-b631-44de-abf7-9f9222fcca42
# ╟─929e4bcd-fbe5-4681-b4fb-f2c8c070c5cc
# ╟─f35d4bbb-f2ac-4930-bbcc-3a0d575dab57
# ╟─b9280638-50c5-4fcc-8e5f-0aab56ca575c
# ╟─4f64f8b6-0964-4e4a-b8fe-44bc9b386b3b
# ╟─9ac647d7-f811-4cfa-8020-2a8e0c211f8f
# ╟─f44000ef-c6e4-419d-a6da-eb809ddb6629
# ╟─07a43302-09d5-444c-b215-ad3c6e587762
