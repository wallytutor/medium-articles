
Notes based on *Data-Driven Science and Engineering* by Steven L. Brunton and J. Nathan Kurz. Their proposed teaching materials for the book can be found [here](https://www.databookuw.com/page-6/page-14/). Supplementary notes that might be useful for understanding the concepts are provided in course [AMATH301](https://www.youtube.com/@amath3019/videos). The set of open source materials proposed by Kurz's team is found [here](https://faculty.washington.edu/kutz/page5/page23/).

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```

## Singular Value Decomposition
## Fourier and Wavelet Transforms
## Sparsity and Compressed Sensing
## Regression and Model Selection
## Clustering and Classification
## Neural Networks and Deep Learning
## Data-Driven Dynamical Systems
## Linear Control Theory
## Balanced Models for Control
## Data-Driven Control
## Reduced Order Models (ROMs)
### POD for Partial Differential equations (11.1)

![](https://www.youtube.com/watch?v=I8n8a7q8wLk)

- Proxy models are much faster (lower dimensional)
- Classical discretization (FD) lead to high dimensional schemes
- Model expansion can produce much lower dimension problems
	$$u(x,t) = \sum_{k=1}^{n}a_{k}(t)\psi_k(x)$$
- Idea: plug the modal expansion in the PDE and expand it
- With modal basis the approximations are non-local (global)
- Option 1: Fourier mode expansion - FFT
	$$\psi_k(x)=\frac{1}{L}\exp\left(i\frac{2\pi{}kx}{L}\right)$$
- Goal: try to approximate with $r$ basis instead of large $n$
- Example: try to approximate a Gaussian with FME
- Localized structures require more expansion modes
- Construction similar to spectral methods

### Optimal Basis Elements (11.2)

![](https://www.youtube.com/watch?v=IlYDfGXL0nI)

- Key idea: simulate the dynamics of the system and save snapshots of time-step solutions to then identify a modal expansion.
- The $\tilde{U}$ POD basis $\psi_k$ found by truncating the SVD matrix $U$ at rank $r$ is the optimal in the $L^2$ sense for the given data.
- Use energy *accumulated* in modes as discussed in [Chapter 1](01-Singular-Value-Decomposition) to define the optimal (or good enough) value of $r$.
- The produced ROM is not assured to be safe outside the subspace to which it was identified, though that is fine for several physics.
- 

### POD and Soliton Dynamics (11.3)

![](https://www.youtube.com/watch?v=2GFDVLzFSJU)
### Continuous Formulation of POD

![](https://www.youtube.com/watch?v=TRtAkiOdIP4&feature=youtu.be)
### POD with Symmetries

![](https://www.youtube.com/watch?v=Zl3GjE_C7Vk)
## Interpolation for Parametric ROMs

## Additional materials

![Professor Nick Trefethen, University of Oxford, Linear Algebra Optimization](https://www.youtube.com/watch?v=JngdaWe3-gg)