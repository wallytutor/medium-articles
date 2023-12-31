# -*- coding: utf-8 -*-
using Weave

source = filter(s->endswith(s, ".jmd"), readdir(@__DIR__()))

weave.(source;
    doctype  = "md2html",
    out_path = joinpath(@__DIR__(), "_build/"))
