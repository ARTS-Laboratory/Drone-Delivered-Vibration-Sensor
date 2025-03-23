// Copyright ARTS Lab, 2024

#ifndef LINEAR_ALGEBRA_H
#define LINEAR_ALGEBRA_H

namespace edgeML {
float dotProduct(float *vectorA, float *vectorB, int vectorSize);

void matvec(float *outputVector, float **matrix, float *vector, int vectorSize,
            int matrixNumRows);

float sigmoid(float x);

float hypertan(float x);
}  // namespace edgeML

#endif  // LINEAR_ALGEBRA_H
