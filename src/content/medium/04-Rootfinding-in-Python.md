+++
title   = "Root-finding in Python"
tags    = ["optimization", "mathematics", "programming", "python"]
showall = true
outpath = "/assets/content/medium/04-Rootfinding-in-Python/code/output"
publish = "2023-05-24-Rootfinding-in-Python"
+++

# Root-finding in Python

It can be simple and performant, trust me.

Whether you are a scientist or engineer, or anything else, root-finding is a
problem you will find along the way when doing numerical stuff. It doesn't
matter whether you are trying to solve a physical model, doing some operational
research to allocate resources, planning a route, or doing some data fitting,
root-finding will be there in some way.

Python itself is slow, but who does really solve problems in *pure* Python
anyway? If you are here, you are certainly aware that Python is simply an
interface to lower-level compiled code that executes fast enough to handle CPU
intense algorithms. Otherwise, there is some homework you forgot to do!

In what follows we will see how to solve a simple root-finding problem with
different packages from Python *jungle*. Advantages and inconveniences of each
of the approaches are discussed along the way. The idea is to keep the problem
simple but representative enough of a generic non-linear root-finding
application.

For reproducible results, copy the following to a `requirements.txt` file and
run `pip install -r requirements.txt` in a new Python environment. Because
Pyomo is not shipped with Ipopt, you can download the executable for Windows
[here](https://github.com/coin-or/Ipopt/releases/tag/releases%2F3.14.13). For
other platforms you must install it from the package manager or compile it, but
that is outside our scope.

```plaintext
casadi==3.5.6rc2
Pyomo==6.4.1
scipy==1.9.0
```

## Problem statement

In the present study we will implement a solution for the steady state of the
[Brusselator](https://en.wikipedia.org/wiki/Brusselator) at a known stable set
of parameters. If after reading you want other similar problems to practice, you
can check the
[Lotka-Volterra](https://en.wikipedia.org/wiki/Lotka%E2%80%93Volterra_equations)
equations or the [Oregonator](https://en.wikipedia.org/wiki/Oregonator). I let
you check the Wikipedia link for the mathematical formulation of the equations.

**Note:** in a future post we will use the same set of tools for dynamic
simulation of the Brusselator, so hold on because our goal today is to
understand the root-finding implementations only.

Because we want to share some parameters across the different implementations
that will be tested without bothering with changing values accross all files or
reading some text/JSON file, we dump the class `Params` below into a `params.py`
file. This way we can profit from the Python import system to easily load these
values.

```python:params
# -*- coding: utf-8 -*-

class Params:
    """ Standard problem parameters. """
    # Initial guess for problem.
    x0 = [1.0, 1.0]

    # Brusselator coefficients
    A = 1.0
    B = 1.7
```

## Solution approaches

It is time to put our hands to work! Today we will explore three ways of
*finding the roots* of the Brusselator. Before we enter the code, here are a few
words about the packages we will use.

- We start with [SciPy](https://scipy.org/). If you have already done some
  numerical methods in Python, you certainly know this package. It is one of the
  main players in the Python ecosystem and it is broad in the scope of covered
  algorithms. There you find optimization, interpolation, integration, signal
  processing, and much more. Although it provides [some constrained
  optimization](https://docs.scipy.org/doc/scipy/tutorial/optimize.html#constrained-minimization-of-multivariate-scalar-functions-minimize)
  possibilities, it is a quite cumbersome interface, and I would stick to it
  only in simple cases. Here we use version 1.10.1.

- The second package we will explore is [CasADi](https://web.casadi.org/). If
  you are not in the field of model predictive controls, you have never heard of
  it. This package does the job of computing the [jacobian
  matrix](https://en.wikipedia.org/wiki/Jacobian_matrix_and_determinant) of your
  problem for you. Why is that great? Nonlinear root-finding is based on some
  sort of gradient descent, and routines need to compute finite difference
  derivatives to find the progress direction. This is *VERY* error-prone, and
  following the gradient computed from an analytical Jacobian introduces great
  robustness. Yes, you could provide SciPy with the problem Jacobian, but good
  luck deriving and implementing it for complex cases. Version 3.5.6 was
  employed here.

- To wrap-up we introduce [Pyomo](http://www.pyomo.org/). This package has a
  broader audience than CasADi but also a steeper learning curve. Pyomo makes
  things formal from a mathematical standpoint. Let me elaborate. Pyomo allows
  you to declare variables and parameters with given domains, boundaries,
  initialization, etc., using a proper terminology. Also, it supports inequality
  constraints, what is harder to do with CasADi. If you are into Operational
  Research, this is the tool to go. We ran the script with version 6.4.1.

As an alternative to these, you could also use
[Gekko](https://gekko.readthedocs.io/en/latest/), but I will refrain myself from
exploring it because the APM executable distributed with it is not open source.

### The well-known SciPy way

SciPy implementation is the simplest one. You need to formulate the problem
residual equation and return an array whose elements all evaluate to *zero* when
the solution is found. Routine `root` from `scipy.optimize` is used to solve the
problem. An initial guess as well as other function parameters are supplied
through its interface. A full set of parameters is provided in its
[documentation](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.root.html).
I have already used this function to solve problems with a few thousands of
equations, with best execution wall times using `krylov` and `df-sane` methods.
By default, it will use the `hybr` solver.

```python:gist-scipy
# -*- coding: utf-8 -*-
from scipy.optimize import root
from params import Params


def brusselator(x, a, b):
    """ Steady-state Brusselator residual equation. """
    eq1 = x[0] * (b - x[0] * x[1])
    eq0 = a - x[0] - eq1
    return [eq0, eq1]


def solve(brusselator, x0=Params.x0, a=Params.A, b=Params.B):
    """ Solve problem with given coefficients and guess. """
    return root(brusselator, x0, args=(a, b))


sol = solve(brusselator)
print(sol)
```

The object returned by the method contains a flag indicating its success, some
relevant values, and the solution `x` to the problem.

```plaintext
In [1]: %run gist-scipy.py
 message: The solution converged.
 success: True
  status: 1
     fun: [ 4.441e-16 -4.441e-16]
       x: [ 1.000e+00  1.700e+00]
    nfev: 5
    fjac: [[-9.191e-01 -3.939e-01]
           [ 3.939e-01 -9.191e-01]]
       r: [ 7.616e-01 -5.252e-01  1.313e+00]
     qtf: [-8.019e-13  2.004e-12]
```

### Versatile CasADi

CasADi provides a framework `SX` of symbolic operations graph construction. This
allows the package to perform its main goal: automatic differentiation. This is
how it manages to provide the solver with an *analytical Jacobian*. An
interesting feature of CasADi is that you can formulate the problem and provide
it to different nonlinear solvers, even commercial ones, using the same
interface. It is shipped with the great open-source solver
[Ipopt](https://github.com/coin-or/Ipopt). Since our problem is composed only of
*constraint* equations, we set the objective `f` to unity and provide the
constraint array `g`. Notice that the operations graph accepts free parameters
through `p` array in nonlinear problem formulation, which can be provided only
at solution time. Finally, when calling the solver, we can provide violation
tolerances to the constraints through `lbg` and `ubg`, which could be an array
of same size as `g` or simply a scalar. Setting both values to zero here
enforces the goal of root-finding.

```python:gist-casadi
# -*- coding: utf-8 -*-
from pprint import pprint
from casadi import SX
from casadi import nlpsol
from casadi import vertcat
from params import Params


def create_solver():
    """ Create steady-state Brusselator solver. """
    p = SX.sym("p", 2)
    x = SX.sym("x", 2)
    a, b = p[0], p[1]

    eq1 = x[0] * (b - x[0] * x[1])
    eq0 = a - x[0] - eq1
    g = vertcat(eq0, eq1)

    nlp = {"x": x, "p": p, "f": 1.0, "g": g}
    opts = {"ipopt.print_level": 5}
    return nlpsol("brusselator", "ipopt", nlp, opts)


def solve(brusselator, x0=Params.x0, a=Params.A, b=Params.B):
    """ Solve problem with given coefficients and guess. """
    return brusselator(x0=x0, p=[a, b], lbg=0.0, ubg=0.0)


brusselator = create_solver()
sol = solve(brusselator)
pprint(sol)
```

When solving the problem with Ipopt, the solver will display a problem summary,
follow the solution process, and summarize the solution. The level of verbosity
can be controlled when creating the solver, see variable `opts` above in
`create_solver`. To get the solver status you could use
`brusselator.stats()["return_status"]` what is not done in sample code.
Personally, I have used this package in situations when the purely numerical
approach of SciPy failed and it is my choice when conceiving model-predictive
controls (MPC) or any other constrained optimization. Under certain
circumstances you can also generate C code for deployment of solver.

```plaintext
In [1]: %run gist-casadi.py
******************************************************************************
This program contains Ipopt, a library for large-scale nonlinear optimization.
 Ipopt is released as open source code under the Eclipse Public License (EPL).
         For more information visit https://github.com/coin-or/Ipopt
******************************************************************************

This is Ipopt version 3.14.4, running with linear solver MUMPS 5.4.1.

Number of nonzeros in equality constraint Jacobian...:        4
Number of nonzeros in inequality constraint Jacobian.:        0
Number of nonzeros in Lagrangian Hessian.............:        2

Total number of variables............................:        2
                     variables with only lower bounds:        0
                variables with lower and upper bounds:        0
                     variables with only upper bounds:        0
Total number of equality constraints.................:        2
Total number of inequality constraints...............:        0
        inequality constraints with only lower bounds:        0
   inequality constraints with lower and upper bounds:        0
        inequality constraints with only upper bounds:        0

iter    objective    inf_pr   inf_du lg(mu)  ||d||  lg(rg) alpha_du alpha_pr  ls
   0  1.0000000e+00 7.00e-01 0.00e+00  -1.0 0.00e+00    -  0.00e+00 0.00e+00   0
   1  1.0000000e+00 0.00e+00 0.00e+00  -1.7 7.00e-01    -  1.00e+00 1.00e+00h  1

Number of Iterations....: 1

                                   (scaled)                 (unscaled)
Objective...............:   1.0000000000000000e+00    1.0000000000000000e+00
Dual infeasibility......:   0.0000000000000000e+00    0.0000000000000000e+00
Constraint violation....:   0.0000000000000000e+00    0.0000000000000000e+00
Variable bound violation:   0.0000000000000000e+00    0.0000000000000000e+00
Complementarity.........:   0.0000000000000000e+00    0.0000000000000000e+00
Overall NLP error.......:   0.0000000000000000e+00    0.0000000000000000e+00


Number of objective function evaluations             = 2
Number of objective gradient evaluations             = 2
Number of equality constraint evaluations            = 2
Number of inequality constraint evaluations          = 0
Number of equality constraint Jacobian evaluations   = 2
Number of inequality constraint Jacobian evaluations = 0
Number of Lagrangian Hessian evaluations             = 1
Total seconds in IPOPT                               = 0.019

EXIT: Optimal Solution Found.
 brusselator  :   t_proc      (avg)   t_wall      (avg)    n_eval
       nlp_f  |        0 (       0)   3.00us (  1.50us)         2
       nlp_g  |        0 (       0)   8.00us (  4.00us)         2
    nlp_grad  |        0 (       0)   4.00us (  4.00us)         1
  nlp_grad_f  |        0 (       0)  12.00us (  4.00us)         3
  nlp_hess_l  |        0 (       0)   1.00us (  1.00us)         1
   nlp_jac_g  |        0 (       0)   4.00us (  1.33us)         3
       total  |  34.00ms ( 34.00ms)  30.02ms ( 30.02ms)         1

{'f': DM(1),
 'g': DM([0, 0]),
 'lam_g': DM([0, -0]),
 'lam_p': DM([-0, 0]),
 'lam_x': DM([0, 0]),
 'x': DM([1, 1.7])}
```

The dense matrix object `DM` provided in the solution above can be converted to
a NumPy array for further processing in Python.

### Going formal with Pyomo

I told you that the learning path of Pyomo was long, but that pays back. As for
CasADi, Pyomo also accepts several solvers, including proprietary ones. Given
its more format character, it is at declaration time that we tell the model
whether something is a parameter or variable, its mathematical domain, and so
on. When creating a `Constraint` you provide a `rule`, which can be an
inequality, what is not promptly supported by CasADi. The amount of coding is
larger than the previous packages for the same problem, but the goals of
everything are clearer. Pyomo is my package of choice when solving problems that
do not involve step functions (I am still looking for a reliable way of using a
Heaviside function in Pyomo) or for mixed-integer modelling, a feature that is
not supported by the other discussed alternatives. It is also great for handling
DAE problems, but that is a subject for another post.

```python:gist-pyomo
# -*- coding: utf-8 -*-
from pathlib import Path
from pprint import pprint
import pyomo.environ as pe
import pyomo.opt as po
from params import Params

# XXX: Update this or add Ipopt to the path!
apps = Path.home() / "Applications"
ipopt = apps / "Ipopt-3.14.13-win64-msvs2019-md/bin/ipopt.exe"


def create_solver():
    """ Create steady-state Brusselator solver. """
    model = pe.ConcreteModel(name="brusselator")
    model.i = pe.Set(initialize=[0, 1], dimen=1)
    model.a = pe.Param(mutable=True)
    model.b = pe.Param(mutable=True)
    model.x = pe.Var(model.i)

    eq1 = model.x[0] * (model.b - model.x[0] * model.x[1])
    eq0 = model.a - model.x[0] - eq1

    model.eq0 = pe.Constraint(rule=(0.0 == eq0))
    model.eq1 = pe.Constraint(rule=(0.0 == eq1))
    return model


def solve(brusselator, x0=Params.x0, a=Params.A, b=Params.B):
    """ Solve problem with given coefficients and guess. """
    brusselator.a.set_value(a)
    brusselator.b.set_value(b)

    for k, xk in enumerate(x0):
        brusselator.x[k] = xk

    solver = po.SolverFactory("ipopt", executable=ipopt)
    return solver.solve(brusselator)


brusselator = create_solver()
sol = solve(brusselator)
sol.write()

x = [xk.value for xk in brusselator.x.values()]
pprint(x)
```

Solver statistics are printed afterwards, that is an advantage over CasADi
because it saves a lot of time communicating with the standard output.

```plaintext
In [1]: %run gist-pyomo.py
# ==========================================================
# = Solver Results                                         =
# ==========================================================
# ----------------------------------------------------------
#   Problem Information
# ----------------------------------------------------------
Problem:
- Lower bound: -inf
  Upper bound: inf
  Number of objectives: 1
  Number of constraints: 2
  Number of variables: 2
  Sense: unknown
# ----------------------------------------------------------
#   Solver Information
# ----------------------------------------------------------
Solver:
- Status: ok
  Message: Ipopt 3.14.13\x3a Optimal Solution Found
  Termination condition: optimal
  Id: 0
  Error rc: 0
  Time: 0.1560361385345459
# ----------------------------------------------------------
#   Solution Information
# ----------------------------------------------------------
Solution:
- number of solutions: 0
  number of solutions displayed: 0
[1.0, 1.7]
```

## Concluding thoughts

I hope this post helped you make an informed choice of implementation for your
nonlinear root-finding problems.

As we have shown, none of the explored packages handles all the features that
might be required, and this must be considered when starting a new project.
Another important feature is community size and package development team. Both
CasADi and Pyomo are niche applications and finding examples on Stack Overflow
might be a problem.

\patreon
