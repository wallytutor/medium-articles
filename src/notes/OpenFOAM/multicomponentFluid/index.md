In OpenFOAM v11 solver module `multicomponentFluid` provides approaches for setting up the simulation of fluids with multiple species, including combustion.

## Tutorial cases

### Gas phase combustion

### Droplet evaporation combustion

- DLR_A_LTS
- SandiaD_LTS
- [aachenBomb](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/aachenBomb): global combustion kinetics of droplets released in a box.
- counterFlowFlame2D
- counterFlowFlame2DLTS
- counterFlowFlame2DLTS_GRI_TDAC
- counterFlowFlame2D_GRI
- counterFlowFlame2D_GRI_TDAC
- filter
- lockExchange
- membrane
- [nc7h16](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/nc7h16): zero dimensional model of homogeneous kinetics.
- [parcelInBox](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/parcelInBox): evaporation of a single water particle in a closed box.
- [simplifiedSiwek](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/simplifiedSiwek): co-combustion of coal and limestone clouds in Siwek chamber.
- smallPoolFire2D
- smallPoolFire3D
- [verticalChannel](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannel): water droplet evaporation in a vertical channel.
- [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS): same as [verticalChannel](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannel) but with local time-stepping.
- [verticalChannelSteady](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelSteady): same as [verticalChannel](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannel) but at steady state.

## Cases construction

### aachenBombSteady

- This case aims producing a steady state liquid fuel combustion model using [aachenBomb](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/aachenBomb) case as a starting point, but does not directly tries to reproduce the results of that case. It was modified so that there is an inlet and an outlet for flame development.

- To perform the setup we retrieve several modifications from [verticalChannelSteady](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelSteady) and [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS). The first because it is the only case under `multicomponentFluid` solver currently using a `steadyState` time-stepping scheme and the latter due to the use of `localEuler`, which is often used to produce pseudo-steady solutions when a direct steady state calculations becomes unstable (as it is the case in most combustion calculations).

- Modify `controlDict` to integer steps (that is, each step is an iteration) for both time-step and write controls, and enable `purgeWrite` to keep case cleaner. Notice that this is also valid if using a `localEuler` time-stepping scheme.  Change time-stepping method accordingly in `fvSchemes`.

- To increase robustness of solution, it is recommended to compute a potential flow with `potentialFoam` as in reference case [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS). This requires a solver control field `Phi` in `fvSolution` and a  reference `rhoInlet` value to be provided in inlet flow velocity. Other parameters, but specially `maxCo` are also copied from reference case.

- Some dictionaries in `cloudProperties` require steady-state specific commands:
	- Add `calcFrequency` to `solution`
	- Add `resetOnStartup` to `solution.sourceTerms`
	- Injection models must use `massFlowRate`
