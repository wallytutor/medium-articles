# Diffusion in 1-D with finite difference method

```{code-cell}
using Plots;
# using Printf;
# using Unitful;
```

```{code-cell}

```

```{code-cell}

```

```{code-cell}

```

```{code-cell}

```

# Introduction to diffusion (Part A)


## Diffusion equation 1-D with finite differences

Diffusion is a process that arises when a flow of a given quantity is induced by a gradient of its content, what is a direct response to second law of Thermodynamics. Under such circunstances, we often denote the flux vector $\vec{J}$ of quantity $u$ as given in the following equation, where $\nu$ is a transport coefficient. This empirical relationship has been shown to hold under several cases, constituting what is called *Fourier's law* in heat transfer and *Fick's first law* in mass transfer.

$$
    \vec{J}=-\nu{}\nabla{}u
$$

In this notebook we introduce the 1-D case of diffusion equation, thus the gradient is replaced by the derivative of $u$ over $x$ axis. To compute the time evolution of $u$ in a point of space in the absence of a source term, one simply aply the divergent operator (special case of Reynolds transport theorem without source) over the flux above which can be interpreted as

<center>
<bold>[ Inlet ] - [ Outlet ] + [ Creation == 0 ] = [ Accumulation rate ]</bold>
</center>

Applying this to the case where the creation rate is null (no source term) is equivalent to take the divergent of the flux. In the case the transport coefficient depends on position or in the transported quantity itself, this leads to the following nonlinear form of the diffusion equation, which we will study later in this notebook series:

$$
    \frac{\partial u}{\partial t}=\frac{\partial{}}{\partial{}x}\left[\nu(x, u)\frac{\partial{}u}{\partial{}x}\right]
$$

For the case of constant transport coefficient $\nu$, we finally get the expression that we study here:

$$
    \frac{\partial u}{\partial t}= \nu \frac{\partial^2{}u}{\partial{}x^2}
$$


### Second derivative computation

A second derivative of a function requires more information than the first one, since it represents the rate of change of a derivative. As a first strategy to compute the right-hand side of diffusion equation, let's take the Taylor series expansion of function $u$ around a given element $u_{i}$. We use this to produce both the next and previous elements in 1-D space, $u_{i+1}$ and $u_{i-1}$

$$
    u_{i+1} = u_i + \Delta x \frac{\partial u}{\partial x}\bigg|_i + \frac{\Delta x^2}{2} \frac{\partial ^2 u}{\partial x^2}\bigg|_i + \frac{\Delta x^3}{3!} \frac{\partial ^3 u}{\partial x^3}\bigg|_i + O(\Delta x^4)
$$

$$
    u_{i-1} = u_i - \Delta x \frac{\partial u}{\partial x}\bigg|_i + \frac{\Delta x^2}{2} \frac{\partial ^2 u}{\partial x^2}\bigg|_i - \frac{\Delta x^3}{3!} \frac{\partial ^3 u}{\partial x^3}\bigg|_i + O(\Delta x^4)
$$

As you may notice in the equations above, the sign of odd terms cancel. Adding up these expressions is a straighforward means of getting only even terms in the series, thus the second derivative.

$$
    u_{i+1} + u_{i-1} = 2u_i+\Delta x^2 \frac{\partial ^2 u}{\partial x^2}\bigg|_i + O(\Delta x^4)
$$

After manipulation for isolating the second derivative one produces the second order accurate scheme:

$$
    \frac{\partial ^2 u_{i}}{\partial x^2}=\frac{u_{i+1}-2u_{i}+u_{i-1}}{\Delta x^2} + O(\Delta x^2)
$$

### Explicit formulation

In the previous notebooks we have established the convention of using a superscript to denote the discrete time index. Computing the right-hand side of the diffusion equation at instant $n$ to predict $n+1$ produces the *explicit* formulation. For brevity we start using $\tau=\Delta{}t$ and $\delta=\Delta{}x$.

$$
    \frac{u_{i}^{n+1}-u_{i}^{n}}{\tau}=\nu\frac{u_{i+1}^{n}-2u_{i}^{n}+u_{i-1}^{n}}{\delta^2}
$$

Again, as we have done for the convection equation, $u^{n+1}$ can be promptly solved from $u^{n}$ at all positions:

$$
    u_{i}^{n+1}=u_{i}^{n}+\frac{\nu\tau}{\delta^2}(u_{i+1}^{n}-2u_{i}^{n}+u_{i-1}^{n})=
    (1-2\alpha)u_{i}^{n}+\alpha(u_{i+1}^{n}+u_{i-1}^{n})
    \qquad\text{where}\qquad{}\alpha=\frac{\nu{}\tau{}}{\delta^2}
$$

### Stability analysis

As we have seen in last notebook, the stability criterium for a formulation can be established through von Neumann analysis. To do so, we make use of the error scaling factors $\hat{\varepsilon}^{n}(k)\exp{(ikp\Delta{}x)}$ as a replacement of every $u$ in the above equation. Remember that for compatibility with imaginary unity, subindices were replaced by $p$ here, and the good value of $p$ must be used for each term. After manipulation we retrieve the amplification factor $g(k)$ that is independent of the position (try doing the full demonstration):

$$
g(k)=(1-2\alpha) + \alpha[\exp(ik\delta)+\exp(-ik\delta)]
$$

The right-hand side can be simplified through Euler's formula $\exp(\pm{}ix)=\cos(x)\pm{}i\sin(x)$. This leads to elimination of the sinuses from the equation, which now can be simplified as:

$$
g(k)=1+2\alpha\left[\cos(ik\delta)-1\right]
$$

Stability is assured when $\vert{}g(k)\vert\le{}1$ for any $k$. It can be shown (it is left for the reader to demonstrate), that this is possible for $\alpha\le\frac{1}{2}$. From now on we consider the derived criterium for the coding activities.

### Sample case

As we did when studying convection for the first time, our sample case will be started witn a hump in the middle of the domain, as per the statement below. The most important difference that is emphasized from now on is that since we are aware of stability criterium, time-step will be chosen to respect it. The code is provided with a flag for override the bounding of time-step allowing to investigate the effect of unstable regions of $\alpha$. In all cases, unity diffusion coefficient $\nu=1$ will be employed for simplicity.

$$
\begin{cases}
u=1 & x\in[0.75;\, 1.25]\\
u=0 & \text{elsewhere}
\end{cases}
$$

The next function provides the integration of the problem with the previously defined numerical scheme using NumPy array slicing to allow the computation of derivative in all internal domain elements. Notice that until the present we have not yet discussed boundary conditions and the next example is equivalent to a constant value over boundaries (Dirichlet condition, as we will see later in the series).


```python
def problem_diffusion_linear(u, dx, t_end, alpha_max):
    """ Explicit solution of 1-D diffusion problem.
    
    Parameters
    ----------
    u : np.ndarray
        Array quantity over 1-D grid of step `dx`.
    dx : float
        Grid spacing in 1-D domain.
    t_end : float
        Final integration time.
    alpha_max : float
        Value of alpha for initial time-step calculation.
        
    Returns
    -------
    np.ndarray
        Solution array with quantity `u` at `t_end`.
    """
    # Constant diffusion coefficient.
    nu = 1.0
    
    # Compute dx**2 only once.
    dx2 = dx ** 2

    # Maximum stable time-step.
    dt = alpha_max * dx2 / nu
    
    # Initialize time.
    t = 0.0

    # Time loop until end.
    while t < t_end:
        # Bound time step for ending.
        dt = min(dt, t_end - t)
        
        # Increase solution time.
        t += dt 

        # Compute explicity solution
        alpha = nu * dt / dx2
        u[1:-1] += alpha * (u[2:] - 2.0 * u[1:-1] + u[:-2])
        
        if abs(t - t_end) <= 1.0e-08:
            return u
```

For allowing multiple calculations with same initial condition but different grids, we provide a simple function for allocation and computation of initial conditions and space discretization. This function will be used as a parameter of our simulation study, so different cases can be investigated.


```python
def get_initial_conditions_sample1(nx):
    """ Allocate x, u, and set initial state. """
    x, dx = np.linspace(0.0, 2.0, nx, retstep=True)
    u = np.zeros(nx, dtype=np.float64)
    u[((x >= 0.75) & (x <= 1.25))] = 1.0
    return x, u, dx
```

Finally we wrap the problem in a function to study the effect of alpha and integration time for a given fixed set of number of nodes in space. This function creates a plot of initial state and results for reference.


```python
def simulate_for_alpha(alpha, initialize, t_end=1.0e-03, bound_alpha=True):
    """ Simulate problem for a given `alpha`.
    
    Parameters
    ----------
    alpha : float
        Critical value of `alpha` to use in calculation.
    t_end : float
        Final integration time for studying effect of boundaries.
    bound_alpha : bool
        If `True`, ensure stability criterium.
    """
    plt.close('all')
    plt.style.use('bmh')
    plt.figure(figsize=(8, 4), dpi=100)

    if bound_alpha:
        alpha = min(alpha, 0.5)
    
    x, u, _ = initialize(5000)
    plt.plot(x, u, drawstyle='steps', label=F'Initial')

    t0 = perf_counter()
    for nx in [20, 200, 2000]:
        x, u, dx = initialize(nx)
        u = problem_diffusion_linear(u, dx, t_end, alpha)
        plt.plot(x, u, drawstyle='steps', label=F'nx={nx}')

    delay = perf_counter() - t0
    title = F'All simulations took {delay:.2f} s'
    
    plt.title(title)
    plt.xlabel('Position [m]')
    plt.ylabel('Quantity [a.u.]')
    plt.xlim(0.0, 2.0)
    plt.legend()}
    plt.tight_layout()
```

In the next cell we present the solution for the critical value of alpha that has been found in *von Neumann* stability analysis.


```python
simulate_for_alpha(0.5, get_initial_conditions_sample1)
```

As you observe in the plot above, with 2000 nodes in grid a pretty smooth solution starts to be produced with the given conditions. For 20 nodes, the problem is not even centered because of the placement of initial state in that case.

The next cells are an invitation for you to experiment with different parameters in the simulation. Take care with `t_end` as it can be pretty long to compute the solution with 2000 nodes in the grid.


```python
# simulate_for_alpha(1.0, get_initial_conditions_sample1, bound_alpha=False)
```


```python
# simulate_for_alpha(0.5, get_initial_conditions_sample1, t_end=1.0e-01)
```

What if we have multiple humps (see them as particles being dissolved) in the system? Well, check below! This is a pretty common application case of diffusion in solid state and stationary liquids that is worth understanding.


```python
def get_initial_conditions_sample2(nx):
    """ Allocate x, u, and set initial state. """
    x, dx = np.linspace(0.0, 2.0, nx, retstep=True)
    u = np.zeros(nx, dtype=np.float64)
    u[((x >= 0.20) & (x <= 0.40))] = 2.0
    u[((x >= 0.70) & (x <= 1.00))] = 1.0
    u[((x >= 1.50) & (x <= 1.60))] = 3.0
    return x, u, dx
```


```python
simulate_for_alpha(0.5, get_initial_conditions_sample2, t_end=5.0e-03)
```

+++

# Introduction to diffusion (Part B)

## Introduction to implicit formulations

Contrary to the *explicit* formulation, in the *implicit* case we compute the spacial derivatives in instant $n+1$. In this case simple algebraic solution is no longer possible, as we show in what follows. Replacing $n$ by $n+1$ in the superscripts on the right-hand side of the *explicit* formulation produces the *implicit* scheme. In fact, any of the previous models could have been treated this way. The main advantage of *implicit* schemes is the stability, as it will be shown later.

$$
    \frac{u_{i}^{n+1}-u_{i}^{n}}{\tau}=\nu\frac{u_{i+1}^{n+1}-2u_{i}^{n+1}+u_{i-1}^{n+1}}{\delta^2}
$$
 
After manipulating the above expression to split the different instants at different sides of the equation we produce the next expression. Observe the linear coupling of different elements at $n+1$: *we have a linear system of equations instead of single algebraic equations* and the solution of the system is required for advancing the integration in time.

$$
-\alpha{}u_{i-1}^{n+1} + (1 + 2\alpha) u_{i}^{n+1} - \alpha{}u_{i+1}^{n+1}=u_{i}^{n}
\qquad\text{where}\qquad{}\alpha=\frac{\nu{}\tau{}}{\delta^2}
$$

This expression holds for all elements in the interior of 1-D space. Boundary elements deserve special treatment as we will see in what follows (*e.g.* at position $i=0$, does index $i-1=-1$ make sense? You are outside the domain!). In matrix form the above equation produces the following tridiagonal linear system (boundary terms not yet implemented):

$$
\begin{bmatrix}~1+2\alpha& -\alpha& ~0& ~0& ~0& \ldots &~0\\[2pt] -\alpha&~1+2\alpha&-\alpha&~0&~0&\ldots &~0\\[2pt] ~0&-\alpha&~1+2\alpha&-\alpha&~0&\ldots &~0\\[2pt] \vdots &\vdots &\vdots &\vdots &\vdots &\ddots &\vdots \\[2pt] ~0&\ldots &~0&-\alpha&~1+2\alpha&-\alpha&~0\\[2pt] ~0&\ldots &\ldots &~0&-\alpha&~1+2\alpha&-\alpha\\[2pt] ~0&\ldots &\ldots &\ldots &~0&-\alpha&~1+2\alpha\end{bmatrix}\cdotp\begin{bmatrix}u^{n+1}_{0}   \\[2pt]u^{n+1}_{1}   \\[2pt] u^{n+1}_{2}   \\[2pt] \vdots        \\[2pt]
u^{n+1}_{N-3} \\[2pt] u^{n+1}_{N-2} \\[2pt] u^{n+1}_{N-1} \\[2pt] \end{bmatrix} = \begin{bmatrix} u^{n}_{0}   \\[2pt] u^{n}_{1}   \\[2pt] u^{n}_{2}   \\[2pt] \vdots      \\[2pt] u^{n}_{N-3} \\[2pt] u^{n}_{N-2} \\[2pt] u^{n}_{N-1} \\[2pt]\end{bmatrix}
$$

So finally we have that the solution of the implicit formulation using matrix boldface notation can be done as follows:

$$
    \mathbf{M}\cdotp\mathbf{u}^{n+1}=\mathbf{u}^{n}\implies{}
    \mathbf{u}^{n+1}=\mathbf{M}^ {-1}\mathbf{u}^{n}
$$

### Stability analysis

Following the same steps from Part A of this chapter, *i.e.* replacing each $u^{m}_{p}=\hat{\varepsilon}^{m}(k)\exp{(ikp\Delta{}x)}$ with proper $m$ and $p$ replacement, we find the error amplification factor $g(k)$, which for the *implicit* scheme takes the form:

$$
    g(k)=\frac{1}{1-2\alpha\left[cos(k\Delta{}x)-1\right]}=
    \frac{1}{1+4\alpha\sin^{2}(k\Delta{}x)}
$$

The value of $\sin^{2}(k\Delta{}x)\ge{}0\implies{}\vert{}g(x)\vert\le{}1$, what implies that the *implicit scheme is unconditionally stable*, meaning that any combination of time and space steps will lead to a finite error. Nonetheless, this does not mean the values are accurate, since the truncation error is the same as the explicit scheme, leading to a first-order accuracy in $x$.

### Boundary conditions
 
We have delayed the derivation of boundary conditions to this point. This is because now we have already seen different equations and the difference of *explicit* and *implicit* schemes. Now we concentrate of how to ensure the PDE boundary conditions as required by a real-world problem. For an *explicit* scheme this can be as trivial as not solving the equation for the first and last element to keep them constant, what would constitue a Dirichlet boundary condition. For *implicit* schemes, the derivation is far more complex, and include modifications in the coefficient matrix $\mathbf{M}$ and to the right-hand side.

**Dirichlet:** this type of boundary condition is characterized by the time-constancy of the boundary node, using dot notation for time-derivative $\dot{u}\vert_{x=0}=0\:\forall{}t\in{}\Re$. That means that the left hand side of diffusion equation is to be held constant at that position. In order to derive this condition, one may write the first equation of the system as follows, where index $i=-1$ is a *ghost* node, a purely numerical feature used to help the derivation of the boundary condition.

$$
    -\alpha{}u^{n+1}_{-1}+(1+2\alpha)u^{n+1}_{0}-\alpha{}u^{n+1}_{1}=u^{n}_{0}
$$

Holding this *ghost* node constant and equal to the boundary value $u_{b}$, the first equation of the problem is then writen as $(1+2\alpha)u^{n+1}_{0}-\alpha{}u^{n+1}_{1}=u^{n}_{0}+\alpha{}u_{b}$. As such, the matrix form of the problem is modified to $\mathbf{u}^{n+1}=\mathbf{M}^ {-1}\left(\mathbf{u}^{n}+\mathbf{u}_{b}\right)$.

**Neumann:** also known as the specified flux condition, is given by $\nu{}u^{\prime}\vert_{x=0}=h$, where we use a prime notation for derivatives in space. We seek now a *ghost* element ensuring the respect of the flux over $u_{0}$. One alternative is to take a centered derivative around this node to represent the boundary condition.

$$
    \nu\frac{u_{1}-u_{-1}}{2\delta}=h\qquad\implies\qquad{}
    u_{-1}=u_{1}+\frac{2\delta{}h}{\nu}
$$

Using this expression in the generic form of the numerical scheme provides us with the first row of our matrix. Notice here that for Neumann boundary condition not only a term is added to the right-hand side of the problem, but also modified one matrix element associated to $u_{1}$.

$$
    (1+2\alpha)u^{n+1}_{0}-2\alpha{}u^{n+1}_{1}=u^{n}_{0}+2\alpha\delta{}h\nu^{-1}
$$

Following we visualize the full final matrix form for this boundary condition.

$$
\begin{bmatrix}
~1+2\alpha& -2\alpha& ~0& ~0& ~0& \ldots &~0\\[2pt] 
-\alpha&~1+2\alpha&-\alpha&~0&~0&\ldots &~0\\[2pt]
~0&-\alpha&~1+2\alpha&-\alpha&~0&\ldots &~0\\[2pt] 
\vdots &\vdots &\vdots &\vdots &\vdots &\ddots &\vdots \\[2pt] 
~0&\ldots &~0&-\alpha&~1+2\alpha&-\alpha&~0\\[2pt]
~0&\ldots &\ldots &~0&-\alpha&~1+2\alpha&-\alpha\\[2pt] 
~0&\ldots &\ldots &\ldots &~0&-2\alpha&~1+2\alpha
\end{bmatrix}\cdotp
\begin{bmatrix}
u^{n+1}_{0}   \\[2pt]
u^{n+1}_{1}   \\[2pt]
u^{n+1}_{2}   \\[2pt]
\vdots        \\[2pt]
u^{n+1}_{N-3} \\[2pt]
u^{n+1}_{N-2} \\[2pt] 
u^{n+1}_{N-1} \\[2pt]
\end{bmatrix} = 
\begin{bmatrix}
u^{n}_{0}   \\[2pt]
u^{n}_{1}   \\[2pt]
u^{n}_{2}   \\[2pt]
\vdots      \\[2pt]
u^{n}_{N-3} \\[2pt]
u^{n}_{N-2} \\[2pt] 
u^{n}_{N-1} \\[2pt]
\end{bmatrix} +
\begin{bmatrix}
2\alpha\delta{}h\nu^{-1} \\[2pt]
0           \\[2pt]
0           \\[2pt]
\vdots      \\[2pt]
0           \\[2pt]
0           \\[2pt] 
2\alpha\delta{}h\nu^{-1}\\[2pt]
\end{bmatrix}
$$

**Fourier:** this third-type represents a generalization of both previous ones. This is why it is the preferred method for implementing generic code dealing with a broaded range of problems. The general form of Fourier boundary condition is given by:

$$
    a{}u + b\frac{\partial{}u}{\partial{}x}=g
$$

$$
    u + \nu\frac{\partial{}u}{\partial{}x}=h
$$



### Thomas solver

### Sample case

$$
\begin{cases}
u=2 & x\in[0,5;\, 1,0]\\
u=1 & \text{elsewhere}
\end{cases}
$$

+++

# Introduction to diffusion (Part C)

## Nonlinear diffusion in 1-D

$$
    \frac{\partial u}{\partial t}=  \frac{\partial{}}{\partial{}x}\left(\nu(u)\frac{\partial{}u}{\partial{}x}\right)
$$

$$
    \frac{\partial u}{\partial t}= \nu(u) \frac{\partial^{2}{}u}{\partial{}x^{2}}+
    \frac{\partial{}\nu(u)}{\partial{}x}\frac{\partial{}u}{\partial{}x}
$$


## Study case

$$
    \frac{\partial u}{\partial t}= u\frac{\partial^{2}{}u}{\partial{}x^{2}}+
    \left(\frac{\partial{}u}{\partial{}x}\right)^2
$$

$$
    D^{\gamma}_{C}=4.84\times{}10^{-5}\exp\left(-\frac{150000}{RT}\right)\exp\left(\frac{570000-320{}T}{RT}x_{C}\right)\frac{1}{1-5x_{C}}
$$

```{code-cell}

```




---
From old report

\section{Introduction}

This sample program has been conceived for didactic purposes of teaching Fick's second law in its linear form (constant diffusion coefficient). In is conceived as a dummy example for asking students to provide the required modifications to reach generality in non-linear form as exercise. Introduction to Finite Volume Method (FVM) is supposed to have already been done in such a way that this tutorial goes directly to the details of the equation discretization. Numerical analysis and stability conditions are not provided.

\section{Equation in Cartesian coordinates}

For a constant density medium, the diffusion of a species is modeled in two steps: \begin{inparaenum}[(i)] \item the constitutive relationship of the flux under a composition (or chemical potential) gradient, and \item the balance provided by a divergent operation.\end{inparaenum} Assuming Fick's first law as the constitutive relationship one can derive the model partial differential equation as provided in \eqref{eq:cartesian-form}, where $C$ gives the concentration of the diffusing species and $x$ and $t$ take the usual spacial and time coordinates convention.

\begin{equation}
\frac{\partial{}C}{\partial{}t}=D\frac{\partial^{2}C}{\partial{}x^{2}}
\label{eq:cartesian-form}
\end{equation}

Before proceeding with the numerical formulation one must establish the convention for spacial discretization so that equations can be written in terms of the node indexing system. Figure~\ref{fig:discretization-scheme} represents a finite volume one-dimensional space of equally sized nodes\footnote{Although we could have worked out the problem for the case of any spacial grid, such as a geometric series expansion of node sizes, this would only impact on the coefficients that will be produced once we discretized the equation and would make the code more difficult to read (implementation would not be much more complex, but certainly more verbose and we would loose the focus on the mathematical formulation).}. In what follows we start by integrating the problem around node $P$ by computing fluxes through edges $w$ and $e$ between $P$ and its neighbors $W$ and $E$.  Boundaries will be discussed later.


\caption{\label{fig:discretization-scheme}Discretization around node $P$ and ghost boundaries. Dashed nodes represent an indefinite number of nodes in the system up to the boundaries.}

A first general step in obtaining a discrete form of the model PDE is to provide spacial and temporal integration over a node. Equation~\eqref{eq:cartesian-form-integral} provide such integration over the domain of node $P$ between the current time and a future instant $t+\delta{}t$. In what follows we assume that time-step $\delta{}t$ is constant but nothing would change in the formulation with a varying time-step, except that problem coefficients would need to be recomputed after each step.

\begin{equation}
\int_{w}^{e}\int_{t}^{t+\delta{}t}\frac{\partial{}C_{P}}{\partial{}t}\mathrm{d}t\mathrm{d}x=\int_{w}^{e}\int_{t}^{t+\delta{}t}D\frac{\partial^{2}C_{P}}{\partial{}x^{2}}\mathrm{d}t\mathrm{d}x
\label{eq:cartesian-form-integral}
\end{equation}

Integration over time of \eqref{eq:cartesian-form-integral} right-hand side is straightforward since it is the integral of a differential of time: we just compute the difference of local concentrations $C_{P}$ between the instants. In \eqref{eq:cartesian-form-first-step} we denote the instant by using parenthesized superscripts. Since the left-hand side of \eqref{eq:cartesian-form-integral} does not depend on time, integration is simply the multiplication of the integrand by time-step $\delta{}t$.

\begin{equation}
\int_{w}^{e}\left[C^{(t+\delta{}t)}_{P}-C^{(t)}_{P}\right]\mathrm{d}x=
\int_{w}^{e}D\frac{\partial^{2}C}{\partial{}x^{2}}\delta{}t\mathrm{d}x
\label{eq:cartesian-form-first-step}
\end{equation}

Spacial integration is then performed in \eqref{eq:cartesian-form-second-step}. Left-hand side is trivial since it is independent of spacial coordinate. For right-hand side we perform the integration of a derivative what corresponds to decreasing its degree by one and computing difference between evaluations of remaining derivatives over the node boundaries $w$ and $e$. Notice here the introduction of superscripts $(m)$ on the right-hand side representing an arbitrary instant. Up to this step we have not select the kind of time-stepping we will apply and thus we leave it there for now.

\begin{equation}
\left[C^{(t+\delta{}t)}_{P}-C^{(t)}_{P}\right]\frac{\delta{}x}{\delta{}t}=
\left(D\frac{\partial{}C}{\partial{}x}\right)^{(m)}_{e}-\left(D\frac{\partial{}C}{\partial{}x}\right)^{(m)}_{w}
\label{eq:cartesian-form-second-step}
\end{equation}

For the evaluation of the resulting fluxes in the right-hand side of \eqref{eq:cartesian-form-second-step} we adopt a first order\footnote{Higher order schemes would not impact the general procedure of deriving the numerical model but would again be more verbose and require more complex solving routines for the linear system that will be derived.} upwind differencing scheme (UDS), in which a derivative at an interface is computed by taking the difference between concentrations in the neighbor nodes in the positive direction of the spacial coordinate\footnote{If using other space discretization scheme, the upwind derivative would need to be pondered by the lengths of the neighbor nodes.}

Following the proposed scheme, derivative on edge $e$ of node $P$ is computed by taking the difference of concentrations between $E$ and $P$, as given by \eqref{eq:difference-east}. Notice here that $E$ is the \emph{next} node after $P$ in increasing $x$ coordinate.

\begin{equation}
\left(D\frac{\partial{}C}{\partial{}x}\right)^{(m)}_{e}=D\frac{C^{(m)}_{E}-C^{(m)}_{P}}{\delta{x}}
\label{eq:difference-east}
\end{equation}

Similarly, for $w$ we take the difference between $P$ and $W$, as given by \eqref{eq:difference-west}. Again notice the upwind ordering of the terms in the difference equation.

\begin{equation}
\left(D\frac{\partial{}C}{\partial{}x}\right)^{(m)}_{w}=D\frac{C^{(m)}_{P}-C^{(m)}_{W}}{\delta{x}}
\label{eq:difference-west}
\end{equation}

Multiplying both sides of \eqref{eq:cartesian-form-second-step} by $\sfrac{\delta{}t}{\delta{}x}$ we see appear on the right-hand side the multiplier given by \eqref{eq:cfl-number}, also known as Courant–Friedrichs–Lewy number, which can be used for studying the numerical stability of the system.

\begin{equation}
\beta=D\frac{\delta{t}}{\delta{}x^{2}}
\label{eq:cfl-number}
\end{equation}

Applying equations \eqref{eq:cfl-number}, \eqref{eq:difference-east}, and \eqref{eq:difference-west} to \eqref{eq:cartesian-form-second-step} we derive the general model given by \eqref{eq:base-model}. This equation still needs the time-stepping scheme to be defined. Several options are possible, such as replacing $(m)$ by the current or next time-step, leading to explicit and implicit problems, respectively. Another alternative would be to use an interpolated intermediate instant, what is known as the family of Crank-Nicolson schemes. Higher order time-stepping is also possible, with the exception of the first one, but again we skip this possibility to make the implementation as simple as possible.

\begin{equation}
C^{(t+\delta{}t)}_{P}-C^{(t)}_{P}=
\beta{}C^{(m)}_{W}-2\beta{}C^{(m)}_{P}+\beta{}C^{(m)}_{E}
\label{eq:base-model}
\end{equation}

The simplest solution is to apply the current instant as a replacement to $(m)$ in \eqref{eq:base-model}, what leads to \eqref{eq:explicit-model} after rearranging the terms. Notice that the integration is straightforward in this case once the next solution is computed directly from the current state of the system for each node. Due to extreme simplicity and stability issues that arise from this approach, we leave it for the interested reader to implement and experiment with the scheme.

\begin{equation}
C^{(t+\delta{}t)}_{P}=
C^{(t)}_{P}+\beta{}\left(C^{t}_{W}-2C^{t}_{P}+C^{t}_{E}\right)
\label{eq:explicit-model}
\end{equation}

Since the target of this paper is not the comparison of different time-stepping methods, we skip Crank-Nicolson schemes due to its verbose implementation when compared to the simpler implicit scheme. Real world problems would generally use a Crank-Nicolson or higher order schemes due to precision aspects of such methods. By replacing $(m)$ by $(t+\delta{}t)$ in \eqref{eq:base-model} and rearranging terms we produce \eqref{eq:implicit-model}, which is a linear system of equations.

\begin{equation}
-\beta{}C^{(t+\delta{}t)}_{W} + \left(1+2\beta{}\right) C^{(t+\delta{}t)}_{P} -\beta{}C^{(t+\delta{}t)}_{E}=C^{(t)}_{P}
\label{eq:implicit-model}
\end{equation}

The only missing element now are the boundary conditions (BC). In what follows we assume that our space in Figure~\ref{fig:discretization-scheme} represents the thickness of a plate, which can be submitted to different conditions on each side. Common cases are \begin{inparaenum}[(i)] \item the constant BC (also known as Dirichlet BC), \item the constant flux BC (known as Neumman BC), \item and variable flux BC (known as Fourier or Robin BC).\end{inparaenum} Here we will consider the later due to its generality. In its purely mathematical form, a Fourier BC writes:

\begin{equation}
au + \frac{\partial{}u}{\partial{}x}=g
\label{eq:fourier-bc}
\end{equation}

For practical purposes, when modeling diffusion it can be rewritten as \eqref{eq:fourier-bc-1}. In this equation we introduce the mass transfer coefficient $h$, which in related to a resistance of mass transfer between environment of concentration $C_{\infty}$ and the studied medium. Physically this is generally introduced due to reaction rates in environment or the establishment of a chemical boundary layer.

\begin{equation}
\frac{\partial{}C}{\partial{}x}=h\left(C_{\infty}-C\right)
\label{eq:fourier-bc-1}
\end{equation}

This boundary condition has to be replaced in \eqref{eq:cartesian-form-second-step} for both sides of the plate. This will provide us the modified terms for the first and last rows of the linear system modeled internally by \eqref{eq:implicit-model}. Replacing $W$ by ghost node $B_w$ and thus computing the flow across $bw$ instead of $w$ one determines the first row of the linear system to solve. Notice here that we made use of $C_{\infty}^{(t+\delta{}t)}$ which should be provided as an analytical function of time, allowing the computation of this additional term to right-hand side.

\begin{equation}
\left(1+\beta-\gamma_{e}\right)C^{(t+\delta{}t)}_{P}-\beta{}C^{(t+\delta{}t)}_{E} =
C^{(t)}_{P}-\gamma_{e}C_{\infty,e}^{(t+\delta{}t)}
\label{eq:cartesian-form-second-step-bw}
\end{equation}

\noindent{}where we introduced the symbol $\gamma$ analogous to CFL number for the environment-medium transfer coefficient, where $h$ has units of $\sfrac{D}{\delta{}x}$.

\begin{equation}
\gamma = h\frac{\delta{}t}{\delta{}x}
\end{equation}

Performing the analogous substitutions for the boundary $B_e$ we can show that the last row of the linear problem is given by:

\begin{equation}
-\beta{}C^{(t+\delta{}t)}_{W}\left(1+\beta-\gamma_{w}\right)C^{(t+\delta{}t)}_{P} =
C^{(t)}_{P}-\gamma_{w}C_{\infty,w}^{(t+\delta{}t)}
\label{eq:cartesian-form-second-step-be}
\end{equation}

This way the numerical formulation of the problem is complete, only an initial state being necessary to compute its time-evolution.

\section{Equation in cylindrical coordinates}

To be done in next version.

\section{Implementation}

For the construction of the program to solve this model we can start by listing all the required physical constants and parameters. Starting by the space discretization we should provide the \begin{inparaenum}[(i)] \item length $L$ of the medium and \item the number of nodes $N_{nodes}$\end{inparaenum}, the cell length $\delta{}x$ being computed as $\sfrac{L}{(N_{nodes}-1)}$. Similarly we provide \begin{inparaenum}[(i)] \item the total integration time $T$ and \item the number of time-steps $N_{steps}$\end{inparaenum}, the time-step $\delta{}t$ being computed as $\sfrac{T}{(N_{steps}-1)}$.

Storage of local composition of each node requires an array $C$ of length $N_{nodes}$. The initialization of $C$ can be done by an user defined function that sets the value of each node in $C$. Next, the transport coefficients $D$ and $h$ must be provided as constants, what allows for the computation of parameters $\beta$ and $\gamma$, both held constant in this study. Boundary conditions on both sides are treated independently, thus two values of $h$, leading to $\gamma_{w}$ and $\gamma_{e}$. Once we assumed the environment concentration $C_{\infty}$ can vary in time, two functions must be provided, say $C_{\infty,w}$ and $C_{\infty,e}$.

The matrix describing the system of equations is tridiagonal. Storing it as three arrays for the diagonals is convenient for the solution with use of Thomas algorithm. Thus, the main diagonal is stored in array $d$ of length $N_{nodes}$, the upper and lower diagonals of length $N_{nodes}-1$ are stored in $u$ and $l$, respectively. An implementation of Thomas algorithm must be provided.

Once all these features are available, a method providing the management of time-stepping and output of results to a file must be conceived. The problem solver will be provided in a dynamically linked library programmed in C\# and the application program will be conceived in Python so that ease of change of parameters and post-processing is achieved.
