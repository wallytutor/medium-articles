#include "saint-venant.h"

// Specify wave height `h` at starting time `t = 0`.
event init (t = 0) {
    double a = 1.0, b = 200.0;
    foreach() {
        h[] = 0.1 + a * exp(-b * (x*x + y*y));
    }
}

// Generate images of results every iteration.
// By default redirected to `stdout`.
event images (i++) {
    output_ppm(h);
}

// Print statistics of `h` every step to `stderr`.
// Notice `stdout` is taken by the `images` event.
event graphs (i++) {
    stats s = statsf(h);
    fprintf(stderr, "%g %g %g\n", t, s.min, s.max);
}

// At iteration `i = 10` (end of calculation), show integration time `t`.
event end (i = 1200) {
    printf("i = %d t = %g\n", i, t);
}

int main() {
    // Change origin of coordinate system.
    origin(-0.5, -0.5);

    // Increase grid resolution.
    init_grid(256);

    // Run simulation.
    run();
}

