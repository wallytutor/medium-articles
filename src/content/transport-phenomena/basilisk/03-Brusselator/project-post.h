#pragma once

event movie (i = 1; i += 10)
{
    output_ppm(C1, linear = true, spread = 2, file = "f.mp4", n = 200);
    fprintf(stderr, "%d %g %g %d %d\n", i, t, dt, mgd1.i, mgd2.i);
}

event final (t = 3000)
{
    char name[80];
    sprintf(name, "mu-%.2f.png", mu);
    output_ppm(C1, file = name, n = 200, linear = true, spread = 2);
}

