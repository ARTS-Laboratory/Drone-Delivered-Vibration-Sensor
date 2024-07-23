// Copyright ARTS Lab, 2024

#include "linear-algebra.h"
#include <math.h>

float edgeML::dotProduct(float* vectorA, float* vectorB, int vectorSize) {
  float output = 0;

  for (int i = 0; i < vectorSize; i++) {
    output += vectorA[i] * vectorB[i];
  }

  return output;
}

void edgeML::vectorMatTmultiply(float* vector, float** matrix,
                                float* bias, float* destination, int vectorSize,
                                int matrixNumRows) {
  for (int i = 0; i < matrixNumRows; i++) {
    destination[i] = dotProduct(vector, matrix[i], vectorSize) + bias[i];
  }
}

float edgeML::sigmoid(float x) {
  return 1/ (1 + exp(-1 * x));
}

float edgeML::hypertan(float x) {
  return 2 * sigmoid(x) - 1;
}
