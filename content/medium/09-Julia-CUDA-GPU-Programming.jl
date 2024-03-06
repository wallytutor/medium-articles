### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ 54ba12d2-8f81-4108-8552-897c53996a9d
begin
	import Adapt
	import CUDA
	import PlutoUI
	using BenchmarkTools: @btime
	using CUDA: @cuda, CuArray
	using Test: @test

	CUDA.functional() && begin
		CUDA.versioninfo()
		println()
		CUDA.memory_status()
	end
end

# ╔═╡ 22ccd410-29e2-4a04-b8d0-c6bae02a83c9
let
	import Zygote
	using LinearAlgebra
	using Zygote: gradient

	CUDA.allowscalar(false)

	CuMatrix = CuArray{Float32, 2, CUDA.Mem.DeviceBuffer}
	CuVector = CuArray{Float32, 1, CUDA.Mem.DeviceBuffer}
	
	struct SimpleMLP
		M1::CuMatrix
		b1::CuVector
		f1::Function
		M2::CuMatrix
		b2::CuVector
		f2::Function

		# function SimpleMLP(; M1, b1, f1, M2, b2, f2)
		# 	return new(M1, b1, f1, M2, b2, f2)
		# end
	end

	function (self::SimpleMLP)(x)
		l1 = self.f1.(self.M1 * x  + self.b1)
		l2 = self.f2.(self.M2 * l1 + self.b2)
		return l2
	end
	
	Adapt.@adapt_structure SimpleMLP

	function dudt!(unet, udot, x)
		blkid  = CUDA.blockIdx().x - Int32(1)
		index  = blkid * CUDA.blockDim().x + CUDA.threadIdx().x
	    stride = CUDA.gridDim().x * CUDA.blockDim().x

	    while index <= length(udot)
	        @inbounds udot[index] = gradient(z->unet(z)[index], x)[1][index]
			index += stride
	    end
		
	    return nothing
	end

	x = CuArray([1; 2; 3; 4; 5; 10; 20])
	
	udot = CUDA.zeros(5)
	
	unet = SimpleMLP(
		# M1 =
		CUDA.rand(10, 7),
		# b1 =
		CUDA.rand(10),
		# f1 =
		(z) -> (1 + exp(-z))^(-1),
		# M2 =
		CUDA.rand(5, 10),
		# b2 =
		CUDA.rand(5),
		# f2 =
		identity
	)
	
	# @info unet(x)

	# gradient(x->unet(x)[1], x)[1][1]
	
	# map((k, _)->gradient(unet(x)[k], enumerate(x))[1][k])
	
	# kernel = @cuda launch=false dudt!(unet, udot, x)
	# config = CUDA.launch_configuration(kernel.fun)
	
	# threads = min(length(udot), config.threads)
	# blocks  = cld(length(udot), threads)
	
	# kernel(udot, x; threads, blocks)
	
	# Zygote.jacobian(l0->NN(l0, params), x)[1]
	# dudtk(z, k) = Zygote.jacobian(x->NN(x, params), z)[1]
	# dudtk(x, 1)
end

# ╔═╡ 2aca7e21-7480-49f7-8ffc-cd22d458ca4c
md"""
# Julia CUDA (not for dummies)

$(PlutoUI.TableOfContents())

*The approach here is minimalist and assumes you already have a CUDA background in other languages. Its main goal is to review the state of functionalities implemented in Julia.* Unless specified otherwise, the contents are reworked from the stable branch [documentation of CUDA.jl](https://cuda.juliagpu.org/stable/).
"""

# ╔═╡ e2132bdd-4f44-4750-8f14-cccbbfcc9208
md"""
## Helpers
"""

# ╔═╡ 5f2db8e8-5ce2-4fa5-8e13-7345782473ea
"Shortcut to get CUDA attributes for device."
cuattr(name) = CUDA.attribute(CUDA.device(), name)

# ╔═╡ 68e5b1b7-dce3-45b7-986f-026519d32eee
md"""
Some characteristics of the current GPU:

| Property | Value |
| -------- | ----- |
Threads per block | $(cuattr(CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK))
Block dim. X | $(cuattr(CUDA.DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_X))
Block dim. Y | $(cuattr(CUDA.DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_Y))
Block dim. Z | $(cuattr(CUDA.DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_Z))
Grid dim. X | $(cuattr(CUDA.DEVICE_ATTRIBUTE_MAX_GRID_DIM_X))
Grid dim. Y | $(cuattr(CUDA.DEVICE_ATTRIBUTE_MAX_GRID_DIM_Y))
Grid dim. Z | $(cuattr(CUDA.DEVICE_ATTRIBUTE_MAX_GRID_DIM_Z))
"""

# ╔═╡ 45aed95c-95d0-4ae5-a558-d9ed4cc11998
"Better memory usage message."
function gpu_usage()
	total = CUDA.total_memory()
	avail = CUDA.available_memory()
	usage = 100 * (total - avail) / total
	@info "GPU memory usage $(round(usage; digits = 3))%"
end

# ╔═╡ 3f47e863-310a-4090-81f0-ba57d1109443
"Standard workflow for benchmarking `add!` implementations."
function test_it_all(add!, x, y; threads = nothing, blocks = nothing, val = 3.0f0)
	# → Scalar indexing is disallowed.
	# add!(y, x)

	if isnothing(threads) || isnothing(blocks)
		kernel = @cuda launch=false add!(y, x)
		config = CUDA.launch_configuration(kernel.fun)
		
		threads = min(length(y), config.threads)
		blocks  = cld(length(y), threads)
		
		kernel(y, x; threads, blocks)
	else
		# Direct call without kernel compilation.
		@cuda threads=threads blocks=blocks add!(y, x)
	end
	
	@test all(Array(y) .== val)

	function bench_gpu!(y, x)
	    kernel = @cuda launch=false add!(y, x)
		
		if isnothing(threads) || isnothing(blocks)
	    	config = CUDA.launch_configuration(kernel.fun)
		    threads = min(length(y), config.threads)
		    blocks  = cld(length(y), threads)
		end
	
	    CUDA.@sync kernel(y, x; threads, blocks)
	end

	# Run it once to force compilation.
	bench_gpu!(y, x)
	@btime $bench_gpu!($y, $x)
	
	CUDA.@profile trace=true bench_gpu!(y, x)
end

# ╔═╡ 80da024a-4b3f-4037-9eac-0aea27b51cd8
md"""
## Broadcasted benchmark

From tutorial: *Wrapping the execution in a CUDA.@sync block will make the CPU block until the queued GPU tasks are done, similar to how Base.@sync waits for distributed CPU tasks.*
"""

# ╔═╡ 3f9bdd09-eafb-42aa-b933-92429204fce3
let
	function add!(y, x)
		CUDA.@sync y .+= x
		return
	end
	
	x = CUDA.fill(1.0f0, 2^20)
	y = CUDA.fill(3.0f0, 2^20)
	
	add!(y, x)
	@btime $add!($y, $x)
end

# ╔═╡ fc58d35a-bb68-4fe2-851d-37a42c29d991
md"""
## Sequential benchmark

From tutorial: *Aside from using the CuArrays x_d and y_d, the only GPU-specific part of this is the kernel launch via @cuda. The first time you issue this @cuda statement, it will compile the kernel (gpu_add1!) for execution on the GPU.*
"""

# ╔═╡ eabb31db-1ac6-432c-b7c7-10142b53719a
let
	function add!(y, x)
	    for i in eachindex(y)
	        @inbounds y[i] += x[i]
	    end
	    return nothing
	end

	x = CUDA.fill(1.0f0, 2^20)
	y = CUDA.fill(3.0f0, 2^20)

	# Also available in inplace transformation.
	CUDA.fill!(y, 2.0f0)

	test_it_all(add!, x, y; threads = 1, blocks = 1)
end

# ╔═╡ cf0daa11-7e0c-4588-ab4e-e43e81953607
md"""
## Multi-threaded benchmark

From tutorial: *Note the threads=256 here, which divides the work among 256 threads numbered in a linear pattern. (For a two-dimensional array, we might have used threads=(16, 16) and then both x and y would be relevant.)*

**Important:** the number of `threads=256` used in first call to `gpu_add!` produces a specific compilation of this function. Using another value in the benchmark later will recompile the function, leading to a wrong conclusion regarding performance increase!
"""

# ╔═╡ ffbbeb61-1f15-41e1-814d-020e2a43bc33
let
	function add!(y, x)
		# this example only requires linear indexing, so just use `x`
		index = CUDA.threadIdx().x    
	    stride = CUDA.blockDim().x
	    for i in index:stride:length(y)
	        @inbounds y[i] += x[i]
	    end
	    return nothing
	end

	x = CUDA.fill(1.0f0, 2^20)
	y = CUDA.fill(2.0f0, 2^20)

	test_it_all(add!, x, y; threads = 1024, blocks = 1)
end

# ╔═╡ e1abe5b1-8efc-49e9-997b-ab4c32ae72dc
md"""
## Multi-block benchmark
"""

# ╔═╡ 8878779c-4c26-454d-a2a8-f88ffac77a5f
let
	function add!(y, x)
		# Because Julia indexing starts at 1!
		blkid  = CUDA.blockIdx().x - 1
		index  = blkid * CUDA.blockDim().x + CUDA.threadIdx().x
	    stride = CUDA.gridDim().x * CUDA.blockDim().x
		
	    for i in index:stride:length(y)
	        @inbounds y[i] += x[i]
	    end
	    return nothing
	end

	N = 2^20
	THREADS = 1024
	BLOCKS  = ceil(Int, N/THREADS)
	
	x = CUDA.fill(1.0f0, N)
	y = CUDA.fill(2.0f0, N)

	test_it_all(add!, x, y; threads = THREADS, blocks = BLOCKS)
end

# ╔═╡ feffdfdb-2e56-4ce3-8f80-36b10687c9a5
md"""
## Improving allocation

From tutorial: *In the previous example, the number of threads was hard-coded to 256. This is not ideal, as using more threads generally improves performance, but the maximum number of allowed threads to launch depends on your GPU as well as on the kernel.*

Also take a look at this relevant [question](https://discourse.julialang.org/t/cuda-threads-and-blocks-confusion/54816/8).
"""

# ╔═╡ 8ce73927-64c6-4834-be06-d11b0de3d599
let
	function add1!(y, x)
		# Because Julia indexing starts at 1!
		blkid  = CUDA.blockIdx().x - 1
		index  = blkid * CUDA.blockDim().x + CUDA.threadIdx().x
	    stride = CUDA.gridDim().x * CUDA.blockDim().x
		
	    for i in index:stride:length(y)
	        @inbounds y[i] += x[i]
	    end
	    return nothing
	end

	function add2!(y, x)
		# Because Julia indexing starts at 1!
		blkid  = CUDA.blockIdx().x - Int32(1) # HERE Int32
		index  = blkid * CUDA.blockDim().x + CUDA.threadIdx().x
	    stride = CUDA.gridDim().x * CUDA.blockDim().x
		
	    for i in index:stride:length(y)
	        @inbounds y[i] += x[i]
	    end
	    return nothing
	end

	function add3!(y, x)
		# Because Julia indexing starts at 1!
		blkid  = CUDA.blockIdx().x - Int32(1)
		index  = blkid * CUDA.blockDim().x + CUDA.threadIdx().x
	    stride = CUDA.gridDim().x * CUDA.blockDim().x

	    while index <= length(y)
	        @inbounds y[index] += x[index]
			index += stride
	    end
	    return nothing
	end

	N = 2^20

	get_data(N) = (CUDA.fill(1.0f0, N), CUDA.fill(2.0f0, N))

	test_it_all(add1!, get_data(N)...; threads = nothing, blocks = nothing)
	test_it_all(add2!, get_data(N)...; threads = nothing, blocks = nothing)
	test_it_all(add3!, get_data(N)...; threads = nothing, blocks = nothing)

	@info add1! CUDA.registers(@cuda add1!(get_data(N)...))
	@info add2! CUDA.registers(@cuda add2!(get_data(N)...))
	@info add3! CUDA.registers(@cuda add3!(get_data(N)...))
end

# ╔═╡ d4af989c-6ff7-46d4-bca9-715658a9e66c
md"""
## Standard output
"""

# ╔═╡ 23adf774-0264-479f-8005-25810f650dde
let
	function gpu_add_print!(y, x)
	    index = CUDA.threadIdx().x
	    stride = CUDA.blockDim().x
		
	    CUDA.@cuprintln("thread $(index)/$(stride)")
		
	    for i = index:stride:length(y)
	        @inbounds y[i] += x[i]
	    end
	    return nothing
	end

	N = 2^20
	x = CUDA.fill(1.0f0, N)
	y = CUDA.fill(2.0f0, N)
	
	@cuda threads=8 gpu_add_print!(y, x)
	CUDA.synchronize()
end

# ╔═╡ fe8b1c93-e1b5-4df8-8415-641ca0eebcec
md"""
## Custom structures
"""

# ╔═╡ 04554cdb-6c9e-49fc-b625-b7cd9b92eb6d
md"""
The structure cannot be called directly. From tutorial: *Why does it throw an error? Our calculation involves a custom type Interpolate{CuArray{Float64, 1}}. At the end of the day all arguments of a CUDA kernel need to be bitstypes. How to fix this? The answer is, that there is a conversion mechanism, which adapts objects into CUDA compatible bitstypes. It is based on the Adapt.jl package and basic types like CuArray already participate in this mechanism.*
"""

# ╔═╡ 065edf25-ba20-4e90-9c0c-313693e0e6a1
let
	struct Interpolate{T}
	    xs::T
	    ys::T
	end

	function (self::Interpolate)(x)
	    i = searchsortedfirst(self.xs, x)
	    i = clamp(i, firstindex(self.ys), lastindex(self.ys))
	    return @inbounds self.ys[i]
	end

	Adapt.@adapt_structure Interpolate

	# The code below produces the same result as wrapping
	# `Interpolate` above. The tutorial is not explicit on
	# why the manual customization may be useful.
	#
	# function Adapt.adapt_structure(to, itp::Interpolate)
	#     xs = Adapt.adapt_structure(to, itp.xs)
	#     ys = Adapt.adapt_structure(to, itp.ys)
	#     return Interpolate(xs, ys)
	# end
		
	xs_cpu = [1.0, 2.0, 3.0]
	ys_cpu = [10.0, 20.0, 30.0]
	ps_cpu = [1.1, 2.3]
	
	itp_cpu = Interpolate(xs_cpu, ys_cpu)
	@info itp_cpu.(ps_cpu)

	xs_gpu = CuArray(xs_cpu)
	ys_gpu = CuArray(ys_cpu)
	ps_gpu = CuArray(ps_cpu)
	
	itp_gpu = Interpolate(xs_gpu, ys_gpu)
	@info itp_gpu.(ps_gpu) |> Array
	
end

# ╔═╡ 23810108-ee34-4759-a062-d33050b3f6ad
md"""
## Performance tips

- @cuda always_inline=true
- @cuda max_registers=32
- @cuda fastmath=true
- Using @inbounds when indexing into arrays eliminate bounds checking exceptions
- Use `LLVM.Interop.assume` to get rid of some exceptions
- Use [32-bit integers](https://cuda.juliagpu.org/stable/tutorials/performance/#bit-Integers) where possible
- Avoid StepRange, instead it is faster to use a while loop
- Make sure scalar indexing is off with `CUDA.allowscalar(false)`
"""

# ╔═╡ 8b4f7093-bebc-4a6f-8d9f-a4e75629923b
md"""
## General use

- With `map`, `reduce` or `broadcast` it is possible to perform kernel-like operations without actually writing your own GPU kernels.
- Higher order functions include `(map)reduce(dim)` and `accumulate`. 
"""

# ╔═╡ d2e79ccb-1c70-4e1f-bbf2-993650e24a30
let
	N = 2^21

	gpu_usage()
	
	a = CuArray{Int}(undef, N)
	gpu_usage()
		
	b = copy(a)
	gpu_usage()
	
	fill!(b, 0)
	@test b == CUDA.zeros(Int, N)
	
	# automatic memory management NOT WORKING witout GC.gc(true)
	a = nothing
	b = nothing
	GC.gc(true)
	gpu_usage()
end

# ╔═╡ 1e23ae5c-d70a-4b2a-8477-f19277fff656
let
	GC.gc(true)
	gpu_usage()

	elapsed = CUDA.@elapsed begin
		# code that will be timed using CUDA events
		a = CUDA.zeros(2^20)
		b = CUDA.ones(2^20)
		c = @. a^2 + sin(b)
	end

	@info "Elapsed $(elapsed)"
	
	GC.gc(true)
	gpu_usage()
end

# ╔═╡ d16f12a9-ab6d-4396-a3c0-c6856aeaf3c8
let
	a = CuArray([1π, 2π])
	
	b = [2.0, 3.0]
	b = copyto!(b, a)

	map(sin, b)
end

# ╔═╡ f31465d9-3d38-4277-86e4-6184d8c28f5e


# ╔═╡ e423323d-c21d-4336-bb25-c12537a3da63
md"""
## Differentiable programming
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[compat]
Adapt = "~4.0.1"
BenchmarkTools = "~1.4.0"
CUDA = "~5.2.0"
PlutoUI = "~0.7.56"
Zygote = "~0.6.69"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.1"
manifest_format = "2.0"
project_hash = "0b5a92c2c4f3e5e46c32c1262390d708f11b1933"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "c278dfab760520b8bb7e9511b968bf4ba38b7acc"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.3"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "0fb305e0253fd4e833d486914367a2ee2c2e78d0"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.1"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "dbf84058d0a8cbbadee18d25cf606934b22d7c66"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.4.2"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1f03a9fa24271160ed7e73051fba3c1a759b53f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.4.0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CUDA_Driver_jll", "CUDA_Runtime_Discovery", "CUDA_Runtime_jll", "Crayons", "DataFrames", "ExprTools", "GPUArrays", "GPUCompiler", "KernelAbstractions", "LLVM", "LLVMLoopInfo", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "NVTX", "Preferences", "PrettyTables", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "StaticArrays", "Statistics"]
git-tree-sha1 = "baa8ea7a1ea63316fa3feb454635215773c9c845"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "5.2.0"
weakdeps = ["ChainRulesCore", "SpecialFunctions"]

    [deps.CUDA.extensions]
    ChainRulesCoreExt = "ChainRulesCore"
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.CUDA_Driver_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "d01bfc999768f0a31ed36f5d22a76161fc63079c"
uuid = "4ee394cb-3365-5eb0-8335-949819d2adfc"
version = "0.7.0+1"

[[deps.CUDA_Runtime_Discovery]]
deps = ["Libdl"]
git-tree-sha1 = "2cb12f6b2209f40a4b8967697689a47c50485490"
uuid = "1af6417a-86b4-443c-805f-a4643ffb695f"
version = "0.2.3"

[[deps.CUDA_Runtime_jll]]
deps = ["Artifacts", "CUDA_Driver_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "8e25c009d2bf16c2c31a70a6e9e8939f7325cc84"
uuid = "76a88914-d11a-5bdc-97e0-2f5a05c973a2"
version = "0.11.1+0"

[[deps.ChainRules]]
deps = ["Adapt", "ChainRulesCore", "Compat", "Distributed", "GPUArraysCore", "IrrationalConstants", "LinearAlgebra", "Random", "RealDot", "SparseArrays", "SparseInverseSubset", "Statistics", "StructArrays", "SuiteSparse"]
git-tree-sha1 = "4e42872be98fa3343c4f8458cbda8c5c6a6fa97c"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.63.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "ad25e7d21ce10e01de973cdc68ad0f850a953c52"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.21.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "75bd5b6fc5089df449b5d35fa501c846c9b6549b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.12.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "ac67408d9ddf207de5cfa9a97e114352430f01ed"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.16"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "5b93957f6dcd33fc343044af3d48c215be2562f1"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.9.3"

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

    [deps.FillArrays.weakdeps]
    PDMats = "90014a1f-27ba-587c-ab20-58faa44d9150"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GPUArrays]]
deps = ["Adapt", "GPUArraysCore", "LLVM", "LinearAlgebra", "Printf", "Random", "Reexport", "Serialization", "Statistics"]
git-tree-sha1 = "47e4686ec18a9620850bad110b79966132f14283"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "10.0.2"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "ec632f177c0d990e64d955ccc1b8c04c485a0950"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.6"

[[deps.GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "Scratch", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "a846f297ce9d09ccba02ead0cae70690e072a119"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.25.0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "5d8c5713f38f7bc029e26627b687710ba406d0dd"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.12"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaNVTXCallbacks_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "af433a10f3942e882d3c671aacb203e006a5808f"
uuid = "9c1d0b0a-7046-5b2e-a33f-ea22f176ac7e"
version = "0.2.1+0"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "LinearAlgebra", "MacroTools", "PrecompileTools", "Requires", "SparseArrays", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "4e0cb2f5aad44dcfdc91088e85dee4ecb22c791c"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.9.16"

    [deps.KernelAbstractions.extensions]
    EnzymeExt = "EnzymeCore"

    [deps.KernelAbstractions.weakdeps]
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Preferences", "Printf", "Requires", "Unicode"]
git-tree-sha1 = "9e70165cca7459d25406367f0c55e517a9a7bfe7"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "6.5.0"
weakdeps = ["BFloat16s"]

    [deps.LLVM.extensions]
    BFloat16sExt = "BFloat16s"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "114e3a48f13d4c18ddd7fd6a00107b4b96f60f9c"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.28+0"

[[deps.LLVMLoopInfo]]
git-tree-sha1 = "2e5c102cfc41f48ae4740c7eca7743cc7e7b75ea"
uuid = "8b046642-f1f6-4319-8d3c-209ddc03c586"
version = "1.0.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NVTX]]
deps = ["Colors", "JuliaNVTXCallbacks_jll", "Libdl", "NVTX_jll"]
git-tree-sha1 = "53046f0483375e3ed78e49190f1154fa0a4083a1"
uuid = "5da4648a-3479-48b8-97b9-01cb529c0a1f"
version = "0.3.4"

[[deps.NVTX_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ce3269ed42816bf18d500c9f63418d4b0d9f5a3b"
uuid = "e98f9f5b-d649-5603-91fd-7774390e6439"
version = "3.1.0+2"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "211cdf570992b0d977fda3745f72772e0d5423f2"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.56"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "c860e84651f58ce240dd79e5d9e055d55234c35a"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.6.2"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SparseInverseSubset]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "52962839426b75b3021296f7df242e40ecfc0852"
uuid = "dc90abb0-5640-4711-901d-7e5b23a2fada"
version = "0.1.2"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "7b0e9c14c624e435076d19aea1e5cbdec2b9ca37"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.2"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.StructArrays]]
deps = ["Adapt", "ConstructionBase", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "1b0b1205a56dc288b71b1961d48e351520702e24"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.17"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f548a9e9c490030e545f72074a41edfd0e5bcdd7"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.23"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "323e3d0acf5e78a56dfae7bd8928c989b4f3083e"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.1.3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "GPUArrays", "GPUArraysCore", "IRTools", "InteractiveUtils", "LinearAlgebra", "LogExpFunctions", "MacroTools", "NaNMath", "PrecompileTools", "Random", "Requires", "SparseArrays", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "4ddb4470e47b0094c93055a3bcae799165cc68f1"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.69"

    [deps.Zygote.extensions]
    ZygoteColorsExt = "Colors"
    ZygoteDistancesExt = "Distances"
    ZygoteTrackerExt = "Tracker"

    [deps.Zygote.weakdeps]
    Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
    Distances = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.ZygoteRules]]
deps = ["ChainRulesCore", "MacroTools"]
git-tree-sha1 = "27798139afc0a2afa7b1824c206d5e87ea587a00"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.5"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─2aca7e21-7480-49f7-8ffc-cd22d458ca4c
# ╟─54ba12d2-8f81-4108-8552-897c53996a9d
# ╟─68e5b1b7-dce3-45b7-986f-026519d32eee
# ╟─e2132bdd-4f44-4750-8f14-cccbbfcc9208
# ╟─5f2db8e8-5ce2-4fa5-8e13-7345782473ea
# ╟─45aed95c-95d0-4ae5-a558-d9ed4cc11998
# ╟─3f47e863-310a-4090-81f0-ba57d1109443
# ╟─80da024a-4b3f-4037-9eac-0aea27b51cd8
# ╟─3f9bdd09-eafb-42aa-b933-92429204fce3
# ╟─fc58d35a-bb68-4fe2-851d-37a42c29d991
# ╟─eabb31db-1ac6-432c-b7c7-10142b53719a
# ╟─cf0daa11-7e0c-4588-ab4e-e43e81953607
# ╟─ffbbeb61-1f15-41e1-814d-020e2a43bc33
# ╟─e1abe5b1-8efc-49e9-997b-ab4c32ae72dc
# ╟─8878779c-4c26-454d-a2a8-f88ffac77a5f
# ╟─feffdfdb-2e56-4ce3-8f80-36b10687c9a5
# ╟─8ce73927-64c6-4834-be06-d11b0de3d599
# ╟─d4af989c-6ff7-46d4-bca9-715658a9e66c
# ╟─23adf774-0264-479f-8005-25810f650dde
# ╟─fe8b1c93-e1b5-4df8-8415-641ca0eebcec
# ╟─04554cdb-6c9e-49fc-b625-b7cd9b92eb6d
# ╟─065edf25-ba20-4e90-9c0c-313693e0e6a1
# ╟─23810108-ee34-4759-a062-d33050b3f6ad
# ╟─8b4f7093-bebc-4a6f-8d9f-a4e75629923b
# ╟─d2e79ccb-1c70-4e1f-bbf2-993650e24a30
# ╟─1e23ae5c-d70a-4b2a-8477-f19277fff656
# ╠═d16f12a9-ab6d-4396-a3c0-c6856aeaf3c8
# ╠═f31465d9-3d38-4277-86e4-6184d8c28f5e
# ╟─e423323d-c21d-4336-bb25-c12537a3da63
# ╠═22ccd410-29e2-4a04-b8d0-c6bae02a83c9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
