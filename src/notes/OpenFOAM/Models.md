## Combustion models

Models inheriting from [`combustionModel`](https://cpp.openfoam.org/v11/classFoam_1_1combustionModel.html) base class.

| Type | Group | Description |
| ---- | ---- | ---- |
| [`EDC`](https://cpp.openfoam.org/v11/classFoam_1_1combustionModels_1_1EDC.html) | Turbulent | Eddy Dissipation Concept turbulent combustion model. Probably the most popular approach for simulation of gas combustion in industrial processes. |
| `laminar` | Laminar |  |
| `PaSR` | Laminar |  |
| `FDS` | Single-step |  |
| `infinitelyFastChemistry` | Single-step |  |
| `diffusion` | Single-step |  |
| `zoneCombustion` | Filter | Enable the reactions within the specified list of cell-zones and set to zero elsewhere. |
| `noCombustion` | Dummy | Dummy combustion model for 'no combustion'. |
## Injection models

These inherit from [`InjectionModel`](https://cpp.openfoam.org/v11/classFoam_1_1InjectionModel.html) and implement how particles are injected into a continuous medium. The following table summarizes *some* of the available models.

| Type | Description |
| ---- | ---- |
| [coneInjection](https://cpp.openfoam.org/v11/classFoam_1_1ConeInjection.html) | Inject particles in a number of oriented cones. Particles can be generated from a single point or over a disk. Injection can be made at constant velocity, pressure, or with a flow rate and discharge coefficient. |
|  |  |
