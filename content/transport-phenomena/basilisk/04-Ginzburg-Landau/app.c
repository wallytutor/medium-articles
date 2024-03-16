// app.c
#define LEVEL 8
#define MSIZE 100

#include "grid/multigrid.h"
#include "run.h"
#include "diffusion.h"

#include "project-base.h"
#include "project-init.h"
#include "project-post.h"
#include "project-exec.h"

int main() {
    size(MSIZE);
    init_grid(1 << LEVEL);
    run();
}

