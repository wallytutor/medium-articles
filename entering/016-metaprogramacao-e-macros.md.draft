# Parte 16 - Metaprogramação e macros

[Workshop - JuliaCon 2021](https://www.youtube.com/watch?v=2QLhw6LVaq0&t=3275s)
[This video?](https://www.youtube.com/watch?v=sL8O4Hb9zD0)

```
using CairoMakie

macro makeplot1(ex)
    return quote
        let
            eval(:( fig = Figure(resolution = (720, 500)) ))
            eval(:( ax = Axis(fig[1, 1]) ))
            eval( $ex )
            eval(:( axislegend(position = :rb) ))
            eval(:( fig ))
        end
    end
end

macro makeplot2(ex, xlims)
    return quote
        eval(:( fig = Figure(resolution = (720, 500)) ))
        eval(:( ax = Axis(fig[1, 1]) ))
        eval( $ex )
        eval(:( xlims!(ax, $xlims) ))
        eval(:( axislegend(position = :rb) ))
        eval(:( fig ))
    end
end

@makeplot1 quote
    lines!(ax, [0, 1], [0, 1], label = "1")
    lines!(ax, [0, 1], [0, 3], label = "2")
end

let
    # ex = quote
    #     lines!(ax, [0, 1], [0, 1], label = "1")
    #     lines!(ax, [0, 1], [0, 3], label = "2")
    # end

    @makeplot1 quote
        lines!(ax, [0, 1], [0, 1], label = "1")
        lines!(ax, [0, 1], [0, 3], label = "2")
    end
end

let
    ex = quote
        lines!(ax, [0, 1], [0, 1], label = "1")
        lines!(ax, [0, 1], [0, 3], label = "2")
    end

    @makeplot1 ex
end

fig

@makeplot2  quote (0, 2) end
```

Isso é tudo para esta sessão de estudo! Até a próxima!
