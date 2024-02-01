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




    SX([x_0, x_1, x_2])




```python
ndot_tot = SX.sym("ndot_tot")

ndot = SX.sym("ndot", 3)
ndot[1] = ndot_tot - ndot[0]
ndot[2] = 0

ndot
```




    SX([ndot_0, (ndot_tot-ndot_0), 0])




```python
k = SX.sym("k")
rate = k * x[0]
rate
```




    SX((k*x_0))




```python
ndot_gen = vertcat(-rate, 0.0, rate)
ndot_gen
```




    SX(@1=(k*x_0), [(-@1), 0, @1])




```python
n_tot = SX.sym("n_tot")

xdot = (ndot - ndot_tot * x + ndot_gen) / n_tot
xdot
```




    SX(@1=(k*x_0), [(((ndot_0-(ndot_tot*x_0))-@1)/n_tot), (((ndot_tot-ndot_0)-(ndot_tot*x_1))/n_tot), ((@1-(ndot_tot*x_2))/n_tot)])




```python
p = [ndot[0], ndot_tot, n_tot, k]
F_xdot = Function("F_xdot", [x, *p], [xdot])
```


```python
F_xdot
```




    Function(F_xdot:(i0[3],i1,i2,i3,i4)->(o0[3]) SXFunction)




```python
F_xdot([0.5, 0.5, 0.0], 10.0, 3.0, 1000.0, 10.0)
```




    DM([0.0035, -0.0085, 0.005])




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

```
