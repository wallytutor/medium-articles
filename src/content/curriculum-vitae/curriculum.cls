%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% curriculum.cls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{curriculum}[2023/07/24 v0.1]
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{europasscv}}
\ProcessOptions\relax
\LoadClass{europasscv}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% PACKAGES
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Language definitions.
\RequirePackage[
  portuguese,%
  english,%
  french
]{babel}%

%% Manually entered bibliographic entries.
\RequirePackage{bibentry}%

%% Chemical forumulas.
\RequirePackage{chemformula}%

%% Provide columns background.
\RequirePackage[most]{tcolorbox}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CONFIGURATION
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Configure aspect of links.
\hypersetup{%
    pdftoolbar        = {true},      % show Acrobat’s toolbar?
    pdfmenubar        = {true},      % show Acrobat’s menu?
    pdffitwindow      = {false},     % window fit to page when opened
    pdfstartview      = {FitH},      % fits the page width to the window
    %
    bookmarksopen     = {true},      %
    bookmarksnumbered = {true},      %
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% PUBLIC
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\myAcademic}[5]{%
  \ecvtitle{#1}{#2}%
  \ecvitem{#3}{#4}%
  \ecvitem{Advisor}{#5}%
}

\newtcolorbox{skillbox}[1][]{%
  nobeforeafter,%
  enhanced jigsaw,%
  sharp corners,%
  clip upper,%
  leftright skip = 0pt,%
  boxrule        = 0pt,%
  boxsep         = 4pt,%
  top            = 0pt,%
  bottom         = 0pt,%
  left           = 0pt,%
  right          = 0pt,%
  coltitle       = white,%
  colframe       = white,%
  colback        = white,%
  coltext        = ecvtextcolor,%
  {#1}
}

\newcommand{\barplot}[1]{%
\begin{skillbox}%
  \begin{flushleft}%
    \begin{tikzpicture}%
      \def\posy{0.0}%
      \def\step{0.8}%
      \def\yskipa{0.40}%
      \def\yskipb{0.23}%
      \foreach \s/\x in {#1}%
      {%
        \node[right] at (0, \posy) {\small{\s}};%
        %
        \fill[ecvhighlightcellcolor]%
          (0, \posy-\yskipa) rectangle (1\textwidth,  \posy-\yskipb);%
        %
        \fill[ecvrulecolor]%
          (0, \posy-\yskipa) rectangle (\x\textwidth, \posy-\yskipb);%
        %
        \pgfmathparse{\posy-\step}%
        \xdef\posy{\pgfmathresult}%
      }%
    \end{tikzpicture}%
  \end{flushleft}%
\end{skillbox}%
}

\endinput