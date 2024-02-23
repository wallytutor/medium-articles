---
title: Physics-informed neural networks for data-free surrogate modelling and engineering optimization – An example from composite manufacturing
authors: Tobias Würth, Constantin Krauß, Clemens Zimmerling, Luise Kärger
year: 2023
URL: https://doi.org/10.5445/IR/1000159290
Drive: https://1drv.ms/b/s!Ar4x-UlrYAiZla5XEQtEiYnlp5ggtA?e=6TW8va
---
- PINNs are alternative to SBO methods

- Reference 6: one NN per output

- Used same weight for all losses (domain, B.C., I.C.)

- NNs provide automatic jacobian and hessian evaluations, what can be used for great benefit of optimization algorithms

- Implemented in SciANN [[@Haghighat2021sciann]] (wrapper to [[@Tensorflow2015Whitepaper]])

- Solves the [diffusion equation](Transport-Phenomena/Diffusion-Equation.md)

- Kamal-Malkin model can be seem as a more general parametrization as JMKA $\rightarrow$ maybe useful in cement hydration modeling?

- Interesting to write a tutorial about!

