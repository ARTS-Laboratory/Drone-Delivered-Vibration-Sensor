// Copyright (c) UofSC ARTS Lab, 2025

#ifndef LINEAR_ALGEBRA_H
#define LINEAR_ALGEBRA_H

float dot(float* v1, float* v2, int length);

// Computes the matrix-vector product and writes the result to an array.
void matvec(float* output, float* matrix, float* vector, int m, int n);

float sigmoid(float x);

float hypertan(float x);

#endif  // LINEAR_ALGEBRA_H
