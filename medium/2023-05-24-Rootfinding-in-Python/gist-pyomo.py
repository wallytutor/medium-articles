# -*- coding: utf-8 -*-
from pathlib import Path
from pprint import pprint
import pyomo.environ as pe
import pyomo.opt as po
from params import Params

apps = Path.home() / "Applications"
ipopt = apps / "Ipopt-3.14.12-win64-msvs2019-md/bin/ipopt.exe"


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
