// ARTS Lab, 2024

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

  // [i f c o]
  // Apply activation functions
  for (int i = 0; i < numUnits; i++) {
    gates[i] = sigmoid(gates[i]);
    gates[numUnits + i] = sigmoid(gates[numUnits + i]);
    cellState[i] = cellState[i] * gates[numUnits + i] + gates[i] + hypertan(2 * numUnits + i);
    gates[3 * numUnits + i] = sigmoid(gates[3 * numUnits + i]);
    destination[i] = statesVector[inputSize + i] = gates[3 * numUnits + i] * hypertan(cellState[i]);
  }
}
