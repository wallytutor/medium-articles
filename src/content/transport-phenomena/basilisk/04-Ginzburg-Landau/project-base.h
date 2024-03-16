#pragma once

// Maximum time step in dynamic management.
const double M_MAX_TIME_STEP = 0.05;

// Random noise scale for initialization.
const double M_NOISE_SCALE = 1.0e-04;

// Real, imaginary, and absolute value of solution.
scalar Ar[], Ai[], A2[];

// Problem coefficients.
// double alpha = 0.0; // Not used, generalize with this!
double beta = 1.5;

// For time-stepping and statistics.
double dt;
mgstats mgd1, mgd2;


