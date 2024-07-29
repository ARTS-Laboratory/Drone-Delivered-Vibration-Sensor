// Copyright ARTS Lab, 2024

#include "lstm.h"
#include "linear-algebra.h"
using edgeML::LSTM;

LSTM::LSTM(int numUnits, int inputSize, float** mergedWeightMatrix,
           float* biasVector) : numUnits(numUnits), inputSize(inputSize),
                                mergedWeightMatrix(mergedWeightMatrix), biasVector(biasVector) {
  this->statesVector = new float[numUnits + inputSize]();
  this->cellState = new float[numUnits]();
  this->gates = new float[numUnits * 4]();
}

// Forward pass
void LSTM::step(float* input, float* destination) {
  // Concat x and h
  for (int i = 0; i < inputSize; i++) {
    statesVector[i] = input[i];
  }

  vectorMatTmultiply(statesVector, mergedWeightMatrix, biasVector, gates,
                     numUnits + inputSize, numUnits * 4);

  // Apply activation functions
  for (int i = 0; i < numUnits; i++) {
    cellState[i] = cellState[i] * sigmoid(gates[numUnits + i]) +
                   sigmoid(gates[i]) * hypertan(gates[2 * numUnits + i]);

    destination[i] = statesVector[inputSize + i] =
      sigmoid(gates[3 * numUnits + i]) * hypertan(cellState[i]);
  }
}

void LSTM::resetState() {
  for (int i = 0; i < numUnits; i++) {
    cellState[i] = 0;
    statesVector[inputSize + i] = 0;
  }
}
