## POD for Partial Differential equations

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
## Optimal Basis Elements

![](https://www.youtube.com/watch?v=IlYDfGXL0nI)

## POD and Soliton Dynamics

![](https://www.youtube.com/watch?v=2GFDVLzFSJU)

## Continuous Formulation of POD

![](https://www.youtube.com/watch?v=TRtAkiOdIP4&feature=youtu.be)

## POD with Symmetries

![](https://www.youtube.com/watch?v=Zl3GjE_C7Vk)
