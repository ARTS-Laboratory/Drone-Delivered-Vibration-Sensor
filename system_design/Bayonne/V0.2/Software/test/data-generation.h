// Copyright (c) ARTS Lab, 2025

// Generates pseudo data for seeing if the model implementation is correct. This
// is not designed to check the model itself, as it expects real-world data
// from a sensor package. This is only meant as a debugging tool for the model's
// implementation.

#include <math.h>
#include <vector>
using std::vector;

// Writes a sinwave of a given frequency to a vector.
void genSinwave(vector<float>& buffer, float amplitude, float freqency);


// Writes a frequency sweep to a vector.
void genSweep(vector<float>& buffer, float amplitude, float startFreq,
              float endFreq);
