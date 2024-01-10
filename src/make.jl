# -*- coding: utf-8 -*-
using Weave

const BUILDDIR = joinpath(@__DIR__(), "_build")

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
                      template = joinpath(@__DIR__(), "template.html"))
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
