# -*- coding: utf-8 -*-
using Weave

source = filter(s->endswith(s, ".jmd"), readdir(@__DIR__()))
target = joinpath.(@__DIR__(), source)

weave.(target;
    doctype  = "md2html",
    out_path = joinpath(@__DIR__(), "_build/"),
    template = joinpath(@__DIR__(), "template.html"))
