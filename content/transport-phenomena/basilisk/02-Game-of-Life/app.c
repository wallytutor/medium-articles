// Definitions
#define LEVEL 8

// Use a cartesian grid and generic loop.
#include "grid/cartesian.h"
#include "run.h"

// Project includes.
#include "project-base.h"
#include "project-init.h"
#include "project-exec.h"
#include "project-post.h"

int main() {
    origin(-0.5, -0.5);
    init_grid(1 << LEVEL);
    run();
}

