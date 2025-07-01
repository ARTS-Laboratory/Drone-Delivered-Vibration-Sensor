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


void dofMatvec(float* output, float* b, float* c, float* vector, int m, int n, int r) {
  // output = [ax1, ax2]. Here, ax1 has a length of r, and ax2 has a length of n - r.

  // ax1 = B * x
  matvec(output, b, vector, r, m);

  // ax2 = C * ax1
  matvec(&output[r], c, output, n - r, r);
}


float sigmoid(float x) {
  return 1 / (1 + exp(-x));
}


float hypertan(float x) {
  return 2 * sigmoid(2 * x) - 1;
}
