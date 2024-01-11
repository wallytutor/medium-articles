### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
begin
    import Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()

    import PlutoUI
    PlutoUI.TableOfContents(title = "Tópicos")
end

# ╔═╡ e275b8ce-52b8-11ee-066f-3d20f8f1593e
md"""
# Parte 6 - Funções e despacho
"""

# ╔═╡ d0cba36d-01b0-425d-9677-dd188cedbd04
md"""
## Capturando de excessões
"""

# ╔═╡ e4428ffe-6180-4145-bed6-08ca5bd2f179
try
    unsignedx::UInt8 = 13;
    unsignedx = 256;
catch err
    println("Error: $(err)")
end

# ╔═╡ 3ea63386-f519-45f3-ad0c-e132ece600d8
try
    var = "bolo";
    throw(DomainError(var, "Não quero $(var)!"))
catch err
    println("Error: $(err)")
end

# ╔═╡ a7b98a28-a889-4c12-a3a7-2e1c932b2d0d
try
    error("Pare já!")
catch err
    println("Error: $(err)")
end

# ╔═╡ f4ff938a-e686-4d3f-a26f-b691f06308dc
md"""
## O básico de funções
"""

# ╔═╡ 5162ae71-422b-43c9-8992-c1e0858c866a
function sayhi(name)
    println("Hi $name, it's great to see you!")
end

# ╔═╡ bfe58e91-80c6-48c9-9659-17a63f8740e1
function f(x)
    x^2
end

# ╔═╡ 375f28c2-f7b5-4a7d-8390-d4db4a536f65
sayhi("C-3PO")

# ╔═╡ 00534b84-fa0a-497d-a1a4-4799e374d3c7
f(42)

# ╔═╡ 02e12b7e-b094-4dec-8014-fa6e3943a4da
md"""
## Funções *inline*
"""

# ╔═╡ 3129caeb-1429-4490-a161-31f2ae4c4b18
sayhi2(name) = println("Hi $name, it's great to see you!")

# ╔═╡ 21d2de46-56db-4937-b3fe-ee182f94e89f
f2(x) = x^2

# ╔═╡ 9645676d-7896-4ed9-9733-6e03a7869815
sayhi2("R2D2")

# ╔═╡ 072942b2-3811-40bd-94c2-646cf84b3bd7
f2(42)

# ╔═╡ b9b1f6b5-910f-41fa-963d-137a692b1b3f
md"""
## Funções anônimas
"""

# ╔═╡ b4827084-5ee9-4e1a-843d-1d40ee5a9831
sayhi3 = name -> println("Hi $name, it's great to see you!")

# ╔═╡ bc8988db-b6c1-42c4-ac67-621aeec7fb41
f3 = x -> x^2

# ╔═╡ 8f409f59-0441-47d8-8fd3-fed9a0e0ef90
sayhi3("Chewbacca")

# ╔═╡ 88a042f8-0ea2-43d1-b0bc-b02c17a10e7d
f3(42)

# ╔═╡ 5f8c7947-ebbc-4088-ae2f-6c6ed2887c88
md"""
## *Duck-typing*
"""

# ╔═╡ 1cc9e102-7f3a-467b-a411-f53ba6182737
sayhi(55595472)

# ╔═╡ 6b0c7d4e-169d-4fa0-a035-e069a8df4e3a
f(rand(3, 3))

# ╔═╡ 1410bb0e-ca29-49e5-ba94-c535a853dbef
f("hi")

# ╔═╡ ad57b708-e9f1-4b84-8017-e21ff7e4f46c
try
    f(rand(3))
catch err
    println("Erro: $(err)")
end

# ╔═╡ f354f7e6-96fa-4f89-a80e-eabb3371e085
md"""
## Funções mutantes
"""

# ╔═╡ cd3ca7a3-7507-4b79-9b66-efc23b226339
v = [3, 5, 2]

# ╔═╡ 789045e0-f17a-43f4-80a7-c72a66aebd65
sort(v), v

# ╔═╡ c5ac8f6b-1727-4d24-aee6-79c5e80b916c
sort!(v), v

# ╔═╡ 85fc3e1e-94f2-4c5e-b83f-d1b8bdc4e8f5
md"""
## Funções de ordem superior
"""

# ╔═╡ 40aa7913-5221-42ff-b2c4-bccef842278e
map(f, [1, 2, 3])

# ╔═╡ e5da732b-aac4-4dc5-b4d0-b39033758a56
map(x -> x^3, [1, 2, 3])

# ╔═╡ aa15e96d-311d-4b3c-98a1-64f9ae7d889e
broadcast(f, [1, 2, 3])

# ╔═╡ b82b4049-ce04-4083-a9b9-87c97cd0eaff
md"""
Some syntactic sugar for calling broadcast is to place a . between the name of the function you want to broadcast and its input arguments. For example,

```julia
broadcast(f, [1, 2, 3])
```
is the same as

```julia
f.([1, 2, 3])
```
"""

# ╔═╡ a01353ca-c442-4ab2-9f05-686bf28315d7
f.([1, 2, 3])

# ╔═╡ ec9b12db-e336-418e-8cd7-ddf0cd317c04
M = [i + 3*j for j in 0:2, i in 1:3]

# ╔═╡ f760e4f1-e69e-43c4-a9f2-9a781b55c0f0
f(M)

# ╔═╡ 42f39581-ee66-4b91-aba7-e7ce531371f1
f.(M)

# ╔═╡ fd58bd8d-5117-4602-a2f9-440635c1ee1c
M .+ 2 .* f.(M) ./ M

# ╔═╡ 6b9e0dc2-b245-44de-af4d-bf814add67be
broadcast(x -> x + 2 * f(x) / x, M)

# ╔═╡ 084164e4-f2c9-4baf-94c9-37b09caa11e2
@. M + 2 * f(M) / M

# ╔═╡ 0f9e30f1-ef56-40c7-9db2-5539b3af74c5
md"""
## Despacho múltiplo
"""

# ╔═╡ b77e16a4-3006-4723-8695-3c5c48abab86
foo(x::String, y::String) = println("My inputs x and y are both strings!")

# ╔═╡ 10d33b9a-9a1d-4d9b-bec6-56bcb9e520d4
foo(x::Int, y::Int) = println("My inputs x and y are both integers!")

# ╔═╡ 7a9fb78c-9fee-4c9f-86ed-39f00fea4715
methods(cd)

# ╔═╡ fa1c30f7-75dc-49f3-9f60-bb1bc1d2e5a8
@which 3.0 + 3.0

# ╔═╡ b6378ba8-f0f2-4df2-9aad-1e9a209e1c2b
foo(x::Number, y::Number) = println("My inputs x and y are both numbers!")

# ╔═╡ bddddbab-501d-4882-a589-cbb704044f52
foo(x, y) = println("I accept inputs of any type!")

# ╔═╡ 509acca3-4221-4d61-995a-183b1c326957
foo("hello", "hi!")

# ╔═╡ 816e018d-d815-489f-91f4-e82672d3bb1a
foo(3, 4)

# ╔═╡ a896fde1-03ce-4748-905b-09c46412748b
methods(foo)

# ╔═╡ ce6e237c-77d0-4892-a297-7a61874df3a7
@which foo(3, 4)

# ╔═╡ 73d561f0-4eaa-4ac7-909e-fb0f20f420f5
@which foo(3, 4)

# ╔═╡ a046fc0a-55e4-4831-9139-6cefe39649c6
@which foo(3.0, 4)

# ╔═╡ e3371c65-7719-427d-9574-974c751dd66d
foo(rand(3), "who are you")

# ╔═╡ 542763c5-b1d7-4e3f-b972-990f1d14fe39
md"""
Isso é tudo para esta sessão de estudo! Até a próxima!

[Voltar aos conteúdos](https://wallytutor.github.io/julia-for-scientists/)
"""

# ╔═╡ Cell order:
# ╟─e275b8ce-52b8-11ee-066f-3d20f8f1593e
# ╟─d0cba36d-01b0-425d-9677-dd188cedbd04
# ╠═e4428ffe-6180-4145-bed6-08ca5bd2f179
# ╠═3ea63386-f519-45f3-ad0c-e132ece600d8
# ╠═a7b98a28-a889-4c12-a3a7-2e1c932b2d0d
# ╟─f4ff938a-e686-4d3f-a26f-b691f06308dc
# ╠═5162ae71-422b-43c9-8992-c1e0858c866a
# ╠═bfe58e91-80c6-48c9-9659-17a63f8740e1
# ╠═375f28c2-f7b5-4a7d-8390-d4db4a536f65
# ╠═00534b84-fa0a-497d-a1a4-4799e374d3c7
# ╟─02e12b7e-b094-4dec-8014-fa6e3943a4da
# ╠═3129caeb-1429-4490-a161-31f2ae4c4b18
# ╠═21d2de46-56db-4937-b3fe-ee182f94e89f
# ╠═9645676d-7896-4ed9-9733-6e03a7869815
# ╠═072942b2-3811-40bd-94c2-646cf84b3bd7
# ╟─b9b1f6b5-910f-41fa-963d-137a692b1b3f
# ╠═b4827084-5ee9-4e1a-843d-1d40ee5a9831
# ╠═bc8988db-b6c1-42c4-ac67-621aeec7fb41
# ╠═8f409f59-0441-47d8-8fd3-fed9a0e0ef90
# ╠═88a042f8-0ea2-43d1-b0bc-b02c17a10e7d
# ╟─5f8c7947-ebbc-4088-ae2f-6c6ed2887c88
# ╠═1cc9e102-7f3a-467b-a411-f53ba6182737
# ╠═6b0c7d4e-169d-4fa0-a035-e069a8df4e3a
# ╠═1410bb0e-ca29-49e5-ba94-c535a853dbef
# ╠═ad57b708-e9f1-4b84-8017-e21ff7e4f46c
# ╟─f354f7e6-96fa-4f89-a80e-eabb3371e085
# ╠═cd3ca7a3-7507-4b79-9b66-efc23b226339
# ╠═789045e0-f17a-43f4-80a7-c72a66aebd65
# ╠═c5ac8f6b-1727-4d24-aee6-79c5e80b916c
# ╟─85fc3e1e-94f2-4c5e-b83f-d1b8bdc4e8f5
# ╠═40aa7913-5221-42ff-b2c4-bccef842278e
# ╠═e5da732b-aac4-4dc5-b4d0-b39033758a56
# ╠═aa15e96d-311d-4b3c-98a1-64f9ae7d889e
# ╟─b82b4049-ce04-4083-a9b9-87c97cd0eaff
# ╠═a01353ca-c442-4ab2-9f05-686bf28315d7
# ╠═ec9b12db-e336-418e-8cd7-ddf0cd317c04
# ╠═f760e4f1-e69e-43c4-a9f2-9a781b55c0f0
# ╠═42f39581-ee66-4b91-aba7-e7ce531371f1
# ╠═fd58bd8d-5117-4602-a2f9-440635c1ee1c
# ╠═6b9e0dc2-b245-44de-af4d-bf814add67be
# ╠═084164e4-f2c9-4baf-94c9-37b09caa11e2
# ╟─0f9e30f1-ef56-40c7-9db2-5539b3af74c5
# ╠═b77e16a4-3006-4723-8695-3c5c48abab86
# ╠═10d33b9a-9a1d-4d9b-bec6-56bcb9e520d4
# ╠═509acca3-4221-4d61-995a-183b1c326957
# ╠═816e018d-d815-489f-91f4-e82672d3bb1a
# ╠═a896fde1-03ce-4748-905b-09c46412748b
# ╠═7a9fb78c-9fee-4c9f-86ed-39f00fea4715
# ╠═ce6e237c-77d0-4892-a297-7a61874df3a7
# ╠═fa1c30f7-75dc-49f3-9f60-bb1bc1d2e5a8
# ╠═b6378ba8-f0f2-4df2-9aad-1e9a209e1c2b
# ╠═73d561f0-4eaa-4ac7-909e-fb0f20f420f5
# ╠═a046fc0a-55e4-4831-9139-6cefe39649c6
# ╠═bddddbab-501d-4882-a589-cbb704044f52
# ╠═e3371c65-7719-427d-9574-974c751dd66d
# ╟─542763c5-b1d7-4e3f-b972-990f1d14fe39
# ╟─92b9fe51-6b4f-4ef0-aa83-f6e47c2db5a0
