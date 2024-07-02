// ARTS Lab, 2024

#ifndef LINEAR_ALGEBRA_H
#define LINEAR_ALGEBRA_H

namespace edgeML {
float dotProduct(float* vectorA, float* vectorB,
                 float* destination, int vectorSize);

void vectorMatTmultiply(float* vector, float** matrix,
                       float* bias, float* outputVector,
                       int vectorSize, int matrixNumRows);

float sigmoid(float x);
float hypertan(float x);
}

#endif  //LINEAR_ALGEBRA_H
