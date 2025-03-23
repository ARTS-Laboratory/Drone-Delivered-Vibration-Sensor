// Copyright ARTS Lab, 2025

#include "reduced-lstm.h"
#include "linear-algebra.h"
using edgeML::ReducedLSTM;

ReducedLSTM::ReducedLSTM(int numUnits, int inputSize, int rank, float **matrixB,
                         float **matrixC, float *bias)
    : numUnits(numUnits), inputSize(inputSize), rank(rank), matrixB(matrixB),
      matrixC(matrixC), bias(bias) {
  this->inputHidden = new float[numUnits + inputSize]();
  this->cellState = new float[numUnits]();
  this->gates = new float[numUnits * 4]();
}

// Forward pass
void ReducedLSTM::step(float* input, float* destination) {
  // Concat x and h
  for (int i = 0; i < inputSize; i++) {
    inputHidden[i] = input[i];
  }

  matvec(gates, matrixB, inputHidden, numUnits + inputSize, rank);
  matvec(&gates[rank], matrixC, gates, numUnits - rank, rank);

  for (int i = 0; i < numUnits + inputSize; i++) {
    inputHidden[i] += bias[i];
  }

  // Apply activation functions
  for (int i = 0; i < numUnits; i++) {
    cellState[i] = cellState[i] * sigmoid(gates[numUnits + i]) +
                   sigmoid(gates[i]) * hypertan(gates[2 * numUnits + i]);

    destination[i] = inputHidden[inputSize + i] =
      sigmoid(gates[3 * numUnits + i]) * hypertan(cellState[i]);
  }
}

void ReducedLSTM::resetState() {
  for (int i = 0; i < numUnits; i++) {
    cellState[i] = 0;
    inputHidden[inputSize + i] = 0;
  }
}
