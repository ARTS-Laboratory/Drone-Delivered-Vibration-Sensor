// Copyright ARTS Lab, 2024

#include "interpolation.h"

float interpolation::interpolateLinear(float x0, float x1, float y0, 
                                       float y1, float target) {
  return (y1 - y0) * (target - x0) / (x1 - x0) + y0;
}
