# -*- coding: utf-8 -*-
using Weave

source = joinpath(@__DIR__(), "../src")
files = filter(s->endswith(s, ".jmd"), readdir(source))
weave.(joinpath.(source, files); 
    doctype  = "md2html",
    out_path = @__DIR__() 
)
