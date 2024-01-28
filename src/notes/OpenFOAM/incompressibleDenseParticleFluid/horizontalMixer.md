The following numerical experiments concern the [horizontalMixer](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/) sample case.

## Conceptual phase

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

- [011](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/011): in fact the role of gravity in [010](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/010) was pretty devastating over the sedimentation rate (quite unexpected given the particle sizes that were used) so a variant  of this case was manually initialized from last state and left to run for a much longer physical time (100 s) using `maxCo 2.0` for faster execution. **CALCULATION DIVERGED, REDO!**

## Physical refinement phase

| Model | Takings |
| ---- | ---- |
| [`InjectionModel`](https://cpp.openfoam.org/v11/classFoam_1_1InjectionModel.html) | **CONFIRM CONCLUSIONS WITH POLYDISTRIBUTED CLOUDS (particles per parcel)!** |
| [`PatchInteractionModel`](https://cpp.openfoam.org/v11/classFoam_1_1PatchInteractionModel.html) | This model is key for the simulation of particles coupled to a fluid. Unless different behavior is expected in the different walls so customization of interaction is required, it is much faster to use a `standardWallInteraction` approach. For understanding the role of parameters `e` and `mu` over rebound one can check [lines 144-168 of source code](https://cpp.openfoam.org/v11/StandardWallInteraction_8C_source.html) and confirm the model is the same as the one implemented in `localInteraction` in [lines 366-391 of sources](https://cpp.openfoam.org/v11/LocalInteraction_8C_source.html). |
| [`PackingModel`](https://cpp.openfoam.org/v11/classFoam_1_1PackingModel.html) |  |
| [`DampingModel`](https://cpp.openfoam.org/v11/classFoam_1_1DampingModel.html) |  |
| [`IsotropyModel`](https://cpp.openfoam.org/v11/classFoam_1_1IsotropyModel.html) |  |
| [`ParticleForce`](https://cpp.openfoam.org/v11/classFoam_1_1ParticleForce.html) | This will be discussed in this section. |

Solution with different drag models:

- [012](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/012) :  [`sphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1SphereDragForce.html)

![Case 012](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-012.gif?raw=true)

- [013](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/013) :  [`WenYuDrag`](https://cpp.openfoam.org/v11/classFoam_1_1WenYuDragForce.html) (used in `injectionChannel`) [implemented](https://cpp.openfoam.org/v11/WenYuDragForce_8C_source.html) from equation (2.12) of Gidaspow (1994).

![Case 013](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-013.gif?raw=true)

- [014](https://github.com/wallytutor/OpenFOAM/tree/main/run/incompressibleDenseParticleFluid/horizontalMixer/014) :  [`ErgunWenYuDrag`](https://cpp.openfoam.org/v11/classFoam_1_1ErgunWenYuDragForce.html) (used in `Goldschmidt`, `cyclone`, and `column`) [implemented](https://cpp.openfoam.org/v11/ErgunWenYuDragForce_8C_source.html) from equation (5.11) of Gidaspow (1994).

![Case 014](https://github.com/wallytutor/OpenFOAM/blob/main/run/incompressibleDenseParticleFluid/horizontalMixer/animation-014.gif?raw=true)

Other drag models:

| Model | Details |
| ---- | ---- |
| [`PlessisMasliyahDrag`](https://cpp.openfoam.org/v11/classFoam_1_1PlessisMasliyahDragForce.html) | Used in GoldschmidtMPPIC. [Implemented](https://cpp.openfoam.org/v11/PlessisMasliyahDragForce_8C_source.html) from Plessis (1988) is adapted for flow through consolidated isotropic porous media. This is outside the scope of the current study but functionality is tested anyways from a computational point of view and to understand its behavior far from its reference application. Calculation diverged, so no results are available. |
| [`distortedSphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1DistortedSphereDragForce.html) | Not used in any tutorial. [Implemented](https://cpp.openfoam.org/v11/DistortedSphereDragForce_8C_source.html) as per Liu (1993) is conceived for the simulation of the effects of drop drag and breakup on fuel sprays. This is far from our scope and is not tested. |
| [`nonSphereDrag`](https://cpp.openfoam.org/v11/classFoam_1_1NonSphereDragForce.html) | Not used in any tutorial. [Implemented](https://cpp.openfoam.org/v11/NonSphereDragForce_8C_source.html) as per Haider (1989) is a drag model for non-spherical particles. Its most important parameter is `phi`, the ratio of the surface area of a sphere with the same volume as the particle to the actual surface area of the particle. |
| [`SchillerNaumannDrag`](https://cpp.openfoam.org/v11/classFoam_1_1SchillerNaumannDragForce.html) | Not used in any tutorial. [Implemented](https://cpp.openfoam.org/v11/SchillerNaumannDragForce_8C_source.html) according the classical paper by Schiller (1935) for modeling drag over spheres. |

Solution with different `sizeDistribution`:

- [ ] `fixedValue`
- [ ] `normal`
- [ ] `RosinRammler`
- [ ] `tabulatedDensity`
	
Solution with different cloud types

- `MPPICCloud`
- `collidingCloud`

For the [`PackingModel`](https://cpp.openfoam.org/v11/classFoam_1_1PackingModel.html)one needs to specify the [ParticleStressModel](https://cpp.openfoam.org/v11/classFoam_1_1ParticleStressModel.html) among the following:

| Model | Details |
| ---- | ---- |
| [HarrisCrighton](https://cpp.openfoam.org/v11/classFoam_1_1ParticleStressModels_1_1HarrisCrighton.html#details) |  |
| [Lun](https://cpp.openfoam.org/v11/classFoam_1_1ParticleStressModels_1_1Lun.html#details) |  |

For both  [`DampingModel`](https://cpp.openfoam.org/v11/classFoam_1_1DampingModel.html) and [`IsotropyModel`](https://cpp.openfoam.org/v11/classFoam_1_1IsotropyModel.html) one needs a [TimeScaleModel](https://cpp.openfoam.org/v11/classFoam_1_1TimeScaleModel.html)

| Option | Details |
| ---- | ---- |
| [equilibrium](https://cpp.openfoam.org/v11/classFoam_1_1TimeScaleModels_1_1equilibrium.html) |  |
|  [isotropic](https://cpp.openfoam.org/v11/classFoam_1_1TimeScaleModels_1_1isotropic.html) |  |
| [nonEquilibrium](https://cpp.openfoam.org/v11/classFoam_1_1TimeScaleModels_1_1nonEquilibrium.html) |  |

## References

- [Gidaspow (1994)]([https://doi.org/10.1016/C2009-0-21244-X](https://doi.org/10.1016/C2009-0-21244-X))
- [Plessis (1988)](https://doi.org/10.1007/BF00820342)
- [Liu (1993)](https://doi.org/10.4271/930072)
- [Haider (1989)](https://doi.org/10.1016/0032-5910(89)80008-7)
- Schiller (1935)

