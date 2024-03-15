#pragma once

event init (i = 0)
{
    // The marginal stability is obtained for kb = kbcrit.
    double nu = sqrt(1.0 / D);
    double kbcrit = sq(1.0 + ka * nu);
    kb = kbcrit * (1.0 + mu);

    // Unstable stationary solution perturbed by random noise.
    foreach()
    {
        C1[] = ka; 
        C2[] = kb / ka + 0.01 * noise();
    }
}

