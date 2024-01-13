# -*- coding: utf-8 -*-
using JuliaFormatter
using Pluto: ServerSession, SessionActions
using Pluto: generate_html

function convertnotebook(s::ServerSession, nbname::String)
    nbpath = joinpath(@__DIR__, "$(nbname).jl")
    pgpath = "$(nbname).html"
    
    if !format_file(nbpath)
        @error "file not formatted: $(nbpath)"
    end
    
    if isfile(pgpath) && !FORCE
        VERBOSE > 2 && @info "file exists: $(pgpath)"
        return
    end
    
    VERBOSE > 0 && @info "working on $(nbname)"
    nb = SessionActions.open(s, nbpath; run_async=false)
    write(pgpath, generate_html(nb))
    SessionActions.shutdown(s, nb)
end

function workflow(nblist::Vector{String})
    s = ServerSession()
    s.options.server.launch_browser = false

    for nbname in nblist
        convertnotebook(s, nbname)
    end
end

VERBOSE = 3

FORCE = false

notebooks_ready = [
    "001-reator-pistao"
]

workflow(notebooks_ready)
