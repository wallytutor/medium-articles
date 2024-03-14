#pragma once

// Initialize zeros and ones randomly in a circle of radius 0.2
event init (i = 0)
{
    foreach()
    {
        a[] = (x*x + y*y < sq(0.2))*(noise() > 0.0);
        age[] = a[];
    }
}
