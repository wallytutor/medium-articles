## Breakdown into sub-models

- [ ] Incompressible flow only for mesh and conditions check with `incompressibleFluid`:
	- After a first run with a system length of 1 m it was decided to increase the domain to 2 m in order to ensure a better development of flow profile (at least 10 times the cross section size) and double the number of cells in transversal directions.
	- It was confirmed that the inlet mean velocity profile respects the expected value from the imposed mass flow rate evaluated during parameters setup.
	- Mass conservation was monitored and confirmed through field `phi`.
	- It must be emphasized that boundary layer resolution is not accurate since no grading is applied and mesh is very coarse, but since the goal is flare development this is acceptable at this stage.
	- All residuals are going down adequately, allowing us to move to the next step. 
	- Calculation took approximately 10 seconds with 1 core.

- [ ] Previous case is copied and support to RAS $k-\varepsilon$ ([[@Launder1974]]) is implemented:
	- With inclusion of turbulence the actual outlet velocity matches the expected value (that was unphysical in the previous simulation), validating the approach.
	- Entry length is verified through velocity and turbulent viscosity, confirming the need to extend the domain for a proper development.
	- The number of iterations was increase to 200 to ensure that everything has properly converged, reaching an extremely low residuals level for all variables.
	- Other previous observations are still valid, allowing us to move to the next step.
	- Calculation took approximately 11 seconds with 1 core to perform 100 iterations. After 100 iterations the step convergence becomes slow because of the already low residuals.

- [ ] Adding compressible flow with `multicomponentFluid` to the above:
	- The temperature field is added prior to handling any combustion aspects in this step to avoid having interaction between these elements in convergence checks. 
	- Nonetheless, gravity was already added here after a first run without it for a basic check. A vertical pressure profile is observed in the cross-section, showing the expected buoyancy effects.
	- Other Impacted files include physical properties, which now incorporate more detailed thermodynamics, `alphat` and, at least, the main chemical component file with boundary and initial conditions. 
	- The mean value of `phi` in the outlet can now be compared to the imposed mass flow rate, validating the boundary condition setup.
	- Calculation took approximately 13 seconds with 1 core to perform 100 iterations.

- [ ] The next logical step is to include evaporation of fuel in the gas, without enabling reactions:

- [ ] Add the following to the parameters file for full turbulence model controls:
```C
Cmu             0.09;
C1              1.44;
C2              1.92;
C3              0;
sigmak          1;
sigmaEps        1.3;
```
## Reminders

- Because of `potentialFlow` initialization, a dictionary corresponding to this must be present in `fvSolution` as well as a solver for `Phi` (copy defaults for pressure). Because this solver does not have information about temperature or composition of fluid, a field `rhoInlet` is required in inlets.

## Initial tentative setup

- This case aims producing a steady state liquid fuel combustion model using [aachenBomb](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/aachenBomb) case as a starting point, but does not directly tries to reproduce the results of that case. It was modified so that there is an inlet and an outlet for flame development.

- To perform the setup we retrieve several modifications from [verticalChannelSteady](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelSteady) and [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS). The first because it is the only case under `multicomponentFluid` solver currently using a `steadyState` time-stepping scheme and the latter due to the use of `localEuler`, which is often used to produce pseudo-steady solutions when a direct steady state calculations becomes unstable (as it is the case in most combustion calculations).

- Modify `controlDict` to integer steps (that is, each step is an iteration) for both time-step and write controls, and enable `purgeWrite` to keep case cleaner. Notice that this is also valid if using a `localEuler` time-stepping scheme.  Change time-stepping method accordingly in `fvSchemes`.

- To increase robustness of solution, it is recommended to compute a potential flow with `potentialFoam` as in reference case [verticalChannelLTS](https://github.com/OpenFOAM/OpenFOAM-11/tree/master/tutorials/multicomponentFluid/verticalChannelLTS). This requires a solver control field `Phi` in `fvSolution` and a  reference `rhoInlet` value to be provided in inlet flow velocity. Other parameters, but specially `maxCo` are also copied from reference case.

- Some dictionaries in `cloudProperties` require steady-state specific commands, such as adding `calcFrequency` to `solution`,  `resetOnStartup` to `solution.sourceTerms`, and injection models must use `massFlowRate`, what is physically understandable.

- Combustion is quite sensitive and Seulex alone does not seem able to handle it with an `EDC` approach. First flow was developed further during 100 steps before activating chemistry. For now using a single step `infinitelyFastChemistry` to try to stabilize the behavior before trying back to use the `EDC` model.
