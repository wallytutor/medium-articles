## Breakdown into sub-models

- [x] Incompressible flow only for mesh and conditions check with `incompressibleFluid`:
	- After a first run with a system length of 1 m it was decided to increase the domain to 2 m in order to ensure a better development of flow profile (at least 10 times the cross section size) and double the number of cells in transversal directions.
	- It was confirmed that the inlet mean velocity profile respects the expected value from the imposed mass flow rate evaluated during parameters setup, but outlet is controversial. This is probably because the case should be run as turbulent or grid is too coarse.
	- Mass conservation was monitored and confirmed through field `phi`.
	- It must be emphasized that boundary layer resolution is not accurate since no grading is applied and mesh is very coarse, but since the goal is flare development far from the walls this is acceptable at this stage and will be dealt with at a later stage.
	- All residuals are going down adequately, allowing us to move to the next step. 
	- Calculation took approximately 10 seconds with 1 core.

- [x] Previous case is copied and support to RAS $k-\varepsilon$ ([[@Launder1974]]) is implemented:
	- With inclusion of turbulence the actual outlet velocity matches the expected value (that was unphysical in the previous simulation), validating the approach.
	- Entry length is verified through velocity and turbulent viscosity, confirming the need to extend the domain for a proper development.
	- The number of iterations was increased to 200 to ensure that everything has properly converged, reaching an extremely low residuals level for all variables.
	- Other previous observations are still valid, allowing us to move to the next step.
	- Calculation took approximately 11 seconds with 1 core to perform 100 iterations. After 100 iterations the step convergence becomes slow because of the already low residuals, leading to a calculation time of 38 seconds.

- [x] Adding compressible flow with `multicomponentFluid` to the above:
	- The temperature field is added prior to handling any combustion aspects in this step to avoid having interaction between these elements in convergence checks. 
	- Nonetheless, gravity was already added here after a first run without it for a basic check. A vertical pressure profile is observed in the cross-section, showing the expected buoyancy effects.
	- Other Impacted files include physical properties, which now incorporate more detailed thermodynamics, `alphat` and, at least, the main chemical component file with boundary and initial conditions. 
	- The mean value of `phi` in the outlet can now be compared to the imposed mass flow rate, validating the boundary condition setup.
	- Calculation took approximately 13 seconds with 1 core to perform 100 iterations. Again an important slow down is observed leading to 125 seconds to perform 300 iterations.

- [x] The next logical step is to include evaporation of fuel in the gas, without enabling reactions:
	- The simples way of doing so is adding the required chemical and associated initial file without adding any combustion or reaction parameters. It was chosen to use the actual species name instead of simply *fuel* to keep created files compatible with next steps. Simulation was checked before adding the cloud, which exponentially complexifies the setup.
	- A `patchPostProcessing` cloud function was tested at first to check if conditions were leading to complete fuel evaporation. It is kept commented-out for future debug if required. To make results easier to interpret, a fixed size PSD was adopted at this stage.
	- As expected, convergence is bad and the only strategy that seems to work is mesh refinement. Otherwise pressure coupling becomes difficult and trying to change numerical parameters (solver correctors, linear solver, divergence and Laplacian schemes, relaxation level) do not improve anything. Tried to use `SOI` at a later iteration to let flow converge before injection, but apparently the steady solver ignores this. Even with `localEuler` pseudo-time stepping (requires to add residuals for `rho` in `fvSolution`) it does not seem to take `SOI` into account.  Also tried deactivating clouds and converging before reactivating it (what would be equivalent to the later `SOI` approach) and that does not work either, confirming it is a physical coupling problem.
	- Because of mesh refinement, now parallelization becomes a requirement unless we work with mesh grading, what is out of the present scope (to be done only in production scenario). Nonetheless, parallelization does not seem to be of great advantage.

- [ ] Activation of global chemistry and combustion modeling:
	- From now on the level of physics start becoming too complex and pre-computation of fields should be done whenever compatible. That means that prior to chemistry activation it seems a good idea to let evaporation of droplets converge (testing 1000 iterations).
	- To keep things general, instead of setting up the case with a fixed database of species thermodynamics, it is better to convert Chemkin files.
	- 

- [ ] Add radiation modeling
- [ ] Add arbitrary empirical fuel modeling

After modification the cases were run again getting the following performances, from which it becomes clear that for the present grid size the parallelization saturates quickly.

| Step | 1 processor | 32 processors |
| ---- | ----------- | ------------- |
| 0    | 77          | 14            |
| 1    |             | 35            |
| 2    |             | 80            |
| 3    |             |               |
| 4    |             |               |
## Future improvements

- [ ] Add the following to the parameters file for full turbulence model controls:
```C
Cmu             0.09;
C1              1.44;
C2              1.92;
C3              0;
sigmak          1;
sigmaEps        1.3;
```

- [ ] Add convergence criteria `PIMPLE: No convergence criteria found`.

- [ ] Consider a possible adaptive mesh refinement at case setup (not runtime!).
## Reminders

- Because of `potentialFlow` initialization, a dictionary corresponding to this must be present in `fvSolution` as well as a solver for `Phi` (copy defaults for pressure). Because this solver does not have information about temperature or composition of fluid, a field `rhoInlet` is required in inlets.

## Initial tentative setup

- This case aims producing a steady state liquid fuel combustion model using [aachenBomb](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/aachenBomb) case as a starting point, but does not directly tries to reproduce the results of that case. It was modified so that there is an inlet and an outlet for flame development.

- To perform the setup we retrieve several modifications from [verticalChannelSteady](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelSteady) and [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS). The first because it is the only case under `multicomponentFluid` solver currently using a `steadyState` time-stepping scheme and the latter due to the use of `localEuler`, which is often used to produce pseudo-steady solutions when a direct steady state calculations becomes unstable (as it is the case in most combustion calculations).

- Modify `controlDict` to integer steps (that is, each step is an iteration) for both time-step and write controls, and enable `purgeWrite` to keep case cleaner. Notice that this is also valid if using a `localEuler` time-stepping scheme.  Change time-stepping method accordingly in `fvSchemes`.

- To increase robustness of solution, it is recommended to compute a potential flow with `potentialFoam` as in reference case [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS). This requires a solver control field `Phi` in `fvSolution` and a  reference `rhoInlet` value to be provided in inlet flow velocity. Other parameters, but specially `maxCo` are also copied from reference case.

- Some dictionaries in `cloudProperties` require steady-state specific commands, such as adding `calcFrequency` to `solution`,  `resetOnStartup` to `solution.sourceTerms`, and injection models must use `massFlowRate`, what is physically understandable.

- Combustion is quite sensitive and Seulex alone does not seem able to handle it with an `EDC` approach. First flow was developed further during 100 steps before activating chemistry. For now using a single step `infinitelyFastChemistry` to try to stabilize the behavior before trying back to use the `EDC` model.
