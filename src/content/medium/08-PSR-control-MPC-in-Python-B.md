# Stirred Reactor Model Predictive Control


## Import tools

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


## Build system of equations

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
F_xdot = Function("F_xdot", [x, ndot[0], ndot_tot, n_tot, k], [xdot])
```


```python
F_xdot
```
```python
F_xdot([0.5, 0.5, 0.0], 10.0, 3.0, 1000.0, 10.0)
```
```python
F_xdot(x, ndot[0], ndot_tot, n_tot, k * x[1])
```

## Provide parameters

```python
Np = 200
tau = 10.0

Q = 1.0
R = 0.1
S = 100.0

k_num = 10.0
n_tot_num = 500.0
ndot_tot_num = 3.0

ndot0_max = 0.9 * ndot_tot_num
ndot0_ini = 0.5 * ndot_tot_num

pars_fixed = [ndot_tot_num, n_tot_num, k_num]
```


## Integrate symbolically

```python
def step(xn, pn):
    return F_xdot(xn, pn, *pars_fixed)

def integrate(xn, pn):
    return xn + tau * step(xn, pn)
```

```python
integrate(x, ndot0_ini)
```

```python
J = 0.0
g = []

xs2 = SX.sym("xs2", Np+1)

lbx = []
ubx = []
v_ndot0 = []
```


```python
xn = x
    
for ts in range(Np):
    v_ndot0_ts = SX.sym(f"v_ndot0_{ts}")
    v_ndot0.append(v_ndot0_ts)
    
    lbx.append(0.0)
    ubx.append(ndot0_max)

    xn = integrate(xn, v_ndot0_ts)

    v_prev = ndot0_ini if ts == 0 else v_ndot0[ts-1]

    scale_error  = xn[2] - xs2[ts]
    scale_change = v_prev - v_ndot0_ts

    cost_error = Q * pow(scale_error, 2)
    cost_change = R * pow(scale_change, 2)
    
    J += cost_error + cost_change
    
J += S * pow(xn[2] - xs2[-1], 2)
```

## Optimize controls

```python
nlp = {
    "f": J,
    "x": vertcat(*v_ndot0), 
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
xs2_num[:3*Np//5] = 0.2
xs2_num[3*Np//5:] = 0.5
```

```python
x0_num = [0.0, 1.0, 0.0]
p = [*xs2_num, *x0_num]
```

```python
solution = solver(x0=np.ones(Np), p=p, lbx=lbx, ubx=ubx, lbg=0.0, ubg=0.0)
```

## Post-processing

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

steps = list(range(Np+1))
quality = 100 * sum(good.astype("u8")) / len(good)

cmd = list(ndot0_opt / ndot_tot_num)
cmd.append(cmd[-1])

plt.style.use("default")
fig = plt.figure(figsize=(12, 6))
plt.grid(linestyle=":")

plt.plot(steps, xt[:, 0], label="$X_A$")
plt.plot(steps, xt[:, 1], label="$X_B$")
plt.plot(steps, xt[:, 2], lw=4, label="$X_C$")

plt.step(steps, xs2_max, "m--", lw=2, label="_none_", where="post")
plt.step(steps, xs2_min, "m--", lw=2, label="_none_", where="post")
plt.step(steps, xs2_num, "m-", lw=1, label="$X_C$ (target)", where="post")

# Add *negative time* with initial flow rate.
plt.step([-1, *steps], [ndot0_ini/ ndot_tot_num, *cmd], "r", lw=2, 
         label="$Q_A$ (relative)", where="post")

plt.fill_between(steps, xs2_min, xs2_max, where=good, alpha=0.3)

plt.title(f"Expected quality level at {quality:.1f}%")
plt.ylabel("Mole fractions and relative flow rate of A")
plt.xlabel("Action step number over prediction horizon")
plt.legend(loc="upper center", fancybox=True, framealpha=1.0, ncol=6)
plt.xlim(-1, Np)
plt.ylim(0, 1)
plt.tight_layout()
```

```python

```
