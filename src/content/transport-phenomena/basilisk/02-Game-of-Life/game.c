// Change type of grid used by the solver (~2x faster than Quadtree).
// But it cannot be used with adaptive grid refinement.
// #include "grid/cartesian.h"

// Add Saint-Venant equation solver.
#include "saint-venant.h"

// Refinement level to use in simulation.
#define LEVEL 8

// Specify wave height `h` at starting time `t = 0`.
event init (t = 0) {
    double a = 1.0, b = 200.0;
    foreach() {
        h[] = 0.1 + a * exp(-b * (x*x + y*y));
    }
}

// Generate images of results every iteration.
//event images (i++) {          // By iteration number.
event images (t += 4.0/300.0) { // By physical time.
    // By default redirected to `stdout`.
    // Add interpolation for grid refinement display.
    output_ppm(h, linear = true);

    // Store animation of grid additionally in a file.
    scalar l[];
    foreach() {
        l[] = level;
    }

    // Static variable is allocated only in the first call here.
    static FILE * fp = fopen("grid.ppm", "w");

    // Min and max ensure constant color scale across animation.
    output_ppm(l, fp, min = 0, max = LEVEL);
}

// Adaptive grid refinement.
event adapt (i++) {
    adapt_wavelet({h}, (double []){4.0e-03}, maxlevel = LEVEL);
}

// Print statistics of `h` every step to `stderr`.
// Notice `stdout` is taken by the `images` event.
event graphs (i++) {
    stats s = statsf(h);
    fprintf(stderr, "%g %g %g\n", t, s.min, s.max);
}

// At iteration `i` (end of calculation), show integration time `t`.
// event end (i = 1200) { // By iteration number.
event end (t = 4) {       // By physical time.
    printf("i = %d t = %g\n", i, t);
}

int main() {
    // Change origin of coordinate system.
    origin(-0.5, -0.5);

    // Increase grid resolution.
    init_grid(1 << LEVEL);

    // Run simulation.
    run();
}

