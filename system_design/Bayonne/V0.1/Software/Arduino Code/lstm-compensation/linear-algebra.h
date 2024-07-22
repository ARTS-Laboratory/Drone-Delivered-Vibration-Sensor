// ARTS Lab, 2024

#ifndef LINEAR_ALGEBRA_H
#define LINEAR_ALGEBRA_H

namespace edgeML {
// Computes the dotproduct between two vectors
float dotProduct(float* vectorA, float* vectorB, int vectorSize);

// Multiplies a vector by a column major matrix and add a bias vector
void vectorMatTmultiply(float* vector, float** matrix,
                       float* bias, float* outputVector,
                       int vectorSize, int matrixNumRows);

// Linear approximation of sigm(x)
float sigmoid(float x);

// Linear approximation of tanh(x) using sigmoid
float hypertan(float x);
}

#endif  //LINEAR_ALGEBRA_H
