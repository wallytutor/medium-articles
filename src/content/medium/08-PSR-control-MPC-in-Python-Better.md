```python
%matplotlib inline
```


```python
from casadi import SX
from casadi import Function
from casadi import nlpsol
from casadi import vertcat
import numpy as np
import matplotlib.pyplot as plt
```


```python
x = SX.sym("x", 3)
x
```
```python
ndot_tot = SX.sym("ndot_tot")

ndot = SX.sym("ndot", 3)
ndot[1] = ndot_tot - ndot[0]
ndot[2] = 0

ndot
```
```python
k = SX.sym("k")
rate = k * x[0]
rate
```
```python
ndot_gen = vertcat(-rate, 0.0, rate)
ndot_gen
```
```python
n_tot = SX.sym("n_tot")

xdot = (ndot - ndot_tot * x + ndot_gen) / n_tot
xdot
```
```python
p = [ndot[0], ndot_tot, n_tot, k]
F_xdot = Function("F_xdot", [x, *p], [xdot])
```


```python
F_xdot
```
```python
F_xdot([0.5, 0.5, 0.0], 10.0, 3.0, 1000.0, 10.0)
```
```python
Np = 100
tau = 15.0

Q = 1.0
R = 0.05
S = 100.0

k_num = 10.0
n_tot_num = 1000.0
ndot_tot_num = 3.0

x_A_max = 0.85
ndot0_A = 0.5 * ndot_tot_num
```


```python
J = 0.0
g = []
```


```python
xs_C = SX.sym("xs_C", Np+1)
```


```python
lbx = [0.0]
ubx = [x_A_max*ndot_tot_num]
v_qdot_A = [SX.sym(f"v_dot_A_0")]
```


```python
# for ts in range(1, Np+1):
#     v_qdot_A_ts = SX.sym(f"v_dot_A_{ts}")
#     v_qdot_A.append(v_qdot_A_ts)
    
#     lbx.append(0.0)
#     ubx.append(x_A_max*qdot_t)

#     xn = vertcat(xt_A, xt_B, xt_C)
#     pn = v_qdot_A_ts
        
#     xt_A = xt_A + tau * F_xdot_A(xn, pn)
#     xt_B = xt_B + tau * F_xdot_B(xn, pn)
#     xt_C = xt_C + tau * F_xdot_C(xn, pn)
    
#     J += Q * pow(xt_C - xs_C[ts], 2) +\
#          R * pow(v_qdot_A_ts - v_qdot_A[ts-1], 2)
```
