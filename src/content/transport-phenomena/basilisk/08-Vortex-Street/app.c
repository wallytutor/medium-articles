// app.c

#include "embed.h"
#include "navier-stokes/centered.h"
#include "tracer.h"

#include "project-base.h"
#include "project-init.h"
#include "project-post.h"
#include "project-exec.h"

int main() {
    L0 = 8.0 [1];

    origin(-0.5, -L0/2);

    N = 512;
    mu = muv;

    display_control(Reynolds, 10, 1000);
    display_control(maxlevel, 6, 12);

    run();
}

