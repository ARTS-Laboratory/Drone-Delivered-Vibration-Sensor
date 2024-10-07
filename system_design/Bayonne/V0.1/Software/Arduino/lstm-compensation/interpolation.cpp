// Copyright ARTS Lab, 2024

#include "interpolation.h"

void interpolation::interpolateLinear(float* xValues, float* yValues,
                                      float* destination, int length,
                                      float period) {
  int x0 = 0;
  float step = period;

  for (int x1 = 1; x1 < length; x1++) {
    destination[x0] =  yValues[x0];

    destination[x0] += (yValues[x1] - yValues[x0]) /
                       (xValues[x1] - xValues[x0]);

    destination[x0] *= step - xValues[x0];

    x0 = x1;
    step += period;
  }
}
