+++
title   = "Engenharia de Reatores"
tags    = ["programming", "simulation", "physics"]
showall = true
+++

# Engenharia de Reatores

Neste tópico abordamos modelos de reatores de uma ótica que pode ser
simultâneamente útil em Engenharia Química e Engenharia Mecânica. Os modelos de
reator estudados incluem em alguns casos aspectos voltados a engenharia dos
aspectos térmicos e em outros elementos de cinética química. Isso inclui modelos
0-D de reatores perfeitamente agitados, modelos 1-D de reatores pistão, e outros
tópicos mais avançados.

O objetivo final da série é progressivamente introduzir complexidate em termos
da física considerada, mas também na organização de ferramentas para a concepção
e extensão de modelos genéricos de reators para integração dos modelos com
maturidade suficiente em
[DryTooling.jl](https://wallytutor.github.io/DryTooling.jl/dev/).

**Nota:** os links abaixo remetem a novas páginas que foram geradas usando
[Pluto.jl](https://plutojl.org/). Essas páginas não fazem parte da estrutura
normal deste site e não possuem link de retorno aqui, então se necessário é
importante não fechar esta *tab*. No canto direito superior das páginas você
encontra um botão para exportar em alguns formatos, incluindo *Notebook file*,
que pode em seguida ser executado localmente ou em seu *cloud* de preferência
para estudar os materiais. Os blocos de código nos notebooks foram
intencionalmente colapsados para que você precise executálos para um estudo de
qualidade. Os notebooks criam seu próprio ambiente de pacotes e contém
eventualmente ferramentas que não se encontram no `Project.toml` do repositório
principal. Essa escolha visa a menor latência quando executando notebooks
localmente para acelerar o estudo.

Para execução local, caso não deseje clonar todo o repositório para estudar,
é necessário salvar na mesma pasta que os notebooks este
[módulo](https://github.com/wallytutor/medium-articles/blob/main/src/content/engenharia-de-reatores/PlugFlowReactors.jl).

## Conteúdos

~~~
<table>
  <tr>
    <td>1</td>
    <td><input type="checkbox" checked /></td>
    <td>
      <a href="001-reator-pistao" target="_blank">
          Reator pistão - introdução
      </a>
      <hr style="padding: 0pt; margin: 5pt"/>
      Solução térmica de um reator incompressível formulado em termos da temperatura.
      O objetivo é de realizar a introdução ao modelo de reator pistão sem entrar em
      detalhes involvendo não-linearidades como a dependência da densidade em termos
      da temperatura ou composição. Ademais, essa forma permite uma solução analítica.
      Introduz o uso de ModelingToolkit e do método dos volumes finitos.
    </td>
  </tr>

  <tr>
    <td>2</td>
    <td><input type="checkbox" checked /></td>
    <td>
      <a href="002-reator-pistao" target="_blank">
        Formulação entálpica do reator pistão
      </a>
      <hr style="padding: 0pt; margin: 5pt"/>
      Casos práticos de aplicação de reatores normalmente envolvem fluidos com propriedades
      que dependem da temperatura, especialmente o calor específico. Em geral a sua solução
      é tratada de forma mais conveniente com uma formulação em termos da entalpia. Continuamos
      com o mesmo caso elaborado no estudo
      <a href="001-reator-pistao" target="_blank"> Reator pistão - introdução </a> modificando
      as equações para que a solução seja realizada com a entalpia como variável dependente.
    </td>
  </tr>

  <tr>
   <td></td>
    <td><input type="checkbox" checked /></td>
    <td>
      <a href="003-reator-pistao" target="_blank">
        Reatores em contra corrente
      </a>
      <hr style="padding: 0pt; margin: 5pt"/>
      O precedente para um par de reatores em contra-corrente.
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      <a href="004-reator-pistao" target="_blank">
        Trocas em fluidos supercríticos
      </a>
      <hr style="padding: 0pt; margin: 5pt"/>
      Suporte à fluidos supercríticos (água, dióxido de carbono).
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      O precedente generalizado para um sólido e um gás (compressível).
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      O precedente com coeficiente HTC dependente da posição.
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      O precedente com trocas térmicas com o ambiente externo.
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      O precedente com inclusão de perda de carga na fase gás.
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      O precedente com um modelo de trocas térmicas com meio poroso.
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      O precedente com um modelo de efeitos difusivos axiais no sólido.
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      O precedente com inclusão da entalpia de fusão no sólido.
    </td>
  </tr>

  <tr>
    <td></td>
    <td><input type="checkbox" /></td>
    <td>
      O precedente com inclusão de cinética química no gás.
    </td>
  </tr>
</table>
~~~
