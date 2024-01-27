Approaches for setting up a flow interacting with particles in OpenFOAM (v11+).

## Fundamental concepts

- **Parcel** is a computational particle unit that may be composed of several particles which are all identical sharing a state, which include velocity, size, temperature, etc. See [O'Rourke (2010)](https://doi.org/10.1016/j.ces.2010.08.032) for details.

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

### Sub-models to explore

The main models for setting up a particle simulation are:

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

When working with `collidingCloud` the following and `PatchInteractionModel` are important:

-  [`CollisionModel`](https://cpp.openfoam.org/v11/classFoam_1_1CollisionModel.html)

### Tips and reminders

- It is a good idea to set `SOI` to a value higher than zero (dimensioned to match the global time-scale of the problem) so that flow is fully developed before particles arrive.

- If it makes sense to do so, make parameter `U0` in the entries of `injectionModels` of `cloudProperties` identical to the velocity specified for the corresponding path. In most cases this applies, except when modeling a particle jet that originates from another source *outside* of the computational domain.

- When working with a 2-D extruded mesh (1-cell in thickness), the mass flow rate must be scaled by the width of the domain to keep consistency with what would be expected in 3-D.

- After the start of injection, a `patchInteraction` is [required](https://cpp.openfoam.org/v11/classFoam_1_1NoInteraction.html#details) otherwise the dummy class representing the setting `none` will generate an error.

### Study case - horizontal mixer

The following numerical experiments concern the [horizontalMixer](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/) sample case.

#### Conceptual phase

Minimal working examples:

- [000](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/000): no models active other than `patchInteraction rebound`.

![Case 000](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-000.gif?raw=true)
	
- [001](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/001): no models active other than `patchInteraction standardWallInteraction`.

![Case 001](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-001.gif?raw=true)

- [002](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/002): no models active other than `patchInteraction localInteraction`.

![Case 002](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-002.gif?raw=true)

If there are outlets in the system, `rebound` model is not suitable. Because of this, all the next cases, unless stated otherwise, will use `localInteraction` given the better control it provides over individual patches with respect to `standardWallInteraction` (although it is much slower than the latter).

- [007](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/007): compare solution for same (approximate) mass flow with using multiple particles per parcel -  with respect to the single particle per parcel performed in the [reference case 002](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/002). The overall cloud shape remains the same but some spatial resolution is lost. For conception studies it seems valid to use a higher number of particles per parcel.

![Case 007](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-007.gif?raw=true)

Using the basic `patchInteraction localInteraction` add these variants (notice that the option `none` for all these models is already covered by the [reference case 002](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/002). After comparing cases [002](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/002) and [007](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/007) the following variants were modified to match [007](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/007) as a reference case given the much lower computational time (more particles per parcel).

- [003](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/003): `packingModel explicit`.

![Case 003](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-003.gif?raw=true)

- [004](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/004): `packingModel implicit`.

![Case 004](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-004.gif?raw=true)

- [005](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/005): `dampingModel relaxation`. Particle velocities are relaxed towards the local mean over a time-scale. Notice that [reference paper](https://doi.org/10.1016/j.ces.2010.08.032 ) intended to improve MP-PIC for polydisperse sedimenting particle clouds.

![Case 005](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-005.gif?raw=true)

- [006](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/006) `isotropyModel stochastic`. According to the [reference paper](https://doi.org/10.1016/j.ces.2012.05.047) collisions cause numerical particles to scatter in MP-PIC calculations, just as physical particles do in particle/fluid flows, just as the generated animation implies.

![Case 006](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-006.gif?raw=true)

Implicit packing so far is the only model for which particles left the system and turbulence effects and segregation becomes apparent. In fact without implicit packing the results do not even look physical, so it is probably a requirement to activate this model. Damping and isotropy models produce similar results, with a little more dispersed cloud when isotropy is active, as stated above from its reference.
	
Hypotheses testing cases:

- [008](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/008): modify case [004](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/004) to test if with `rebound` patch interaction particles are able to quit the system. Confirmed that this patch interaction does not handle outlets.

![Case 008](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-008.gif?raw=true)

- [009](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/009): modify case [004](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/004) to test if with `standardWallInteraction` patch interaction particles are able to quit the system. Confirmed that this patch interaction **does** handle outlets similarly to the `localInteraction`. It was not possible to confirm if inlets also allow backflow since reporting is not provided by patch.

![Case 009](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-009.gif?raw=true)

- [010](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/010): check the role of gravity option over implicit packing model. Here we derive a variant of [009](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/009) because it runs faster than with `localInteraction`. 

![Case 010](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-010.gif?raw=true)

- [011](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/011): in fact the role of gravity in [010](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/010) was pretty devastating over the sedimentation rate (quite unexpected given the particle sizes that were used) so a variant  of this case was manually initialized from last state and left to run for a much longer physical time (100 s) using `maxCo 2.0` for faster execution.

#### Physical refinement phase

| Model | Takings |
| ---- | ---- |
| [`InjectionModel`](https://cpp.openfoam.org/v11/classFoam_1_1InjectionModel.html) | **CONFIRM CONCLUSIONS WITH POLYDISTRIBUTED CLOUDS (particles per parcel)!** |
| [`PatchInteractionModel`](https://cpp.openfoam.org/v11/classFoam_1_1PatchInteractionModel.html) | This model is key for the simulation of particles coupled to a fluid. Unless different behavior is expected in the different walls so customization of interaction is required, it is much faster to use a `standardWallInteraction` approach. For understanding the role of parameters `e` and `mu` over rebound one can check [lines 144-168 of source code](https://cpp.openfoam.org/v11/StandardWallInteraction_8C_source.html) and confirm the model is the same as the one implemented in `localInteraction` in [lines 366-391 of sources](https://cpp.openfoam.org/v11/LocalInteraction_8C_source.html). |
| [`PackingModel`](https://cpp.openfoam.org/v11/classFoam_1_1PackingModel.html) |  |
| [`DampingModel`](https://cpp.openfoam.org/v11/classFoam_1_1DampingModel.html) |  |
| [`IsotropyModel`](https://cpp.openfoam.org/v11/classFoam_1_1IsotropyModel.html) |  |
| [`ParticleForce`](https://cpp.openfoam.org/v11/classFoam_1_1ParticleForce.html) | This will be discussed in this section. |
|  |  |

Solution with different drag models:

- [ ] [`sphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1SphereDragForce.html)
- [ ] [`WenYuDrag`](https://cpp.openfoam.org/v11/classFoam_1_1WenYuDragForce.html)
- [ ] [`ErgunWenYuDrag`](https://cpp.openfoam.org/v11/classFoam_1_1ErgunWenYuDragForce.html)
- [ ] [`PlessisMasliyahDrag`](https://cpp.openfoam.org/v11/classFoam_1_1PlessisMasliyahDragForce.html)
- [ ] [`distortedSphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1DistortedSphereDragForce.html)
- [ ] [`nonSphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1NonSphereDragForce.html)
- [ ] [`SchillerNaumannDrag`](https://cpp.openfoam.org/v11/classFoam_1_1SchillerNaumannDragForce.html)
	
Solution with different `sizeDistribution`:

- [ ] `fixedValue`
- [ ] `normal`
- [ ] `RosinRammler`
- [ ] `tabulatedDensity`
	
Solution with different cloud types

- `MPPICCloud`
- `collidingCloud`

#### Sub-models

For the [`PackingModel`](https://cpp.openfoam.org/v11/classFoam_1_1PackingModel.html)one needs to specify the [ParticleStressModel](https://cpp.openfoam.org/v11/classFoam_1_1ParticleStressModel.html) among the following:

- [HarrisCrighton](https://cpp.openfoam.org/v11/classFoam_1_1ParticleStressModels_1_1HarrisCrighton.html#details)
- [Lun](https://cpp.openfoam.org/v11/classFoam_1_1ParticleStressModels_1_1Lun.html#details)

For both  [`DampingModel`](https://cpp.openfoam.org/v11/classFoam_1_1DampingModel.html) and [`IsotropyModel`](https://cpp.openfoam.org/v11/classFoam_1_1IsotropyModel.html) one needs a [TimeScaleModel](https://cpp.openfoam.org/v11/classFoam_1_1TimeScaleModel.html)

- [equilibrium](https://cpp.openfoam.org/v11/classFoam_1_1TimeScaleModels_1_1equilibrium.html)
- [isotropic](https://cpp.openfoam.org/v11/classFoam_1_1TimeScaleModels_1_1isotropic.html)
- [nonEquilibrium](https://cpp.openfoam.org/v11/classFoam_1_1TimeScaleModels_1_1nonEquilibrium.html)
#### Post-processing features

- [ ] Compute fractional mass in system with respected to injected (extract from log files).
- [ ] Work towards enabling `particleTracks` in `cloudFunctions`.

## Non-isothermal models

- `thermoCloud`


