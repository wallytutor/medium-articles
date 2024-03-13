
In OpenFOAM, *clouds* designate the injection of a secondary phase, generally solid particles or droplets, in a primary continuous carrier phase. The dictionary `cloudProperties` is identified in tutorials related to the following solver modules:

1. [`incompressibleDenseParticleFluid`](../incompressibleDenseParticleFluid/index)
2. `incompressibleFluid`
3. [`multicomponentFluid`](../multicomponentFluid/index)
4. `multiRegion`

The default version of the dictionary provided [here](https://github.com/OpenFOAM/OpenFOAM-11/blob/master/etc/caseDicts/solvers/lagrangian/cloudProperties) is not yet documented as of OpenFOAM v11 and does not contain any solver specific configurations, so the users must refer to the tutorial cases for setting up their studies.  A post-processing particle tracking function associated to the dictionary is provided [here (untested)](https://github.com/OpenFOAM/OpenFOAM-11/blob/master/etc/caseDicts/postProcessing/solvers/particles).

## Cloud types

| Cloud | Description |
| ---- | ---- |
| [MPPICCloud]() |  |
| [reactingMultiphaseCloud]() |  |
| [sprayCloud]() |  |
|  |  |
|  |  |
## Guidelines

> **NOTE:** the text that follows was written when creating cases for `incompressibleDenseParticleFluid`. Care must be taken when following the recommendations below since they are (for now) solver-specific. This will be updated as I take notes while building/testing cases for other solvers using clouds.

Most default values in `solution` dictionary should be fine for typical fluid-particle applications, but for phase interaction it is important to configure `coupled` as `true` so that drag forces are applied to the particles and conversely, particles disturb the fluid. 

We must also turn on `cellValueSourceCorrection`, which will correct cell values using latest transfer information. These elements as given in the following block (you can check the full dictionary in the official OpenFOAM tutorials for other details).

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

When using `collidingCloud` we enabled the use of `collisionModel pairCollision` and material properties can be set in detail in sub-dictionary `constantProperties`. Notice that this is computationally expensive, we will come back to this topic in specific examples using it.

On the other hand, `MPPICCloud` makes use only of `patchInteractionModel localInteraction` for interaction with the environment and collisions between particles are not taken into account (that is not completely true if you consider the packing effects that can be enabled as *collisions*). Again, it is better to go deeper in the case studies.

The main models for setting up a particle simulation in `constant/cloudProperties`  are:

- [[Models#Injection models|InjectionModel]]
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

## Verification

Using the base package provided [here](https://github.com/wallytutor/OpenFOAM) we can verify the computation of number of parcels per second of sample case `injectionChannel`. Notice that the value of `mdot` has been reversed engineered so that it matches the expected value.

```
import OpenFOAM as OF

OF.parcels_per_second(; mdot = 0.2, rhop = 1000.0, diam = 650.0e-06, nParticle = 1)
# Output: 1390885
```
