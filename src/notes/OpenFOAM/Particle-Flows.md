Approaches for setting up a flow interacting with particles in OpenFOAM (v11+).

## Fundamental concepts

- **Parcel** is a computational particle unit that may be composed of several particles which are all identical sharing a state, which include velocity, size, temperature, ... See [O'Rourke (2010)](https://doi.org/10.1016/j.ces.2010.08.032) for details.

## Incompressible isothermal

In this case use solver `incompressibleDenseParticleFluid`. This approach is interesting for dealing with conditions where flow can be considered isothermal and eventual packing of particles is possible. Examples are provided with `OpenFOAM` use `MPPCCloud` or `collidingCloud`.

Boundary fields in general are almost the same as any case in *pure fluid* simulations but transported quantities must be named by appending `.air` to the files if `air` is the name of transporting phase (specified as `continuousPhaseName air` in `constant/physicalProperties`), producing things as `k.air` and `U.air`. Pressure file name remains unchanged. The particularity here is that you must provide `phi` for all hydrodynamic solution variables (such as `k.air`, `U.air`) in outlets. That means that an outlet for velocity should include something as

```C
outlet
{
	type            pressureInletOutletVelocity;
	phi             phi.air;
	inletValue      uniform (0 0 0);
	value           uniform (0 0 0);
}
```

The most complex file to set is `constant/cloudProperties`. Most default values in `solution` dictionary are fine, but for fluid-solid interaction it is important to configure `coupled` as `true` and turn on `cellValueSourceCorrection`, which will correct cell values using latest transfer information, as given in the following block.

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

Using `collidingCloud` enables the use of `collisionModel pairCollision` and material properties can be set in detail with `constantProperties`. With this cloud one can optionally make `patchInteractionModel standardWallInteraction` or other alternative and set global coefficients for interaction with walls (check examples). Notice that this is computationally expensive.

On the other hand, `MPPICCloud` makes use only of `patchInteractionModel localInteraction` for interaction with the environment and collisions between particles are not taken into account.

### Tips and reminders

- It is a good idea to set `SOI` to a value higher than zero (dimensioned to match the global time-scale of the problem) so that flow is fully developed before particles arrive.

- If it makes sense to do so, make parameter `U0` in the entries of `injectionModels` of `cloudProperties` identical to the velocity specified for the corresponding path. In most cases this applies, except when modeling a particle jet that originates from another source *outside* of the computational domain.

- When working with a 2-D extruded mesh (1-cell in thickness), the mass flow rate must be scaled by the width of the domain to keep consistency with what would be expected in 3-D.

- After the start of injection, a `patchInteraction` is [required](https://cpp.openfoam.org/v11/classFoam_1_1NoInteraction.html#details) otherwise the dummy class representing the setting `none` will generate an error.

### Horizontal mixer

The following numerical experiments concern the [horizontalMixer](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/) sample case.

1. Minimal working examples:
	- [x] No models active other than `patchInteraction rebound`  [here](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/000)
	- [ ] No models active other than `patchInteraction standardWallInteraction` - [here](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/001)
	- [ ] No models active other than `patchInteraction localInteraction` - [here](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/002)

	- If there are outlets in the system, the only suitable model is `localInteraction`. This is similar to `standardWallInteraction` but behavior is specified in a patch basis. Because of this all the next cases will use `localInteraction`.

- [ ] Using the basic `patchInteraction localInteraction` add these variants (notice that the option `none` for all these models is already covered by the [reference case](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/002):
	- [ ] `packingModel explicit` - [here](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/003)
	- [ ] `packingModel implicit` - [here](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/004)
	- [ ] `dampingModel relaxation` - [here](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/005)
	- [ ] `isotropyModel stochastic` - [here](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/006)

- [ ] Compare solution for same (approximate) mass flow with using [multiple particles per parcel ](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/007) with respect to the single particle per parcel performed in the [reference case](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/002)
	
- [ ] Solution with different cloud types
	- [ ] `collidingCloud`
	- [ ] `MPPICCloud`

- [ ] Solution with different drag models
	- [ ] [`sphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1SphereDragForce.html)
	- [ ] [`WenYuDrag`](https://cpp.openfoam.org/v11/classFoam_1_1WenYuDragForce.html)
	- [ ] [`ErgunWenYuDrag`](https://cpp.openfoam.org/v11/classFoam_1_1ErgunWenYuDragForce.html)
	- [ ] [`PlessisMasliyahDrag`](https://cpp.openfoam.org/v11/classFoam_1_1PlessisMasliyahDragForce.html)
	- [ ] [`distortedSphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1DistortedSphereDragForce.html)
	- [ ] [`nonSphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1NonSphereDragForce.html)
	- [ ] [`SchillerNaumannDrag`](https://cpp.openfoam.org/v11/classFoam_1_1SchillerNaumannDragForce.html)
	
- [ ] Solution with different `sizeDistribution`
	- [ ] `fixedValue`
	- [ ] `normal`
	- [ ] `RosinRammler`
	- [ ] `tabulatedDensity`
	- [ ] 

## Non-isothermal models

- `thermoCloud`

## Sub-models to explore

The main models for setting up a particle simulation are:

- [ ] [`InjectionModel`](https://cpp.openfoam.org/v11/classFoam_1_1InjectionModel.html)
- [ ] [`ParticleForce`](https://cpp.openfoam.org/v11/classFoam_1_1ParticleForce.html)

Notice that when dealing with `incompressibleDenseParticleFluid` the main `ParticleForce` models other than `gravity` are inherited by [`DenseDragForce`](https://cpp.openfoam.org/v11/classFoam_1_1DenseDragForce.html)

When working with `collidingCloud` the following and `PatchInteractionModel` are important:

- [ ] [`CollisionModel`](https://cpp.openfoam.org/v11/classFoam_1_1CollisionModel.html)

In the case of `MPPICCloud` focus is given in the following:

- [ ] [`DampingModel`](https://cpp.openfoam.org/v11/classFoam_1_1DampingModel.html)
- [ ] [`IsotropyModel`](https://cpp.openfoam.org/v11/classFoam_1_1IsotropyModel.html)
- [ ] [`PackingModel`](https://cpp.openfoam.org/v11/classFoam_1_1PackingModel.html)
- [ ] [`PatchInteractionModel`](https://cpp.openfoam.org/v11/classFoam_1_1PatchInteractionModel.html)

In some particular situations the following models might be required:

- [ ] [`DispersionModel`](https://cpp.openfoam.org/v11/classFoam_1_1DispersionModel.html)
- [ ] [`HeatTransferModel`](https://cpp.openfoam.org/v11/classFoam_1_1HeatTransferModel.html)
- [ ] [`StochasticCollisionModel`](https://cpp.openfoam.org/v11/classFoam_1_1StochasticCollisionModel.html)
- [ ] [`SurfaceFilmModel`](https://cpp.openfoam.org/v11/classFoam_1_1SurfaceFilmModel.html)

