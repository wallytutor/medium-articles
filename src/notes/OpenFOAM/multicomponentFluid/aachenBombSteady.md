### aachenBombSteady

- This case aims producing a steady state liquid fuel combustion model using [aachenBomb](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/aachenBomb) case as a starting point, but does not directly tries to reproduce the results of that case. It was modified so that there is an inlet and an outlet for flame development.

- To perform the setup we retrieve several modifications from [verticalChannelSteady](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelSteady) and [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS). The first because it is the only case under `multicomponentFluid` solver currently using a `steadyState` time-stepping scheme and the latter due to the use of `localEuler`, which is often used to produce pseudo-steady solutions when a direct steady state calculations becomes unstable (as it is the case in most combustion calculations).

- Modify `controlDict` to integer steps (that is, each step is an iteration) for both time-step and write controls, and enable `purgeWrite` to keep case cleaner. Notice that this is also valid if using a `localEuler` time-stepping scheme.  Change time-stepping method accordingly in `fvSchemes`.

- To increase robustness of solution, it is recommended to compute a potential flow with `potentialFoam` as in reference case [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS). This requires a solver control field `Phi` in `fvSolution` and a  reference `rhoInlet` value to be provided in inlet flow velocity. Other parameters, but specially `maxCo` are also copied from reference case.

- Some dictionaries in `cloudProperties` require steady-state specific commands:
	- Add `calcFrequency` to `solution`
	- Add `resetOnStartup` to `solution.sourceTerms`
	- Injection models must use `massFlowRate`

- Combustion is quite sensitive and Seulex alone does not seem able to handle it with an `EDC` approach. First flow was developed further during 100 steps before activating chemistry. For now using a single step `infinitelyFastChemistry` to try to stabilize the behavior before trying back to use the `EDC` model.
