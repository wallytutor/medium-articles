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

- Modify `controlDict` to integer -steps and enable `purgeWrite` to keep case cleaner.
- Change time-stepping method to `steadyState` in `fvSchemes`.
- Some dictionaries in `cloudProperties` require steady-state specific commands:
	- Add `calcFrequency` to `solution`
	- Add `resetOnStartup` to `solution.sourceTerms`
	- Injection models must use `massFlowRate`
- Modified case so that there is an inlet and an outlet for flame development.