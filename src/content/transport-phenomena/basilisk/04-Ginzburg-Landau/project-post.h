#pragma once

event movies (i += 3; t <= 150)
{
    fprintf (stderr, "t = %.3f\t√|A2| = %.6e\n", t, sqrt(normf(A2).max));
    output_ppm(Ar, spread = 2, linear = true, file = "Ar.mp4");
    output_ppm(Ai, spread = 2, linear = true, file = "Ai.mp4");
    output_ppm(A2, spread = 2, linear = true, file = "A2.mp4");
}
