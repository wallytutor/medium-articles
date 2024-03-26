#pragma once

event logfile (i++)
{
    fprintf(stderr, "%d %g %d %d\n", i, t, mgp.i, mgu.i);
}

event movies (i += 4; t <= 15.0)
{
    scalar omega[], m[];
    vorticity(u, omega);
    
    foreach()
    {
        m[] = cs[] - 0.5;
    }
       
    output_ppm(omega, file = "vort.mp4", box = {{-0.5,-0.5},{7.5,0.5}},
               min = -10, max = 10, linear = true, mask = m);
    output_ppm(f, file = "f.mp4", box = {{-0.5,-0.5},{7.5,0.5}},
               linear = false, min = 0, max = 1, mask = m);
}

