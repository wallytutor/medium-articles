
## Common applications

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

## Articles

- [Physics-Informed Neural Networks: An Application-Centric Guide](https://towardsdatascience.com/physics-informed-neural-networks-an-application-centric-guide-dc1013526b02)

- [Unraveling the Design Pattern of Physics-Informed Neural Networks: Series 01](https://towardsdatascience.com/unraveling-the-design-pattern-of-physics-informed-neural-networks-series-01-8190df459527)

- [Discovering Differential Equations with Physics-Informed Neural Networks and Symbolic Regression](https://towardsdatascience.com/discovering-differential-equations-with-physics-informed-neural-networks-and-symbolic-regression-c28d279c0b4d)

## References

- [Physics-Informed Neural Nets for Control of Dynamical Systems](https://arxiv.org/abs/2104.02556)

- [Physics-Informed Neural Networks for Heat Transfer Problems](https://doi.org/10.1115/1.4050542)

- [Physics-informed neural networks for data-free surrogate modelling and engineering optimization – An example from composite manufacturing](https://publikationen.bibliothek.kit.edu/1000159290)

- [Physics-informed neural networks with hard constraints for inverse design](https://arxiv.org/abs/2102.04626)

- [RAMP-Net: A Robust Adaptive MPC for Quadrotors via Physics-informed Neural Network](https://arxiv.org/abs/2209.09025)

- [A comprehensive study of non-adaptive and residual-based adaptive sampling for physics-informed neural networks](https://arxiv.org/abs/2207.10289)

- []()