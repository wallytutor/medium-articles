## Combustion models

Models inheriting from [`combustionModel`](https://cpp.openfoam.org/v11/classFoam_1_1combustionModel.html) base class.

| Type                                                                            | Group       | Description                                                                                                                                       |
| ------------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`EDC`](https://cpp.openfoam.org/v11/classFoam_1_1combustionModels_1_1EDC.html) | Turbulent   | Eddy Dissipation Concept turbulent combustion model. Probably the most popular approach for simulation of gas combustion in industrial processes. |
| `laminar`                                                                       | Laminar     |                                                                                                                                                   |
| `PaSR`                                                                          | Laminar     |                                                                                                                                                   |
| `FDS`                                                                           | Single-step |                                                                                                                                                   |
| `infinitelyFastChemistry`                                                       | Single-step |                                                                                                                                                   |
| `diffusion`                                                                     | Single-step |                                                                                                                                                   |
| `zoneCombustion`                                                                | Filter      | Enable the reactions within the specified list of cell-zones and set to zero elsewhere.                                                           |
| `noCombustion`                                                                  | Dummy       | Dummy combustion model for 'no combustion'.                                                                                                       |
## Injection models

These inherit from [`InjectionModel`](https://cpp.openfoam.org/v11/classFoam_1_1InjectionModel.html) and implement how particles are injected into a continuous medium. The following table summarizes *some* of the available models.

| Type                                                                          | Description                                                                                                                                                                                                         |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [coneInjection](https://cpp.openfoam.org/v11/classFoam_1_1ConeInjection.html) | Inject particles in a number of oriented cones. Particles can be generated from a single point or over a disk. Injection can be made at constant velocity, pressure, or with a flow rate and discharge coefficient. |
|                                                                               |                                                                                                                                                                                                                     |
## Heat transfer models

These inherit from [HeatTransferModel](https://cpp.openfoam.org/v11/classFoam_1_1HeatTransferModel.html). It is possible to provide a [Stefan flow](https://www.sciencedirect.com/topics/engineering/stefan-flow) approximation to the models by using flag `BirdCorrection` in the models dictionaries.

| Type                                                                            | Description                                                                                                            |
| ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| [NoHeatTransfer](https://cpp.openfoam.org/v11/classFoam_1_1NoHeatTransfer.html) | Dummy class for the `none` option.                                                                                     |
| [RanzMarshall](https://cpp.openfoam.org/v11/classFoam_1_1RanzMarshall.html)     | The Ranz-Marshall ([[@Ranz1952]]) correlation for heat transfer. For a more recent review, see *e.g.* [[@Aissa2015a]]. |
## Composition models

These inherit from [CompositionModel](https://cpp.openfoam.org/v11/classFoam_1_1CompositionModel.html) and consists of carrier species (via thermo package), and additional liquids and solids.

| Type                                                                                          | Description                                           |
| --------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| [NoComposition](https://cpp.openfoam.org/v11/classFoam_1_1NoComposition.html)                 | Dummy class for the `none` option.                    |
| [SingleMixtureFraction](https://cpp.openfoam.org/v11/classFoam_1_1SingleMixtureFraction.html) | Templated parcel multi-phase, multi-component class.  |
| [SinglePhaseMixture](https://cpp.openfoam.org/v11/classFoam_1_1SinglePhaseMixture.html)       | Templated parcel single phase, multi-component class. |
## Phase change models

These inherit from [PhaseChangeModel](https://cpp.openfoam.org/v11/classFoam_1_1PhaseChangeModel.html)

| Type                                                                                          | Description                                                                                            |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [NoPhaseChange](https://cpp.openfoam.org/v11/classFoam_1_1NoPhaseChange.html)                 | Dummy class for the `none` option.                                                                     |
| [LiquidEvaporation](https://cpp.openfoam.org/v11/classFoam_1_1LiquidEvaporation.html)         | Liquid evaporation model using ideal gas assumption.                                                   |
| [LiquidEvaporationBoil](https://cpp.openfoam.org/v11/classFoam_1_1LiquidEvaporationBoil.html) | Liquid evaporation model using ideal gas assumption and includes boiling model based on [[@Zuo2000a]]. |
## Breakup models

These inherit from [BreakupModel](https://cpp.openfoam.org/v11/classFoam_1_1BreakupModel.html) for handling particle breakup.

| Type                                                                        | Description                                                                                                                                             |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [NoBreakup](https://cpp.openfoam.org/v11/classFoam_1_1NoBreakup.html)       |                                                                                                                                                         |
| [PilchErdman](https://cpp.openfoam.org/v11/classFoam_1_1PilchErdman.html)   |                                                                                                                                                         |
| [ReitzDiwakar](https://cpp.openfoam.org/v11/classFoam_1_1ReitzDiwakar.html) | Secondary breakup model adapted to high pressure fuel sprays.                                                                                           |
| [ReitzKHRT](https://cpp.openfoam.org/v11/classFoam_1_1ReitzKHRT.html)       | Secondary breakup model which uses the Kelvin-Helmholtz instability theory to predict the stripped droplets and the Raleigh-Taylor instability as well. |
| [SHF](https://cpp.openfoam.org/v11/classFoam_1_1SHF.html)                   |                                                                                                                                                         |
| [ETAB](https://cpp.openfoam.org/v11/classFoam_1_1ETAB.html)                 | Enhanced TAB model for non-evaporating fuel sprays.                                                                                                     |
| [TAB](https://cpp.openfoam.org/v11/classFoam_1_1TAB.html)                   |                                                                                                                                                         |
