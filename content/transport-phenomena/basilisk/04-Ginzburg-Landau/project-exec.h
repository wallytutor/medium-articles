#pragma once

event integration (i++)
{
    dt = dtnext(M_MAX_TIME_STEP);

    foreach()
    {
        A2[] = sq(Ar[]) + sq(Ai[]);
    }
  
    scalar r[], lambda[];
    
    foreach()
    {
        r[] = +A2[] * beta * Ai[];
        lambda[] = 1.0 - A2[];
    }

    mgd1 = diffusion(Ar, dt, r = r, beta = lambda);
  
    foreach()
    {
        r[] = -A2[] * beta * Ar[];
        lambda[] = 1.0 - A2[];
    }

    mgd2 = diffusion(Ai, dt, r = r, beta = lambda);
}

