#pragma once

event init (i = 0)
{
    double a = 1.0 [0, -1];

    foreach()
    {
        omega[] = a * noise();
    }
}

