# More advection...


## Courant-Friedrichs-Lewy criterium

The previous examples and proposed exercises have shown that the explicit numerical scheme that was introduced does not lead to a correct problem solution no matter the choice of number of time steps and nodes. In fact, we have discussed the idea that these are actually mutually dependent and provided a tip regarding the origin of the Courant number $\alpha$. In order to ensure the stability of this explicit scheme, we apply the Courant–Friedrichs–Lewy (CFL) condition which states that:

$$
\alpha = c \frac{\tau}{\delta} \le \alpha_{crit}
$$

Here the value of $\alpha_{crit}$ changes with the integration method. Before proceeding with the numerical analysis, let's start again with some numerical experimentation. To do so we will conceive a few methods for automating multiple solutions of linear advection equation with different discretization levels. The idea is to have the possibility to solve a Courant number constrained problem as well as a free discretization. The first step is to conceive a method `compute_cfl` which will discretize space as provided by the user, then compute time step in a CFL-constrained way it the number to time steps is not provided, or simply discretize time with a user-defined number of steps.

```{code-cell}
function compute_cfl(T, L, c, nₓ, nₜ)
    δ = L / (nₓ - 1);
    x = collect(0.0u"m":δ:L);
    
    if !isnothing(nₜ)
        τ = T / (nₜ - 1)
        α = c * τ / δ
    else
        τ = δ / c
        nₜ = convert(Int, floor(T / τ)) + 1
        α  = 1.0
    end
    
    return α, nₜ, τ, x
end
```

Below we test the method with the inputs inherited from previous examples. The underscore in front of returned values is a reminder that these parameters are to be discarded in what follows.

```{code-cell}
_α, _nₜ, _τ, _x = compute_cfl(T, L, c, nₓ, nₜ)
_α, _nₜ, _τ
```

If the number of time steps is not provided with a `nothing` instead of an integer, the method performs the CFL-constrained discretization a wished.

```{code-cell}
_α, _nₜ, _τ, _x = compute_cfl(T, L, c, nₓ, nothing);
_α, _nₜ, _τ
```

Now we put together everything we learned about the solution of advection equation in a single method `linear_advection_explicit` which will ingest our space and time domain, fluid velocity, wave parameters, and discretization, to then output the solution with respective space and time axes.

```{code-cell}
function linear_advection_explicit(T, L, c, xᵤ, u₀, nₓ, nₜ)
    # Compute time-stepping parameters as required.
    α, nₜ, τ, x = compute_cfl(T, L, c, nₓ, nₜ);
    
    # Create time points iterator (no need to collect).
    t = 0u"s":τ:(nₜ-1)*τ;
    
    # Create wave compatible with space discretization.
    mask = ((xᵤ[1] .< x) .& (x .< xᵤ[2]));
    u = u₀ * ones(Float64, (length(x), 1));
    u[.~mask] .= 0.5 .* u₀;
    
    # Allocate memory for solution.
    solution = 0u"m/s" * zeros(Float64, (nₜ, nₓ));
    
    # Time integration loop.
    for (k, _) in enumerate(t)
        solution[k, :] = copy(u);
        u[2:end] = (1 - α) * u[2:end] + α * u[1:end-1];
    end
    
    return x, collect(t), solution, α
end
```

Before going further we test it is working as expected.

```{code-cell}
x, t, solution = linear_advection_explicit(T, L, c, xᵤ, u₀, nₓ, nₜ);
kymograph_advection(solution)
```

To perform an automated numerical experiment we put it all together in `scan_advection`. This method will receive everything to setup the problem as provided above, but instead of a single space discretization, it takes a range of number of nodes. This way it will be able to show us the role of nodal length over the accuracy of the solution. It also takes an optional number of time steps, which will be useful for testing the CFL-bounded integration.

```{code-cell}
function scan_advection(T, L, c, xᵤ, u₀, min_nₓ, max_nₓ, dnₓ;
                        nₜ=nothing, boundy=true)
    p = plot();
    
    for (k, nₓ) in enumerate(min_nₓ:dnₓ:max_nₓ)
        x, t, solution, α = linear_advection_explicit(T, L, c, xᵤ, u₀, nₓ, nₜ);
        uₖ = ustrip(solution[end, :]);
        
        sα = @sprintf("%.2f", α);
        st = @sprintf("%.2f", ustrip(t[end]));
        label = "nₓ = $(nₓ) / α = $(sα) / T = $(st)";
        plot!(p, x, uₖ, label=label, linewidth=2);
    end

    # Get initial state from the fine-grid solution.
    uᵢ = ustrip(solution[1, :]);
    plot!(p, x, uᵢ, label="Initial state", linewidth=2);
    
    xlabel!(p, "Coordinate, \$\\mathrm{m}\$");
    ylabel!(p, "Velocity, \$\\mathrm{m.s^{-1}}\$");
    
    if boundy
        ylims!(p, 0.5, 1.0);
    end

    return p;
end
```

The following examples were integrated for a shorter physical time to allow faster and didactic computations when scanning over different number of nodes in space domain.

```{code-cell}
T = 0.66u"s";
```

Now we discretize the spacial axis with different number of nodes in the range $[40;70]$. As you may observe in the figure below, numerical diffusion decreases for larger $n_x$, as it was expected from previous discussion. The number of time points is held constant here and equal to 24. Solution seems to better preserve wave shape when $\alpha$ approaches unity.

```{code-cell}
scan_advection(T, L, c, xᵤ, u₀, 40, 70, 15; nₜ=24)
```

Next we increase the upper limit of the number of space nodes $n_x$ to 85, while keeping $n_t$ as before. Apparently the solution *exploses*. If we check the value of $\alpha$, for 85 nodes it has reached 1.21.

```{code-cell}
scan_advection(T, L, c, xᵤ, u₀, 40, 85, 15; nₜ=24, boundy=false)
```

Following the observations made on the first trial, we can increase $n_t$ to force $\alpha\le1$. Apparently we identified *empirically* the critical value of CFL for this problem integration method. What happens if you further increase $n_t$, and why does it happen?

```{code-cell}
scan_advection(T, L, c, xᵤ, u₀, 40, 85, 15; nₜ=29)
```

---

## A (not so) formal stability analysis

One important question that arrises when solving PDE's numerically is whether the system is *stable*, *i.e.* if the numerical solution remains bounded as time-step goes to zero. That means that perturbations such as the rounding error do not increase in time. There are no general methods for perform such analysis and one gets restricted to linear problems. The standard method for this was proposed by John von Neumann, who proposes to use Fourier series to represent the rounding error. Notice that this implies periodic boundary conditions, otherwise these need to be artificially introducted to the problem in order to be tractable.

Suppose the numerical scheme used for integration can be represented by a nonlinear operator $\mathcal{J}$, allowing for the progression in time as:

$$
u^{n+1}=\mathcal{J}[u^{n}]
$$

This operator will produce a sequence of values $u(t_{n})=\{u^0,u^1,u^2,...,u^n\}$ Since the numerical scheme is only an approximation, each step introduces a small cummulative error such that this sequence is in fact $\{u^0+\varepsilon^0,u^1+\varepsilon^1,u^2+\varepsilon^2,...,u^n+\varepsilon^n\}$, what can be represented by:

$$
u^{n+1}+\varepsilon^{n+1}=\mathcal{J}(u^{n}+\varepsilon^{n})
$$

Assuming the Taylor series expansion of $\mathcal{J}$ is possible, after linearization we can express the amplification of the error as the next expression, known as the *error propagation law*. Matrix $G$ is called the *amplification matrix*. We promptly identify that this is an eigenvalue problem.

$$
\varepsilon^{n+1}=\frac{\partial{}\mathcal{J}(u^{n})}{\partial{}u^{n}}\varepsilon^{n}=G\varepsilon^{n}
$$

The numerical stability of the system depends on the eigenvalues $g_{\mu}$ of $G$. In order that the error remains bounded, the following condition is required for stability:

$$
\vert{}g_{\mu}\vert\le{}1\qquad\forall\mu
$$

In general the solution of a PDE will be represented by $u(t_{n},x_{p})\equiv{}u^{n}_{p}$ (notice the change of the subscript used for position here to avoid confusion with the imaginary unit $i$ and the wave-number $k$ that will be used later). The error propagation at one node $p$ is coupled to every other node $q$ by means of the Jacobian matrix element $G_{pq}$, what is expressed by:

$$
\varepsilon^{n+1}_{p}=\sum_{q}G_{pq}\varepsilon^{n}_{q}
\qquad\text{where}\qquad
G_{pq}=\frac{\partial{}\mathcal{J}(u^{n}_{p})}{\partial{}u^{n}_{q}}
$$

The error $\varepsilon^{n}_{p}$ can be expanded as a Fourier series of wavenumbes $k$ over the problem domain. Since the cummulative error must decay or grow exponentially in time, we can assume that the Fourier coefficients $\hat{\varepsilon}^{n}(k)$ vary as $\exp{(\omega{}t_{n})}$, where the frequency $\omega$ is a constant.

$$
\varepsilon^{n}_{p}=\sum_{k}\hat{\varepsilon}^{n}(k)\exp{(ikx_{p})}=\sum_{k}\exp{(\omega{}t_{n})}\exp{(ikx_{p})}
$$

It is important to notice that the functions $\exp{(ikx_{p})}$ are eigenfunctions of $G$, so the last expression can be interpreted as an expansion of eigenfunctions og $G$. Furthermore, since the equation for the error is linear, it is enough to study the growth of an arbitrary element in the sum, such as $\varepsilon^{n}_{p}=\exp{(\omega{}t_{n})}\exp{(ikx_{p})}
$. From this we have:

$$
\varepsilon^{n+1}_{p}=g(k)\varepsilon^{n}_{p}
$$

As such, one can take the $\exp{(ikx_{p})}$ as an eigenvector corresponding to eigenvalue $g(k)$, which is known as the amplification factor. The *von Neumann stability criterium* is then:

$$
\vert{}g(k)\vert\le{}1\qquad\forall{}k
$$



### Application to 1-D convection

To start with, at an arbitrary point $p$ in the grid we inject the corresponding error propagation term $\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}$ at the correct time instant. Notice here that we made $x_{p}=p\Delta{}x$ for allowing proper manipulation in what follows. Using the *upwind explicit* scheme we are dealing with one produces:

$$
\hat{\varepsilon}^{n+1}(k)\exp{(ikp\Delta{}x)}=
\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}-
\alpha\left[
    \hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}-
    \hat{\varepsilon}^{n}(k)\exp{(ik(p-1)\Delta{}x)}
\right]
$$

The error amplification factor $g(k)$ can then be identified by simultaneously dividing the previous expression by $\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}$. Notice that this expression is independent of the position $p$ and thus remains valid for the whole domain.

$$
g(k)=\frac{\hat{\varepsilon}^{n+1}(k)}{\hat{\varepsilon}^{n}(k)}=
1-\alpha+\alpha\exp{(-ik\Delta{}x)}
$$

In order to respect von Neumann stability condition for all $k$ we need $1-\alpha\le{}0$, what provides the value of $\alpha_{crit}=1$ that we previously identified through our numerical experiments. Thus, we say the *upwind explicit* scheme for 1-D convection is *conditionally stable*, *i.e* the physical velocity *c* must not be bigger than the numerical *spreading velocity* $\frac{\Delta{}x}{\Delta{}t}$.



By not providing the number of time steps in our scanning model forces CFL criterium to be respected for all number of nodes in space, as expected from the previous analysis. In this case, we cannot ensure that the time step required to respect CFL will produce an integer number of steps to reach exactly the time position we wish the calculation to terminate at. In another moment we will deal with this.

```{code-cell}
scan_advection(T, L, c, xᵤ, u₀, 40, 85, 15)
```

---





## Courant-Friedrichs-Lewy criterium

The previous examples and proposed exercises have shown that the explicit
numerical scheme that was introduced does not lead to a correct problem solution
no matter the choice of number of time steps and nodes. In fact, we have
discussed the idea that these are actually mutually dependent and provided a tip
regarding the origin of the Courant number $\alpha$. In order to ensure the
stability of this explicit scheme, we apply the Courant–Friedrichs–Lewy (CFL)
condition which states that:

```
\alpha = c \frac{\tau}{\delta} \le \alpha_{crit}
```

Here the value of $\alpha_{crit}$ changes with the integration method. Before
proceeding with the numerical analysis, let's start again with some numerical
experimentation. To do so we will conceive a few methods for automating multiple
solutions of linear advection equation with different discretization levels. The
idea is to have the possibility to solve a Courant number constrained problem as
well as a free discretization. The first step is to conceive a method
`compute_cfl` which will discretize space as provided by the user, then compute
time step in a CFL-constrained way it the number to time steps is not provided,
or simply discretize time with a user-defined number of steps.

Below we test the method with the inputs inherited from previous examples. The
underscore in front of returned values is a reminder that these parameters are
to be discarded in what follows.

If the number of time steps is not provided with a `nothing` instead of an
integer, the method performs the CFL-constrained discretization a wished.

Now we put together everything we learned about the solution of advection
equation in a single method `linear_advection_explicit` which will ingest our
space and time domain, fluid velocity, wave parameters, and discretization, to
then output the solution with respective space and time axes.

Before going further we test it is working as expected.

To perform an automated numerical experiment we put it all together in
`scan_advection`. This method will receive everything to setup the problem as
provided above, but instead of a single space discretization, it takes a range
of number of nodes. This way it will be able to show us the role of nodal length
over the accuracy of the solution. It also takes an optional number of time
steps, which will be useful for testing the CFL-bounded integration.

The following examples were integrated for a shorter physical time to allow
faster and didactic computations when scanning over different number of nodes in
space domain.

Now we discretize the spacial axis with different number of nodes in the range
$[40;70]$. As you may observe in the figure below, numerical diffusion decreases
for larger $n_x$, as it was expected from previous discussion. The number of
time points is held constant here and equal to 24. Solution seems to better
preserve wave shape when $\alpha$ approaches unity.

Next we increase the upper limit of the number of space nodes $n_x$ to 85, while
keeping $n_t$ as before. Apparently the solution *exploses*. If we check the
value of $\alpha$, for 85 nodes it has reached 1.21.

Following the observations made on the first trial, we can increase $n_t$ to
force $\alpha\le1$. Apparently we identified *empirically* the critical value of
CFL for this problem integration method. What happens if you further increase
$n_t$, and why does it happen?

## A (not so) formal stability analysis

One important question that arrises when solving PDE's numerically is whether
the system is *stable*, *i.e.* if the numerical solution remains bounded as
time-step goes to zero. That means that perturbations such as the rounding error
do not increase in time. There are no general methods for perform such analysis
and one gets restricted to linear problems. The standard method for this was
proposed by John von Neumann, who proposes to use Fourier series to represent
the rounding error. Notice that this implies periodic boundary conditions,
otherwise these need to be artificially introducted to the problem in order to
be tractable.

Suppose the numerical scheme used for integration can be represented by a
nonlinear operator $\mathcal{J}$, allowing for the progression in time as:

```
u^{n+1}=\mathcal{J}[u^{n}]
```

This operator will produce a sequence of values
$u(t_{n})=\{u^0,u^1,u^2,...,u^n\}$ Since the numerical scheme is only an
approximation, each step introduces a small cummulative error such that this
sequence is in fact
$\{u^0+\varepsilon^0,u^1+\varepsilon^1,u^2+\varepsilon^2,...,u^n+\varepsilon^n\}$,
what can be represented by:

```
u^{n+1}+\varepsilon^{n+1}=\mathcal{J}(u^{n}+\varepsilon^{n})
```

Assuming the Taylor series expansion of $\mathcal{J}$ is possible, after
linearization we can express the amplification of the error as the next
expression, known as the *error propagation law*. Matrix $G$ is called the
*amplification matrix*. We promptly identify that this is an eigenvalue problem.

```
\varepsilon^{n+1}=\frac{\partial{}\mathcal{J}(u^{n})}{\partial{}u^{n}}\varepsilon^{n}=G\varepsilon^{n}
```

The numerical stability of the system depends on the eigenvalues $g_{\mu}$ of
$G$. In order that the error remains bounded, the following condition is
required for stability:

```
\vert{}g_{\mu}\vert\le{}1\qquad\forall\mu
```

In general the solution of a PDE will be represented by
$u(t_{n},x_{p})\equiv{}u^{n}_{p}$ (notice the change of the subscript used for
position here to avoid confusion with the imaginary unit $i$ and the wave-number
$k$ that will be used later). The error propagation at one node $p$ is coupled
to every other node $q$ by means of the Jacobian matrix element $G_{pq}$, what
is expressed by:

```
\varepsilon^{n+1}_{p}=\sum_{q}G_{pq}\varepsilon^{n}_{q}
\qquad\text{where}\qquad
G_{pq}=\frac{\partial{}\mathcal{J}(u^{n}_{p})}{\partial{}u^{n}_{q}}
```

The error $\varepsilon^{n}_{p}$ can be expanded as a Fourier series of
wavenumbes $k$ over the problem domain. Since the cummulative error must decay
or grow exponentially in time, we can assume that the Fourier coefficients
$\hat{\varepsilon}^{n}(k)$ vary as $\exp{(\omega{}t_{n})}$, where the frequency
$\omega$ is a constant.

```
\varepsilon^{n}_{p}=\sum_{k}\hat{\varepsilon}^{n}(k)\exp{(ikx_{p})}=\sum_{k}\exp{(\omega{}t_{n})}\exp{(ikx_{p})}
```

It is important to notice that the functions $\exp{(ikx_{p})}$ are
eigenfunctions of $G$, so the last expression can be interpreted as an expansion
of eigenfunctions og $G$. Furthermore, since the equation for the error is
linear, it is enough to study the growth of an arbitrary element in the sum,
such as $\varepsilon^{n}_{p}=\exp{(\omega{}t_{n})}\exp{(ikx_{p})} $. From this
we have:

```
\varepsilon^{n+1}_{p}=g(k)\varepsilon^{n}_{p}
```

As such, one can take the $\exp{(ikx_{p})}$ as an eigenvector corresponding to
eigenvalue $g(k)$, which is known as the amplification factor. The *von Neumann
stability criterium* is then:

```
\vert{}g(k)\vert\le{}1\qquad\forall{}k
```

### Application to 1-D convection

To start with, at an arbitrary point $p$ in the grid we inject the corresponding
error propagation term $\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}$ at the
correct time instant. Notice here that we made $x_{p}=p\Delta{}x$ for allowing
proper manipulation in what follows. Using the *upwind explicit* scheme we are
dealing with one produces:

```
\hat{\varepsilon}^{n+1}(k)\exp{(ikp\Delta{}x)}=
\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}-
\alpha\left[
    \hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}-
    \hat{\varepsilon}^{n}(k)\exp{(ik(p-1)\Delta{}x)}
\right]
```

The error amplification factor $g(k)$ can then be identified by simultaneously
dividing the previous expression by
$\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}$. Notice that this expression is
independent of the position $p$ and thus remains valid for the whole domain.

```
g(k)=\frac{\hat{\varepsilon}^{n+1}(k)}{\hat{\varepsilon}^{n}(k)}=
1-\alpha+\alpha\exp{(-ik\Delta{}x)}
```

In order to respect von Neumann stability condition for all $k$ we need
$1-\alpha\le{}0$, what provides the value of $\alpha_{crit}=1$ that we
previously identified through our numerical experiments. Thus, we say the
*upwind explicit* scheme for 1-D convection is *conditionally stable*, *i.e* the
physical velocity *c* must not be bigger than the numerical *spreading velocity*
$\frac{\Delta{}x}{\Delta{}t}$.

By not providing the number of time steps in our scanning model forces CFL
criterium to be respected for all number of nodes in space, as expected from the
previous analysis. In this case, we cannot ensure that the time step required to
respect CFL will produce an integer number of steps to reach exactly the time
position we wish the calculation to terminate at. In another moment we will deal
with this.
