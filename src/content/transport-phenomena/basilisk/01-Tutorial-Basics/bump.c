#include "saint-venant.h"

// At iteration `i = 10` (end of calculation), show integration time `t`.
event end (i = 10) {
    printf("i = %d t = %g\n", i, t);
}


int main() {
    // Change origin of coordinate system.
    origin(-0.5, -0.5);

    // Run simulation.
    run();
}

