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
