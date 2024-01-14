# -*- coding: utf-8 -*-
using JuliaFormatter
using Pluto: ServerSession, SessionActions
using Pluto: generate_html

function workflow(nblist::Vector{String})
    s = ServerSession()
    s.options.server.launch_browser = false

    for nbname in nblist
        nbpath = joinpath(@__DIR__, "$(nbname).jl")
        pgpath = joinpath(@__DIR__, "$(nbname).html")
        
        if !format_file(nbpath)
            @warn "file not formatted: $(nbpath)"
        end
        
        if isfile(pgpath) && !FORCE
            VERBOSE > 1 && @info "file exists: $(pgpath)"
            return
        end
        
        VERBOSE > 0 && @info "working on $(nbname)"
        nb = SessionActions.open(s, nbpath; run_async=false)
        write(pgpath, generate_html(nb))
        SessionActions.shutdown(s, nb)
    end
end

VERBOSE = 2

FORCE = false

notebooks_ready = [
    "001-reator-pistao"
    "002-reator-pistao"
    "003-reator-pistao"
    # "004-reator-pistao"
]

workflow(notebooks_ready)
