# -*- coding: utf-8 -*-
using Weave
using Highlights.Tokens
using Highlights.Themes

const BUILDDIR = joinpath(@__DIR__(), "_build")

abstract type CustomTheme <: AbstractTheme end

# Modified version of Highlights.Themes.VimTheme
@theme CustomTheme Dict(
    :name => "Vim",
    :description => "A theme similar to the vim 7.0 default theme.",
    :comments => "Based on the theme from Pygments.",
    :style => S"bg: 000000; fg: cccccc",
    :tokens => Dict(
        COMMENT             => S"fg: 00ff00",
        COMMENT_PREPROC     => S"",
        COMMENT_SPECIAL     => S"bold; fg: cd0000",
        ERROR               => S"bg: ff0000",
        GENERIC_DELETED     => S"fg: cd0000",
        GENERIC_EMPH        => S"italic",
        GENERIC_ERROR       => S"fg: ff0000",
        GENERIC_HEADING     => S"bold; fg: 000080",
        GENERIC_INSERTED    => S"fg: 00cd00",
        GENERIC_OUTPUT      => S"fg: 888",
        GENERIC_PROMPT      => S"bold; fg: 000080",
        GENERIC_STRONG      => S"bold",
        GENERIC_SUBHEADING  => S"bold; fg: 800080",
        GENERIC_TRACEBACK   => S"fg: 04d",
        KEYWORD             => S"fg: cdcd00",
        KEYWORD_DECLARATION => S"fg: 00cd00",
        KEYWORD_NAMESPACE   => S"fg: cd00cd",
        KEYWORD_PSEUDO      => S"",
        KEYWORD_TYPE        => S"fg: 00cd00",
        NAME                => S"",
        NAME_BUILTIN        => S"fg: cd00cd",
        NAME_CLASS          => S"fg: 00cdcd",
        NAME_EXCEPTION      => S"bold; fg: 666699",
        NAME_VARIABLE       => S"fg: 00cdcd",
        NUMBER              => S"fg: cd00cd",
        OPERATOR            => S"fg: 3399cc",
        OPERATOR_WORD       => S"fg: cdcd00",
        STRING              => S"fg: cd0000",
        TEXT                => S"",
        WHITESPACE          => S"",
    )
)

function weaveall()
    @info "Weaving all documents..."
    for (root, _, files) in walkdir(@__DIR__())
        for file in files
            if endswith(file, ".md")
                target = joinpath(root, file)
                output = joinpath(BUILDDIR, relpath(root))

                @info "Weaving  : $(target)"
                @info "Generate : $(output)"

                weave(target;
                      doctype  = "md2html",
                      informat = "markdown",
                      out_path = output,
                      template = joinpath(@__DIR__(), "template.html"),
                      highlight_theme = CustomTheme
                )
            end
        end
    end

    return nothing;
end

function cleanall()
    @info "Removing cache directories..."
    removes = []

    for (root, dirs, _) in walkdir(BUILDDIR)
        for file in dirs
            if startswith(file, "jl_")
                target = joinpath(root, file)
                push!(removes, target)
                @info "Cleaning : $(target)"
            end
        end
    end

    # source = filter(s->startswith(s, "jl_"), readdir(BUILDDIR))
    # target = joinpath.(BUILDDIR, source)
    rm.(removes; recursive=true, force=true)

    return nothing;
end

weaveall()
cleanall()

# Keep a snippet to compile while writting:
# weave(".md";
#       doctype  = "md2html",
#       informat = "markdown",
#       out_path = "_build",
#       template = "template.html")
