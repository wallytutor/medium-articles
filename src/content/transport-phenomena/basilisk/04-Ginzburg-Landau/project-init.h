#pragma once

event init (i = 0) {
    foreach()
    {
        Ar[] = M_NOISE_SCALE * noise();
        Ai[] = M_NOISE_SCALE * noise();
    }
}
