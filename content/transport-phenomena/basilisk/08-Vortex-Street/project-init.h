#pragma once

event properties (i++)
{
    foreach_face()
    {
        muv.x[] = fm.x[] * D * U0 / Reynolds;
    }
}

// Inlet Dirichlet velocity condition and free pressure.
u.n[left]  = dirichlet(U0);
p[left]    = neumann(0.0);
pf[left]   = neumann(0.0);
f[left]    = dirichlet(y < 0);

// Outlet Dirichlet pressure and free velocity.
u.n[right] = neumann(0.0);
p[right]   = dirichlet(0.0);
pf[right]  = dirichlet(0.0);

// Slip conditions on top/botton and no-slip over sphere.
u.n[embed] = fabs(y) > 0.25 ? neumann(0.0) : dirichlet(0.0);
u.t[embed] = fabs(y) > 0.25 ? neumann(0.0) : dirichlet(0.0);

event init (t = 0)
{
    solid(cs, fs, 
        intersection(
            intersection(0.5 - y, 0.5 + y),
			sqrt(sq(x) + sq(y)) - D/2.0
        )
    );

    foreach()
    {
        u.x[] = cs[] ? U0 : 0.0;
    }
}

