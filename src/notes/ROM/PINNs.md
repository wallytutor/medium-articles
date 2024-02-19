
## Common applications

 As per [[@Guo2024a]] the following common applications arise from PINNs:
 
- Predictive modeling and simulations
	- Solution of dynamical systems (even high-dimensional)
	- Acceleration of multi-physics simulations

- Optimization and systems control
	- Surrogate models for design optimization
	- Inverse design (finding conditions)
	- Model predictive control
	- Optimal sensor placement
	
- Data-driven insights

- Data-driven enhancement

- Monitoring, diagnostic, and health assessment

## Key Ideas

- *Inject* the prediction values in the governing equations to compose the loss function, enforcing the NN to *obey* the underlying physics.

- There are 2 components in the loss function, the *physical loss* evaluated from the deviation from training data (as is commonplace in NN training) and the PDE loss, which is further divided into *boundary* and *initial condition* losses.

- **Collocation points** is how we call the temporal and spacial coordinates where evaluation of physical properties are computed, corresponding to nodes or cell centers in classical numerical schemes.

## Research opportunities

- Following [[@Guo2023a]] citing the work by [[@Wu2022a]], resampling and refinement methods could be improved by better PDF's and the use of active or reinforcement learning to improve sampling.

## References

Unraveling the design pattern of physics-informed neural networks:

| Post | Subject | Main reference(s) |
| ---- | ---- | ---- |
| [[@Guo2023a]] | Resampling of residual points | [[@Wu2022a]] |
| [[@Guo2023b]] | Ensemble learning and dynamic solution interval expansion | [[@Haitsiukevich2022a]] |
| [[@Guo2023c]] |  |  |
| [[@Guo2023d]] |  |  |
| [[@Guo2023e]] |  |  |
| [[@Guo2023f]] |  |  |
| [[@Guo2023g]] |  |  |

- [Discovering Differential Equations with Physics-Informed Neural Networks and Symbolic Regression](https://towardsdatascience.com/discovering-differential-equations-with-physics-informed-neural-networks-and-symbolic-regression-c28d279c0b4d)

| Reference | Subject |
| ---- | ---- |
| [[@Antonelo2021a]] |  |
| [[@Cai2021a]] |  |
| [[@Haitsiukevich2022a]] |  |
| [[@Lu2019a]] |  |
| [[@Lu2021a]] |  |
| [[@Nabian2021a]] |  |
| [[@Sanyal2022a]] |  |
| [[@Wurth2023a]] |  |
