```table-of-contents
title: 
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
## Dimensionless groups

**Knudsen:** Particles mean free path over system characteristic dimension. Division between rarefied gas (Boltzmann) and continuum mechanics (Navier-Stokes).

**Prandtl:** Ratio of momentum diffusivity to thermal diffusivity $\mathrm{Pr}=\frac{\nu}{\alpha}$. High $\mathrm{Pr}$ indicates that momentum transfer is more effective than heat transfer (oils), while low values (liquid metals) indicate thermal boundary layer is more important than viscous one.

[**Nusselt:**](https://en.wikipedia.org/wiki/Nusselt_number) Ratio of convective to conductive heat transfer at a boundary in a fluid, defined as $\mathrm{Nu}=\frac{hL}{k}$. Often in buoyancy-driven flow analysis it is correlated as $\mathrm{Nu}=a\mathrm{Ra}^b$. A Nusselt number of value one represents heat transfer by pure conduction. Increasing this number implies a laminar conductive-dominant flow and then a convective dominant turbulent flow.

[**Sherwood**](https://en.wikipedia.org/wiki/Sherwood_number):  Also called the **mass transfer [Nusselt number](https://en.wikipedia.org/wiki/Nusselt_number "Nusselt number")**) is a dimensionless number used in mass-transfer operation. It represents the ratio of the total mass transfer rate (convection + diffusion) to the rate of diffusive mass transport, and is named in honor of [Thomas Kilgore Sherwood](https://en.wikipedia.org/wiki/Thomas_Kilgore_Sherwood "Thomas Kilgore Sherwood").

[**Grashof:**](https://en.wikipedia.org/wiki/Grashof_number) Ratio of buoyancy to viscous forces defined as $\mathrm{Gr}=\frac{g\beta(T_s-T_{\infty})L^3}{\nu^2}$ and is analogous to Reynolds number in natural convection. Increasing the value of this number above a given threshold promotes buoyancy driven flow.

[**Rayleigh:**](https://en.wikipedia.org/wiki/Rayleigh_number) Product of Grashof $\mathrm{Gr}$ and Prandtl $\mathrm{Pr}$ numbers. Related to the transition from laminar to turbulent in buoyancy-driven flows. Laminar to turbulent is assumed to take place at $10^9$  [[@Balaji2014]].

[**Péclet:**](https://en.wikipedia.org/wiki/Péclet_number) provides the ratio of advective per diffusive transport of a substance. For mass transport this is given by the product of Reynolds and Schmidt numbers $\mathrm{Re}\,\mathrm{Sc}$ while for thermal energy it is the product of Reynolds and Prandtl numbers $\mathrm{Re}\,\mathrm{Pr}$.
## Granular flows

- **Parcel** is a computational particle unit that may be composed of several particles which are all identical sharing a state, which include velocity, size, temperature, etc. See [[@ORourke2010]] for details.

- **Cloud** is the term OpenFOAM uses to describe particle flows. Here we will use both `MPPICCloud` and`collidingCloud`, other types being available for reacting or multiphase solvers, such as `thermoCloud`.
## Technological

- **Siwek chamber** is a reactor often used to determine the dispersion of solid fuels for combustion. Validation of simulations can be done through [this](https://www.sciencedirect.com/science/article/abs/pii/S0950423009000801) and [this](https://www.sciencedirect.com/science/article/abs/pii/S0950423014002332) paper. Other than the OpenFOAM [case](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/simplifiedSiwek) there is also [this](https://fetchcfd.com/view-project/763-Simplified-Siwek) setup available on Fetch CFD.

## Combustion

- [HyChem](https://web.stanford.edu/group/haiwanglab/HyChem/) is an approach for modeling combustion of real liquid fuels by decomposing the problem into a lumped parameter model of evaporation/devolatilization and a detailed or simplified chemical kinetics approach applied to the gas phase. It is available for high-end fuels such as jet fuel and gasoline.


