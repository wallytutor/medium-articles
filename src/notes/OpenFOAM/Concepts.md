## Granular flows

- **Parcel** is a computational particle unit that may be composed of several particles which are all identical sharing a state, which include velocity, size, temperature, etc. See [O'Rourke (2010)](https://doi.org/10.1016/j.ces.2010.08.032) for details.

- **Cloud** is the term OpenFOAM uses to describe particle flows. Here we will use both `MPPICCloud` and`collidingCloud`, other types being available for reacting or multiphase solvers, such as `thermoCloud`.

## Technological

- **Siwek chamber** is a reactor often used to determine the dispersion of solid fuels for combustion. Validation of simulations can be done through [this](https://www.sciencedirect.com/science/article/abs/pii/S0950423009000801) and [this](https://www.sciencedirect.com/science/article/abs/pii/S0950423014002332) paper. Other than the OpenFOAM [case](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/simplifiedSiwek) there is also [this](https://fetchcfd.com/view-project/763-Simplified-Siwek) setup available on Fetch CFD.

