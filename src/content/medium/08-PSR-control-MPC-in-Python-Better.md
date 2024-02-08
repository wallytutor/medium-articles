```python
%matplotlib inline
```


<!-- #region -->
The conception of this notebook was performed under the following environment:

```python
>>> import sys; sys.version

# Output:
# '3.11.6 (tags/v3.11.6:8b6ee5b, Oct  2 2023, 14:57:12) [MSC v.1935 64 bit (AMD64)]'
```

Contents for `requirements.txt` for reproducing this notebook:

```plaintext
casadi==3.6.4
matplotlib==3.8.2
numpy==1.26.3
```
<!-- #endregion -->

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

x0_max = 0.85
ndot0 = 0.5 * ndot_tot_num

pars_fixed = [ndot_tot_num, n_tot_num, k_num]
```


```python
def step(xn, pn):
    return F_xdot(xn, pn, *pars_fixed)

def integrate(xn, pn):
    return xn + tau * step(xn, pn)
```

```python
integrate(x, ndot0)
```

```python
J = 0.0
g = []
```


```python
xs2 = SX.sym("xs2", Np+1)
```


```python
lbx = [0.0]
ubx = [x0_max*ndot_tot_num]
v_qdot0 = [SX.sym(f"v_qdot0_0")]
```


```python
xn = x
    
for ts in range(1, Np+1):
    v_qdot0_ts = SX.sym(f"v_qdot0_{ts}")
    v_qdot0.append(v_qdot0_ts)
    
    lbx.append(0.0)
    ubx.append(x0_max*ndot_tot_num)

    xn = integrate(xn, v_qdot0_ts)
    
    J += Q * pow(xn[2] - xs2[ts], 2) +\
         R * pow(v_qdot0_ts - v_qdot0[ts-1], 2)
```

```python
g.append(v_qdot0[0] - ndot0)
```

```python
J += S * pow(xn[2] - xs2[-1], 2)
```

```python
nlp = {
    "f": J,
    "x": vertcat(*v_qdot0), 
    "g": vertcat(*g),
    "p": vertcat(xs2, x)
}
solver = nlpsol("solver", "ipopt", nlp)
```

```python
solver
```

```python
xs2_num = np.zeros(Np+1)
xs2_num[:3*Np//4] = 0.3
xs2_num[3*Np//4:] = 0.6
```

```python
x0_num = [0.0, 1.0, 0.0]
p = [*xs2_num, *x0_num]
```

```python
solution = solver(x0=np.ones(Np+1), p=p, lbx=lbx, ubx=ubx, lbg=0.0, ubg=0.0)
```

```python
ndot0_opt = solution["x"].full().ravel()

xt = np.zeros((Np+1, 3))
xt[0, :] = x0_num

xn = xt[0]
    
for ts in range(1, Np+1):
    xn = integrate(xn, ndot0_opt[ts-1])
    xt[ts] = xn.full().ravel()
```

```python
xs2_max = np.clip(xs2_num + 0.05, 0.0, 1.0)
xs2_min = np.clip(xs2_num - 0.05, 0.0, 1.0)
good = (xt[:, 2] >= xs2_min) & (xt[:, 2] <= xs2_max)
```

```python
steps = list(range(Np+1))
quality = 100 * sum(good.astype("u8")) / len(good)

plt.style.use("default")
fig = plt.figure(figsize=(12, 6))
plt.grid(linestyle=":")
plt.plot(steps, xt[:, 0], label="$X_A$")
plt.plot(steps, xt[:, 1], label="$X_B$")
plt.plot(steps, xt[:, 2], lw=4, label="$X_C$")
plt.step(steps, xs2_max, "k:", label="_none_")
plt.step(steps, xs2_min, "k:", label="_none_")
plt.step(steps, xs2_num, lw=4, label="$X_C$ (target)")
plt.step(steps, ndot0_opt / ndot_tot_num, label="$Q_A$ (relative)", where="post")
plt.fill_between(steps, xs2_min, xs2_max, where=good, alpha=0.3)
plt.title(f"Expected quality level at {quality:.1f}%")
plt.ylabel("Mole fractions and relative flow rate of A")
plt.xlabel("Action step number over prediction horizon")
plt.legend(loc=4, fancybox=True,  framealpha=1.0)
plt.xlim(0, Np)
plt.tight_layout()
```

## Organizing the code

```python
class PlantModel:
    pass

class ControlsMPC:
    pass

def displayresults():
    pass
```

```python

```
