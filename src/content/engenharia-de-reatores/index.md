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
[Pluto.jl](https://plutojl.org/). Essas páginas não possuem link de retorno
aqui, então se necessário é importante não fechar esta *tab*. No canto direito
superior das páginas você encontra um botão para exportar em alguns formatos,
incluindo *Notebook file*, que pode em seguida ser executado localmente ou em
seu *cloud* de preferência para estudar os materiais. Os notebooks criam seu
próprio ambiente de pacotes e contém eventualmente ferramentas que não se
encontram no `Project.toml` do repositório principal. Essa escolha visa a menor
latência quando executando notebooks localmente para acelerar o estudo.

## Conteúdos

~~~
<ol>
  <li style="height: 25px;">
    <a href="001-reator-pistao" target="_blank">
        Reator pistão - introdução
    </a>
  </li>

  <!-- <li style="height: 25px;">
    <a href="c02-reator-pistao.html" target="_blank">
      Reator pistão - Parte 2
    </a>
  </li>
  <li style="height: 25px;">
    <a href="#" target="_blank" style="pointer-events: none">
      Reator pistão - Parte 3
    </a>
  </li>
  <li style="height: 25px;">
    <a href="c99-reator-pistao.html" target="_blank">
      Reator pistão - Planejamento
    </a>
  </li> -->
</ol> 
~~~

## Ambições do projeto

~~~
<ol>
<li style="height: 25px;">
  <input type="checkbox" checked />
  <label>Solução térmica de um reator incompressível formulado em termos da temperatura.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" checked />
  <label>O precedente mas formulado em termos da entalpia.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" checked />
  <label>O precedente para um par de reatores em contra-corrente.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>O precedente generalizado para um sólido e um gás (compressível).</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>O precedente com coeficiente HTC dependente da posição.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>O precedente com trocas térmicas com o ambiente externo.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>O precedente com inclusão de perda de carga na fase gás.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>O precedente com um modelo de trocas térmicas com meio poroso.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>O precedente com um modelo de efeitos difusivos axiais no sólido.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>O precedente com inclusão da entalpia de fusão no sólido.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>O precedente com inclusão de cinética química no gás.</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>Suporte à fluidos supercríticos (água, dióxido de carbono).</label>
</li>
<li style="height: 25px;">
  <input type="checkbox" />
  <label>...</label>
</li>
</ol>
~~~