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
