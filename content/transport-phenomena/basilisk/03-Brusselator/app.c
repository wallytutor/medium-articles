// Definitions
#define LEVEL 7
#define MSIZE 64

// Basilisk includes.
#include "grid/multigrid.h"
#include "run.h"
#include "diffusion.h"

// Project includes.
#include "project-base.h"
#include "project-init.h"
#include "project-post.h"
#include "project-exec.h"

int main() {
    init_grid(1 << LEVEL);
    size(MSIZE);

    // Is this coming from diffusion.h?
    TOLERANCE =  1.0e-04;

    mu = 0.04; run();
    mu = 0.10; run();
    mu = 0.98; run();
}

