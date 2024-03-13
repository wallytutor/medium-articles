## Planned studies

- Learning steps
	- [x] [Base tutorial](http://basilisk.fr/Tutorial)
	- [ ] [Review of main examples](http://basilisk.fr/src/examples/README)
	- [ ] [Review of main tests](http://basilisk.fr/src/test/README)
	- [ ] [Review of built-it solvers](http://basilisk.fr/src/README)
	- [ ] [Dimensional analysis tutorial](http://basilisk.fr/Tutorial.dimensions)
	- [ ] [Basilisk C](http://basilisk.fr/Basilisk%20C)
	- [ ] [Past papers](http://basilisk.fr/Bibliography)

- Concluding projects
	- [ ] Convection equation ([samples](http://basilisk.fr/sandbox/M1EMN/README))
	- [ ] Diffusion equation ([samples](http://basilisk.fr/sandbox/M1EMN/README))
	- [ ] Burgers equation
	- [ ] Cavity flow Navier-Stokes

- Advanced projects
	- [ ] Carbonitriding of low alloy steels
	- [ ] JMAK kinetics and heat transfer
	- [ ] Drag-out flow in plate coating
	- [ ] Graf's acetylene decomposition flow
	- [ ] Rising bubble in fluid

- Things to check
	- [ ] Running simulations in parallel
	- [ ] Evaporation and combustion in sandbox
	- [ ] Examples with [granular flows](http://basilisk.fr/sandbox/M1EMN/README#examples-of-granular-flows) and [silos](http://basilisk.fr/sandbox/M1EMN/Exemples/granular_sandglass.c)
	- [ ] Rising bubble with granular flow
	
## 2023-03-12 Introductory tutorial

### General notes

- Basilisk is a conceptual solver for investigating problems in a Cartesian domain.

- Different steps of the simulations are set by `event`'s, which use a specific syntax do indicate whether they depend on a time or iteration condition. These steps might include setup of initial conditions, storage of intermediate results or solution, grid refinement, etc.

- For iterating over arrays Basilisk provides a `foreach()`loop extending the C-language.

- A standard `Makefile` is provided by Basilisk for managing common workflows.

- Check the [tips](http://basilisk.fr/src/Tips).
### Functions introduced in this tutorial

| Function | Definition | Uses |
| ---- | ---- | ---- |
| `origin` | [common.h](http://basilisk.fr/src/common.h) | Set the origin coordinate of cartesian system. |
| `init_grid` | [`grid/`](http://basilisk.fr/src/grid/) (overloaded) | Level of refinement (size) of initial grid. |
| `statsf` | [utils.h](http://basilisk.fr/src/utils.h) | Retrieve statistics of provided scalar field. |
| `output_ppm` | [output.h](http://basilisk.fr/src/output.h) | Generate a *Portable PixMap* image output. |
| `adapt_wavelet` | [grid/tree-common.h](http://basilisk.fr/src/grid/tree-common.h) | Adaptive grid refinement routine. |
| `run` | [run.h](http://basilisk.fr/src/run.h) (overloaded) | Generic time loop for events execution. |
## 2023-03-14


