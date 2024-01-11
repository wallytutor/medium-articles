# This file was generated, do not modify it. # hide
#hideall
let
    fig = Figure(size = (700, 300))
    ax = Axis(fig[1, 1])
    lines!(ax, ustrip(T); color = :red, linestyle = :dash)
    scatter!(ax, ustrip(T); color = :red)
    ax.xlabel = "Node"
    ax.ylabel = "Temperature [K]"
    ax.xticks = 1:3
    xlims!(ax, (0.95, 3.05))
    ylims!(ax, (300, 350))
    save(joinpath(@OUTPUT, "plot-2.png"), fig)
end;