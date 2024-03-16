#pragma once

event integration (i++)
{
    // Adapt and bound to 1.0 the next time-step.
    dt = dtnext(M_MAX_TIME_STEP);

    // Solve problem in an uncoupled way.
    scalar r[], beta[];
    const face vector c[] = {D, D};
  
    foreach()
    {
        r[] = k * ka;
        beta[] = k * (C1[] * C2[] - kb - 1.0);
    }
    
    mgd1 = diffusion(C1, dt, r = r, beta = beta);
  
    foreach()
    {
        r[] = k * kb * C1[];
        beta[] = -k * sq(C1[]);
    }
  
    mgd2 = diffusion(C2, dt, c, r, beta);
}

