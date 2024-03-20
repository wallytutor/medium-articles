```table-of-contents
title: 
style: nestedList # TOC style (nestedList|inlineFirstLevel)
minLevel: 0 # Include headings from the specified level
maxLevel: 0 # Include headings up to the specified level
includeLinks: true # Make headings clickable
debugInConsole: false # Print debug info in Obsidian console
```
## Planned studies

- Learning steps
	- [x] [Base tutorial](http://basilisk.fr/Tutorial)
	- [ ] [Review of main examples](http://basilisk.fr/src/examples/README)
	- [ ] [Review of extra examples (1)](http://basilisk.fr/sandbox/Antoonvh/README)
	- [ ] [Review of extra examples (2)](http://basilisk.fr/sandbox/M1EMN/README)
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
| `periodic` |  | Set periodic boundary conditions. |
| `statsf` | [utils.h](http://basilisk.fr/src/utils.h) | Retrieve statistics of a scalar field. |
| `output_ppm` | [output.h](http://basilisk.fr/src/output.h) | Generate a image and video output. |
| `adapt_wavelet` | [grid/tree-common.h](http://basilisk.fr/src/grid/tree-common.h) | Adaptive grid refinement routine. |
| `run` | [run.h](http://basilisk.fr/src/run.h) (overloaded) | Generic time loop for events execution. |
| `noise` |  | Generate random noise in $[-1; 1]$. |
| `swap` |  | Swap values of two scalar arrays. |
| `input_stl` | [distance.h](http://basilisk.fr/src/distance.h#input_stl) | Read an STL file as an array of triplets. |
| `bounding_box` | [distance.h](http://basilisk.fr/src/distance.h#bounding_box) | Determines the bounding box of inputs (segments or triangles). |
| `distance` | [distance.h](http://basilisk.fr/src/distance.h#distance) | Distance to coordinate. |
| `view` | [draw.h](http://basilisk.fr/src/draw.h#view) | Setup of viewing (camera) parameters. |
| `isosurface` | [draw.h](http://basilisk.fr/src/draw.h#isosurface) | Displays an isosurface of a field. |
| `draw_vof` | [draw.h](http://basilisk.fr/src/draw.h#draw_vof) | Display VOF reconstructed interfaces. |
| `clear` | [draw.h](http://basilisk.fr/src/draw.h#clear) | Removes previous objects. |
| `save` | [view.h](http://basilisk.fr/src/view.h#save) | Dumps image(s) to file. |
| `refine_biquadradic` | [grid/multigrid-common.h](http://basilisk.fr/src/grid/multigrid-common.h#refine_biquadratic) |  |
| `wavelet` | [grid/multigrid-common.h](http://basilisk.fr/src/grid/multigrid-common.h#wavelet) |  |
| `inverse_wavelet` | [grid/multigrid-common.h](http://basilisk.fr/src/grid/multigrid-common.h#inverse_wavelet) |  |
| `boundary_level` |  |  |
| `unrefine` |  |  |
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

### Tutorial basics
| Reference | [Tutorial](http://basilisk.fr/Tutorial) |
| ---- | ---- |
| Code | 01-Tutorial-Basics |
| Notes | Basilisk is a conceptual solver for investigating problems in a Cartesian domain.<br><br>Different steps of the simulations are set by `event`'s, which use a specific syntax do indicate whether they depend on a time or iteration condition. These steps might include setup of initial conditions, storage of intermediate results or solution, grid refinement, etc.<br><br>For iterating over arrays Basilisk provides a `foreach()`loop extending the C-language.<br><br>A standard `Makefile` is provided by Basilisk for managing common workflows.<br><br>Check the [tips](http://basilisk.fr/src/Tips). |
### Game of life
| Reference | [Conway’s game of life](http://basilisk.fr/src/examples/life.c) |
| ---- | ---- |
| Code | 02-Game-of-life |
| Notes | A simple implementation of [Conway's game of life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) to get used with syntax. |
### Brusselator
| Reference | [Coupled reaction-diffusion equations](http://basilisk.fr/src/examples/brusselator.c) |
| ---- | ---- |
| Code | 03-Brusselator |
| Notes | Solves the 2D [Brusselator](https://en.wikipedia.org/wiki/Brusselator), a theoretical autocatalytic reaction diffusion system. The set of parameters used in the study for the stable Turin points where the ones proposed by [[@Pena2001a]] **Interesting** material for preparing courses extending this to other oscillating systems can be found [here](https://web.archive.org/web/20170909182522/http://www.idea.wsu.edu/OscilChem/#Brusselator%20Model). |
### Ginzburg-Landau
| Reference | [The complex Ginzburg-Landau equation](http://basilisk.fr/src/examples/ginzburg-landau.c) |
| ---- | ---- |
| Code | 04-Ginzburg-Landau |
| Notes | Solves the complex [Ginzburg-Landau equation](https://en.wikipedia.org/wiki/Ginzburg%E2%80%93Landau_equation) describing the nonlinear evolution of disturbances near the transition from a stable to unstable state of a system. Additional materials are provided [here](https://codeinthehole.com/tutorial/index.html). It would be a **good project** to include the term $\alpha$ in the equation and the Laplacian term that goes with it. |
### Distance field
| Reference | [Distance field computation from a 3D model](http://basilisk.fr/src/examples/distance.c) |
| ---- | ---- |
| Code | 05-Distance-Field |
| Notes | This can be seen as a particular case of pre-/post-processing. It can prove useful when initializing domains with scanned surfaces in STL or other compatible format. Additional [steps](http://basilisk.fr/src/gl/INSTALL) must be taken for compilation with rendering (modifications to Makefile). Iteration over dimensions can be done with `foreach_dimension()`. |
### Wavelet transform
| Reference | [Wavelet transforms and filtering](http://basilisk.fr/src/examples/wavelet.c) |
| ---- | ---- |
| Code | 06-Wavelet-Transform |
| Notes | Provides a tutorial on wavelet transform and associated filters. It is presented as the basis to understand mesh adaptation in Basilisk. Recommended reading of [[@Sweldens1998a]]. |
### Decaying turbulence
| Reference | [Decaying two-dimensional turbulence](http://basilisk.fr/src/examples/turbulence.c) |
| ---- | ---- |
| Code | 07-Decaying-Turbulence |
| Notes |  |
### Vortex street
| Reference | [Bénard–von Kármán Vortex Street for flow around a cylinder](http://basilisk.fr/src/examples/karman.c) |
| ---- | ---- |
| Code | 08-Vortex-Street |
| Notes |  |
### Vortex shedding
| Reference | [Vortex shedding behind a sphere](http://basilisk.fr/src/examples/sphere.c) |
| ---- | ---- |
| Code | 09-Vortex-Shedding |
| Notes |  |
### Porous medium
| Reference | [Stokes flow through a complex 3D porous medium](http://basilisk.fr/src/examples/porous3D.c) |
| ---- | ---- |
| Code | 10-Porous-Medium |
| Notes |  |
### Periodic box
| Reference | [Forced isotropic turbulence in a triply-periodic box](http://basilisk.fr/src/examples/isotropic.c) |
| ---- | ---- |
| Code | 11-Periodic-Box |
| Notes |  |
### Pulsed atomization
| Reference |  |
| ---- | ---- |
| Code | 12-Pulsed-Atomisation |
| Notes |  |
### Bubble rising
| Reference |  |
| ---- | ---- |
| Code | 13-Bubble-Rising |
| Notes |  |
### Rotating cylinder
| Reference |  |
| ---- | ---- |
| Code | 14-Rotating-Cylinder |
| Notes |  |
### Moving Tangaroa
| Reference |  |
| ---- | ---- |
| Code | 15-Moving-Tangaroa |
| Notes |  |
### x
| Reference | [The 2004 Indian Ocean tsunami](http://basilisk.fr/src/examples/tsunami.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [The 2011 Tohoku tsunami](http://basilisk.fr/src/examples/tohoku.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [Breakup of a rectangular perturbation into a train of solitons](http://basilisk.fr/src/examples/madsen.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [Tidally-induced internal lee waves](http://basilisk.fr/src/examples/lee.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [Periodic wave propagation over an ellipsoidal shoal](http://basilisk.fr/src/examples/shoal.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [Periodic wave propagation over an ellipsoidal shoal (multilayer)](http://basilisk.fr/src/examples/shoal-ml.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [3D breaking Stokes wave (multilayer solver)](http://basilisk.fr/src/examples/breaking.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [Transcritical flow over a bump](http://basilisk.fr/src/examples/gaussian-ns.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [A Shallow Water Analogue for the Standing Accretion Shock Instability](http://basilisk.fr/src/examples/swasi.c) |
| ---- | ---- |
| Code |  |
| Notes |  |
### x
| Reference | [Python interface](http://basilisk.fr/src/examples/example.py) |
| ---- | ---- |
| Code |  |
| Notes |  |

### x
| Reference | [Poisson problem with Python](http://basilisk.fr/src/examples/poisson.py) |
| ---- | ---- |
| Code |  |
| Notes |  |

## Teaching plan

### Week 1

- **In-class:** Fundamentals of scientific computing (history, basics of hardware, number representations, numerical solvers, parallel computing, etc.)
- **Tutorial:** Basics of Linux command line, VIM text editor, programming in C (with mini-projects), and Basilisk C.
### Week 2

- **In-class:** 
- **Tutorial:** 
### Week 3

- **In-class:** 
- **Tutorial:** 
### Week 4

- **In-class:** 
- **Tutorial:** 
### Week 5

- **In-class:** 
- **Tutorial:** 
### Week 6

- **In-class:** 
- **Tutorial:** 
## Glossary

- **Hopf bifurcation**  is a critical point where, as a parameter changes, a system's stability switches and a periodic solution arises. (see [this](https://en.wikipedia.org/wiki/Hopf_bifurcation)).