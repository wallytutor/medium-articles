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

## Data types

- `scalar`
- `vector`
- `face`
- [`msgstats`](http://basilisk.fr/src/poisson.h#mgstats) convergence statistics of (multigrid?) solver.
## Functions
| Function | Definition | Uses |
| ---- | ---- | ---- |
| `origin` | [common.h](http://basilisk.fr/src/common.h) | Set the origin of cartesian system. |
| `init_grid` | [`grid/`](http://basilisk.fr/src/grid/) (overloaded) | Level of refinement (size) of initial grid. |
| `size` |  |  |
| `statsf` | [utils.h](http://basilisk.fr/src/utils.h) | Retrieve statistics of a scalar field. |
| `output_ppm` | [output.h](http://basilisk.fr/src/output.h) | Generate a image and video output. |
| `adapt_wavelet` | [grid/tree-common.h](http://basilisk.fr/src/grid/tree-common.h) | Adaptive grid refinement routine. |
| `run` | [run.h](http://basilisk.fr/src/run.h) (overloaded) | Generic time loop for events execution. |
| `noise` |  | Generate random noise in $[-1; 1]$. |
| `swap` |  | Swap values of two scalar arrays. |
## Project management

Although Basilisk is a very interesting dialect of C, its documentation is still old-fashioned and lack some structuration. Also sample programs are not written to be easily managed and extended for use in variant cases. Here we propose a structure for better creating projects with Basilisk:

- A Basilisk project lives in its own folder: one executable means one directory.

- The main file is called `app.c` and contains a very simple structure as provided in the dummy listing bellow. All the logic of a project, *i.e. the events*, is implemented in separate header files that are included after Basilisk includes.

```c
// Definitions
#define LEVEL 7
#define ...

// Basilisk includes.
#include "grid/multigrid.h"
#include "run.h"
#include ...  

// Project includes.                                                      #include "project-base.h"
#include "project-init.h"
#include "project-post.h"
#include "project-exec.h"

int main() {
	init_grid(1 << LEVEL);
	...
	run();
}
```

- A simpler `Makefile` than Basilisk's default one is used for project building.

## 2023-03-12 Introductory tutorial

- Basilisk is a conceptual solver for investigating problems in a Cartesian domain.

- Different steps of the simulations are set by `event`'s, which use a specific syntax do indicate whether they depend on a time or iteration condition. These steps might include setup of initial conditions, storage of intermediate results or solution, grid refinement, etc.

- For iterating over arrays Basilisk provides a `foreach()`loop extending the C-language.

- A standard `Makefile` is provided by Basilisk for managing common workflows.

- Check the [tips](http://basilisk.fr/src/Tips).
## 2023-03-14

- Game of life: outputs can be dumped as GIF.

