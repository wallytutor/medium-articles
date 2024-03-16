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
## Commented examples
| # | Name | Description |
| ---- | ---- | ---- |
| 01 | Tutorial basics | Basilisk is a conceptual solver for investigating problems in a Cartesian domain.<br><br>Different steps of the simulations are set by `event`'s, which use a specific syntax do indicate whether they depend on a time or iteration condition. These steps might include setup of initial conditions, storage of intermediate results or solution, grid refinement, etc.<br><br>For iterating over arrays Basilisk provides a `foreach()`loop extending the C-language.<br><br>A standard `Makefile` is provided by Basilisk for managing common workflows.<br><br>Check the [tips](http://basilisk.fr/src/Tips). |
| 02 | Game of life | A simple implementation of [Conway's game of life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) to get used with syntax. |
| 03 | Brusselator | Solves the 2D [Brusselator](https://en.wikipedia.org/wiki/Brusselator), a theoretical autocatalytic reaction diffusion system. The set of parameters used in the study for the stable Turin points where the ones proposed by [[@Pena2001a]] **Interesting** material for preparing courses extending this to other oscillating systems can be found [here](https://web.archive.org/web/20170909182522/http://www.idea.wsu.edu/OscilChem/#Brusselator%20Model). |
| 04 | Ginzburg-Landau | Solves the complex [Ginzburg-Landau equation](https://en.wikipedia.org/wiki/Ginzburg%E2%80%93Landau_equation) describing the nonlinear evolution of disturbances near the transition from a stable to unstable state of a system. Additional materials are provided [here](https://codeinthehole.com/tutorial/index.html). It would be a **good project** to include the term $\alpha$ in the equation and the Laplacian term that goes with it.  |
|  |  |  |
## Teaching plan

### Week 1

- **In-class:** Fundamentals of scientific computing (history, basics of hardware, number representations, numerical solvers, parallel computing, etc.)
- Basics of Linux command line and installation of VIM and Basilisk
- Programming in C tutorial and mini-projects to warm-up.

### Week 2

- **In-class:** 

### Week 3

- **In-class:** 

### Week 4

- **In-class:** 

### Week 5

- **In-class:** 

### Week 6

- **In-class:** 

## Glossary

- **Hopf bifurcation**  is a critical point where, as a parameter changes, a system's stability switches and a periodic solution arises. (see [this](https://en.wikipedia.org/wiki/Hopf_bifurcation)).