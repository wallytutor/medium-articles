+++
author        = "Walter Dal'Maz Silva"
mintoclevel   = 2
maxtoclevel   = 3
prepath       = "medium-articles"
ignore        = ["node_modules/"]
generate_rss  = false
hasplotly     = false
website_title = "WallyTutor's Articles"
website_descr = "Articles and more, all in Julia programming"
website_url   = "https://wallytutor.github.io/medium-articles/"
+++

\newcommand{\note}[2]{@@note @@title ⚠ #1 @@ @@content #2 @@ @@}
\newcommand{\warn}[2]{@@warning @@title ⚠ #1 @@ @@content #2 @@ @@}

\newcommand{\figenv}[2]{
    ~~~
    <figure style="text-align:center;">
      <img src="!#2" style="padding:0; width:100%;" alt="#1"/>
      <figcaption>#1</figcaption>
    </figure>
    ~~~
}

\newcommand{\patreon}{
  \note{Liked my content? }{
    Please help me be able to produce more by becoming
    my [Patreon](https://patreon.com/WallyTutor)!}
}
