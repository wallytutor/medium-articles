# Parte 17 - Interoperação com C

Neste tutorial vamos ilustrar como usar uma biblioteca de link dinâmico (DLL) em Julia. Essa atividade é recorrente em computação científica quando desejamos realizar interface de código externo -- normalmente bibliotecas mais antigas ou aceitas como de alta performance -- com código desenvolvido para aplicações específicas.

Escolhemos como caso de estudo a avaliação de propriedades de transporte em produtos de combustão em termos de uma composição local. Isso é possível de ser realizado através do pacote Cantera, que pelo momento não é disponível em Julia [^1]. As interfaces em C da *DLL* [^2] de Cantera incluem o arquivo de cabeçalho [clib_defs.h](https://cantera.org/documentation/docs-2.6/doxygen/html/dd/d7b/clib__defs_8h.html).

[^1]: Funções de Cantera poderiam ser facilmente acessadas através da interface em Python, mas isso adicionaria a necessidade de se utilizar Conda e a interface de chamada de funções em Python. Por razões evidentes e para manter o sentido deste tutorial vamos negligenciar essa possibilidade.

[^2]: Nos sistemas operacionais Linux (e similares) e Mac OS a terminologia para uma biblioteca compartilhada utiliza a extensão `.so`. Para nosso deleito Julia leva em conta essas diferenças e veremos que o nome da biblioteca não necessita especificar a extensão do arquivo.

## Preparando Cantera

## Interface das funções necessárias

## Uso e validação da interface

Isso é tudo para esta sessão de estudo! Até a próxima!

