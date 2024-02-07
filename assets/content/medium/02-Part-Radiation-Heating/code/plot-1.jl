# This file was generated, do not modify it. # hide
#hideall
let
    tk = t / 3600

    fig = Figure(size = (700, 700))
    
    ax1 = Axis(fig[1, 1])
    lines!(ax1, tk, solution[:, 1]; color = :black, label = "Metal")
    hlines!(ax1, ustrip(Ta); color = :blue, label = "Environment")
    axislegend(ax1; position = :rt)
	
    ax2 = Axis(fig[2, 1])
    lines!(ax2, tk, solution[:, 2]; color = :green, label = "Gas")
    lines!(ax2, tk, solution[:, 3]; color = :red,   label = "Wall")
    hlines!(ax2, ustrip(Ta); color = :blue, label = "Environment")
    axislegend(ax2; position = :rt)
    
    ax3 = Axis(fig[3, 1])
    lines!(ax3, tk, solution[:, 5]; color = :black)

    ax3.xlabel = "Time [h]"
    ax1.ylabel = "Temperature [K]"
    ax2.ylabel = "Temperature [K]"
    ax3.ylabel = "Residual"
    
    ax1.xticks = 0:2:tk[end]
    ax2.xticks = 0:2:tk[end]
    ax3.xticks = 0:2:tk[end]
    
    ax1.yticks = 300:200:1300
    ax2.yticks = 300:20:400
    
    xlims!(ax1, extrema(ax1.xticks.val))
    xlims!(ax2, extrema(ax2.xticks.val))
    xlims!(ax3, extrema(ax3.xticks.val))
    
    ylims!(ax1, extrema(ax1.yticks.val))
    ylims!(ax2, extrema(ax2.yticks.val))
    
    save(joinpath(@OUTPUT, "plot-1.png"), fig)
end
nothing; # hide