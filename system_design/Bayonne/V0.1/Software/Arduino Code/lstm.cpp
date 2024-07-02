// ARTS Lab, 2024

#include "lstm.h"
#include "linear-algebra.h"
using edgeML::LSTM;

LSTM::LSTM(int numUnits, int inputSize, float** mergedWeightMatrix,
           float* biasVector) : numUnits(numUnits), inputSize(inputSize),
                                  mergedWeightMatrix(mergedWeightMatrix),
                                  biasVector(biasVector) {
  this->statesVectorSize = inputSize + numUnits;
  this->statesVector = new float[statesVectorSize]();
  this->cellState = new float[numUnits]();
  this->weightMatrixNumRows = numUnits * 4;
  this->gates = new float[numUnits * 4]();
  this->outputVector = this->gates + inputSize;
}

// Forward pass
void LSTM::step(float* input, float* destination) {
  // Copy the input vector into the states vector. This is equivallent to
  // concatonating x and h.
  for (int i = 0; i < inputSize; i++) {
    statesVector[i] = input[i];
  }

  vectorMatTmultiply(statesVector, mergedWeightMatrix, biasVector, gates,
                     numUnits + inputSize, weightMatrixNumRows);

  // [i f c o]
  // Apply activation functions
  for (int i = 0; i < numUnits; i++) {
    cellState[i] *= sigmoid(gates[numUnits + i]);
    cellState[i] += sigmoid(gates[i]) * hypertan(gates[2 * numUnits + i]);

    destination[i] = statesVector[inputSize + i] =
      sigmoid(gates[3 * numUnits]) * hypertan(cellState[i]);
  }
}
