// Copyright (c) UofSC ARTS Lab, 2025

#include <math.h>


float dot(float* v1, float* v2, int length) {
  float output = 0;

  for (int i = 0; i < length; i++) {
    output += v1[i] * v2[i];
  }

  return output;
}


void matvec(float* output, float* matrix, float* vector, int m, int n) {
  int offset;

  for (int i = 0; i < m; i++) {
    offset = n * i;
    output[i] = 0;

    for (int j = 0; j < n; j++) {
      output[i] += matrix[offset + j] * vector[j];
    }
  }
}


float sigmoid(float x) {
  return 1 / (1 + exp(-x));
}


float hypertan(float x) {
  return 2 * sigmoid(2 * x) - 1;
}
