+++
title   = "Image Segmentation in Julia"
tags    = ["programming", "julia"]
showall = true
outpath = "/assets/content/medium/05-Image-Segmentation-in-Julia/code/output"
+++

# Image Segmentation in Julia

\warn{DANGER!}{This is a work in progress!}

In this article we will see how to implement a custom workflow for porosity
quantification in materials. The selected tools are those from the
[JuliaImages](https://juliaimages.org/latest/) suite. We start below by
importing all required packages.

```
using Images
using ImageSegmentation
using Plots
using Statistics
```

```
filepath = "samples/Ti_pure_1-50.1-50x.jpg"
img = Gray.(load(filepath))

(h, w) = size(img)
println("$(typeof(img)) : size $(h)x$(w)")
img
```

Notice in the image above that it contains the scale bar placed at the
right-bottom corner of the image. A first step towards porosity quantification
is to remove this area. There are many ways of doing this: performing [image
inpainting](https://github.com/JuliaImages/ImageInpainting.jl), setting values
in the zone to a level that the quantification will always capture as matrix
material, ..., or simply cropping the area. As the bar is small and placed near
the corner, we don't loose much sampling space by going forward with the last
option.

The next slider controls the cropping of the bottom of the image.

```
crop = 80
imgc = img[1:end-crop, 1:end]
```

Because of sample preparation and other inherent material characteristics, the
matrix *color* is not homogeneous. We have drying effects, contaminations,
micropores, etc. Thresholding algorithms used for simple background extractions
work better if we *dilute* these disturbances by some means. A basic and
effective way is to use a Gaussian filter to blur the image.

You can test the impact of blurring variance using the following slider.

```
σ = 5.0
imgg = imfilter(imgc, Kernel.gaussian(σ))
```

The package `ImageBinarization` provides several binarization algorithms. A full
list of algorithms provided by the package is found
[here](https://juliaimages.org/ImageBinarization.jl/stable/). Below we provide a
drop-down menu for testing which algorithm works better with the sample image.
Notice that the quality of this binarization will depend on how much blurring
was applied above and that algorithms behave differently depending on the level
of the variance.

```
# algos = [
#     Balanced      => "Balanced",
#     Entropy       => "Entropy",
#     MinimumError  => "MinimumError",
#     Moments       => "Moments",
#     Otsu          => "Otsu",
#     UnimodalRosin => "UnimodalRosin",
#     Yen           => "Yen"
# ];

imgb = binarize(imgg, Balanced())
```

In the binarized image above, the pores are set to black with a value of zero,
and the material background to white, with a value of one. Since a gray-scale
image as such is *no more than a matrix* [^1], adding up all values and dividing
by the number of elements in the matrix gives the fraction of white (one-valued)
pixels. The next cell uses this logic for a first quantification of black
(zero-valued) pixels, the quantity we are seeking here for porosity estimation.

[^1]: the actual implementation is more complex than stated here, but for our
    ends here, the representation of the data storage is an actual matrix and
    this terminology can be applied.

```
convert(Float64, 1 - sum(imgb) / length(imgb))
```

As you will see in what comes next, the value above is *correct* [^1] and could
be used for its end scientific purposes. In practical terms, although its
correctness, it is not enough to get the simple pore fraction. This is because
most applications requiring pore quantification also *ask* other questions, such
as mean size, morphological characteristics, etc. Below we use an unseeded
region segmenter to labelize the image for further processing. This will enable
to complete the workflow with the additional characterization that could be
required. Since we are dealing with a binary image with intensity $I\in\{0,1\}$,
providing a threshold of one-half allows for a two-class labelization as desired
- actually any value $0 < x < 1$ would work, but for some reason we decide not
to binarize the image or adapt to other applications, that could break the
workflow.

The following snippet allows checking that labelization can be reconstructed
into a binarized image. Since There are two labels (numbered as 1 and 2) we
subtract 1 from the map.

```
Gray.(labels_map(seg) .- 1)
```

[^1]: an actual sensitivity analysis with regards to filtering parameters should
    be performed in order to quantify the uncertainty of this estimation, what
    is left as a task for the reader.

```
seg = unseeded_region_growing(imgb, 1//2)
```

```
@assert segment_mean(seg, 1) ≈ 0.0
```

```
segment_pixel_count(seg, 1) / length(imgb)
```

## Preparing automation

```
struct PorositySegmenter
	orig::Matrix{Gray{N0f8}}
	pore::Matrix{Gray{N0f8}}
	fraction::Float64
	segm::Any
	
	# TODO keep parameters as attributes.

	function PorositySegmenter(
		orig::Matrix{Gray{N0f8}};
		sigma::Float64 = 0.0,
		method::Symbol = :porequantification,
		poreclass::Int64 = 1,
		binalg::Any = Balanced()
	)::PorositySegmenter
		@assert sigma >= 0.0
		imgg = imfilter(orig, Kernel.gaussian(sigma))
		pore = binarize(imgg, binalg)
		npix = length(pore)
		
		if method == :porequantification
			# Fast but no segmentation!
			segm = nothing
			fraction = convert(Float64, 1.0 - sum(pore) / npix)
		elseif method == :poresegmentation
			# MUCH slower but gets the image.
			segm = unseeded_region_growing(pore, 1//2)
			fraction = segment_pixel_count(segm, 1) / npix
			@assert segment_mean(segm, poreclass) ≈ 0.0
		else
			error("Unknown method: $(method)")
		end

		return new(orig, pore, fraction, segm)
	end
end
```

```
orig = Gray.(load(filepath))[1:end-80, 1:end];
porosity = PorositySegmenter(orig; sigma = 5.0);
porosity.fraction
```

```
@time imgg_ = imfilter(orig, Kernel.gaussian(5));
@time pore_ = binarize(imgg_, Balanced());
@time segm_ = unseeded_region_growing(pore_[:, :], 1//2);
```

```
scanner(σ) = PorositySegmenter(orig; sigma = σ)
```

```
σ̂ = 0.0:0.25:15.0
porescan = map(scanner, σ̂)
porosities = [p.fraction for p in porescan]
plot(σ̂, porosities)
```

```
mean(porosities), std(porosities)
```

```
scanner(6.0)
```

```
# ((porosity.pore - porosity.orig).^2)

# using Random

# begin
# 	dist = 1.0 .- distance_transform(feature_transform(imgb .> 0.5));
# 	Gray.(dist)
# end

# begin
# 	markers = label_components(dist .< 1);
# 	# Gray.(markers/255)
# end

# segments = watershed(dist, markers)

# function get_random_color(seed)
#     Random.seed!(seed)
#    (rand(N0f8))
# end

# for mm in labels_map(segments)
# 	println(length(mm))
# end

# Gray.(map(i -> get_random_color(i), labels_map(segments)))# .* (1 .- imgb)

# (h, w) = size(img)
# µm = 1.0u"µm"

# axy = Axis{:y}(1*µm:1*µm:w*µm)
# axx = Axis{:x}(1*µm:1*µm:h*µm)

# img₀ = AxisArray(img, axx, axy)
# img₀ = Gray.(img₀)

# p = plot(axis = nothing, layout = @layout([a b c]), size = (950, 440), )

# p0 = plot!(p[1], img₀', ratio=1)
# p1 = plot!(p[2], binarize(img₁, alg)', ratio=1)
# p2 = plot!(p[3], binarize(img₁, MinimumError())', ratio=1)
```

\patreon
