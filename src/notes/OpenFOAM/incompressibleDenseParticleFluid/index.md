In OpenFOAM v11 solver module `incompressibleDenseParticleFluid` provides approaches for setting up a transient flow interacting with particles.

In this directory we discuss and assembly cases built using this solver to handle incompressible isothermal flows with fluid-particle interactions, including cases with dense packing of particles, such as packed beds or initialization of fluidized beds. 

## Fundamental concepts

- **Parcel** is a computational particle unit that may be composed of several particles which are all identical sharing a state, which include velocity, size, temperature, etc. See [O'Rourke (2010)](https://doi.org/10.1016/j.ces.2010.08.032) for details.

- **Cloud** is the term OpenFOAM uses to describe particle flows. Here we will use both `MPPICCloud` and`collidingCloud`, other types being available for reacting or multiphase solvers, such as `thermoCloud`.

## Boundary fields

Boundary fields in general are almost the same as any case in *pure fluid* simulations but transported quantities must be named by appending the name of the continuous phase specified in  `constant/physicalProperties` as `continuousPhaseName <phase>`. To make it simple let's call this phase `air` in what follows. Notice that pressure file name remains unchanged since it is not really *transported* as you don't have an equation in the form of Reynolds transport theorem for it.

That said, we have things as `k.air` and `U.air`.  The particularity here is that you must provide `phi` for all hydrodynamic solution variables (such as `k.air`, `U.air`) in outlets, what is implicit in single phase flow models. That means that an outlet for velocity should include something as

```C
outlet
{
	type            pressureInletOutletVelocity;
	phi             phi.air;
	inletValue      uniform (0 0 0);
	value           uniform (0 0 0);
}
```

## Creating a cloud

The most complex file to set is `constant/cloudProperties`. Most default values in `solution` dictionary should be fine for typical gas-particle applications, but for phase interaction it is important to configure `coupled` as `true` so that drag forces are applied to the particles and conversely, particles disturb the fluid. We must also turn on `cellValueSourceCorrection`, which will correct cell values using latest transfer information. These elements as given in the following block (you can check the full dictionary in the official OpenFOAM tutorials for other details).

```C
solution
{
	coupled                   true;
	transient                 yes;
	cellValueSourceCorrection on;
	maxCo                     0.7;

	...
}
```

When using `collidingCloud` we enabled the use of `collisionModel pairCollision` and material properties can be set in detail in sub-dictionary `constantProperties`. Notice that this is computationally expensive, we will come back to this topic in specific examples using it. On the other hand, `MPPICCloud` makes use only of `patchInteractionModel localInteraction` for interaction with the environment and collisions between particles are not taken into account (that is not completely true if you consider the packing effects that can be enabled as *collisions*). Again, it is better to go deeper in the case studies.

The main models for setting up a particle simulation in `constant/cloudProperties`  are:

- [`InjectionModel`](https://cpp.openfoam.org/v11/classFoam_1_1InjectionModel.html)
- [`ParticleForce`](https://cpp.openfoam.org/v11/classFoam_1_1ParticleForce.html)

In the case of `MPPICCloud` focus is given in the following:

- [`DampingModel`](https://cpp.openfoam.org/v11/classFoam_1_1DampingModel.html)
- [`IsotropyModel`](https://cpp.openfoam.org/v11/classFoam_1_1IsotropyModel.html)
- [`PackingModel`](https://cpp.openfoam.org/v11/classFoam_1_1PackingModel.html)
- [`PatchInteractionModel`](https://cpp.openfoam.org/v11/classFoam_1_1PatchInteractionModel.html)

In some particular situations the following models might be required:

- [`DispersionModel`](https://cpp.openfoam.org/v11/classFoam_1_1DispersionModel.html)
- [`HeatTransferModel`](https://cpp.openfoam.org/v11/classFoam_1_1HeatTransferModel.html)
- [`StochasticCollisionModel`](https://cpp.openfoam.org/v11/classFoam_1_1StochasticCollisionModel.html)
- [`SurfaceFilmModel`](https://cpp.openfoam.org/v11/classFoam_1_1SurfaceFilmModel.html)

Notice that when dealing with `incompressibleDenseParticleFluid` the main `ParticleForce` models other than `gravity` are inherited by [`DenseDragForce`](https://cpp.openfoam.org/v11/classFoam_1_1DenseDragForce.html).

When working with `collidingCloud` the following is also needed:

-  [`CollisionModel`](https://cpp.openfoam.org/v11/classFoam_1_1CollisionModel.html)

## Tips and reminders

- It is a good idea to set `SOI` to a value higher than zero (dimensioned to match the global time-scale of the problem) so that flow is fully developed before particles arrive.

- If it makes sense to do so, make parameter `U0` in the entries of `injectionModels` of `cloudProperties` identical to the velocity specified for the corresponding path. In most cases this applies, except when modeling a particle jet that originates from another source *outside* of the computational domain.

- When working with a 2-D extruded mesh (1-cell in thickness), the mass flow rate must be scaled by the width of the domain to keep consistency with what would be expected in 3-D.

- After the start of injection, a `patchInteraction` is [required](https://cpp.openfoam.org/v11/classFoam_1_1NoInteraction.html#details) otherwise the dummy class representing the setting `none` will generate an error.

## Problems found

- When working with non-constant particle size distribution (tested with `tabulatedDensity`) and `uniformParcelSize nParticle`, if `nParticle` is not `1` no particle mass inlet was possible. Probably the implementation of how to inject multiple particles per parcel is not implemented in this case (with sampling). Update: after some investigation and variants it would not work even with one particle per parcel. It seems related to the threshold of particle volume fraction per cell (set by `alphaMin` - to be confirmed) since for coarser meshes the it stopped injecting particles.

## Verification

Using the base package provided [here](https://github.com/wallytutor/OpenFOAM) we can verify the computation of number of parcels per second of sample case `injectionChannel`. Notice that the value of `mdot` has been reversed engineered so that it matches the expected value.

```
import OpenFOAM as OF

OF.parcels_per_second(; mdot = 0.2, rhop = 1000.0, diam = 650.0e-06, nParticle = 1)
# Output: 1390885
```
## List of samples

The lists below are provided in a relative order of complexity of model setup (options, post-processing, etc). That might be not the case with respect to the physics involved.
### Gas-particle flows

- [sedimentationBox](sedimentationBox): particles drop-off in a steady closed box.
- [injectionChannel](injectionChannel): particles injection in a channel with outlet flow rate (fan).
- [horizontalMixer](horizontalMixer): a simple mixer for testing several particle models.
- [dustCollector](dustCollector): study case of the role of deflectors over particle flows.

### Liquid-particle flows

- *Upcoming...*

