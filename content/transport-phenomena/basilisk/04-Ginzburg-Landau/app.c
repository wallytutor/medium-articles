// app.c
#define LEVEL 8

#include "grid/cartesian.h"
#include "run.h"

#include "project-base.h"
#include "project-init.h"
#include "project-post.h"
#include "project-exec.h"

int main() {
    origin(-0.5, -0.5);
    init_grid(1 << LEVEL);
    run();
}

