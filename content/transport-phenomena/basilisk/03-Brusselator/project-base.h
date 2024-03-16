#pragma once

// Maximum time step in dynamic management.
const double M_MAX_TIME_STEP = 1.0;

// Species concentrations.
scalar C1[], C2[];

// Parameters: 10.1103/PhysRevE.64.056213
double k = 1.0, ka = 4.5, D = 8.0;
double mu, kb;

// For time-stepping and statistics.
double dt;
mgstats mgd1, mgd2;

