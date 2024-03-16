#pragma once

event movie (i += 5; i < 1000)
{
    scalar m[];

    foreach() {
        m[] = age[] ? 1 : -1;
    }

    output_ppm(age,
        mask = m,
        n    = 512,
        file = "age.gif",
        opt  = "--delay 1"
    );
}

