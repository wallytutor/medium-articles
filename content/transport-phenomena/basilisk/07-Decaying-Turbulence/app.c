// app.c
#define LEVEL 8

#include "grid/multigrid.h"
#include "navier-stokes/stream.h"

#include "project-init.h"
#include "project-post.h"

int main() {
    init_grid(1 << LEVEL);
    run();
}

