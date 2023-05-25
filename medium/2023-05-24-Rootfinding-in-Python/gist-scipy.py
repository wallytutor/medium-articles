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
