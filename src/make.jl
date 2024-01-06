# -*- coding: utf-8 -*-
using Weave

const BUILDDIR = joinpath(@__DIR__(), "_build")

function weaveall()
    source = filter(s->endswith(s, ".md"), readdir(@__DIR__()))
    target = joinpath.(@__DIR__(), source)
    
    @info "Weaving all documents..."
    weave.(target;
        doctype  = "md2html",
        informat = "markdown",
        out_path = BUILDDIR,
        template = joinpath(@__DIR__(), "template.html"))
    return nothing;
end

function cleanall()
    @info "Removing cache directories..."
    source = filter(s->startswith(s, "jl_"), readdir(BUILDDIR))
    target = joinpath.(BUILDDIR, source)
    rm.(target; recursive=true, force=true)
    return nothing;
end

weaveall()
cleanall()
