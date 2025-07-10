#include "lstm.h"
#include "linear-algebra.h"

LSTM::LSTM(int numUnits, int inputSize, float* w, float* bI, float* bF,
           float* bC, float* bO)
    : numUnits(numUnits), inputSize(inputSize), w(w), bI(bI), bF(bF), bC(bC),
      bO(bO) {
  this->states = new float[numUnits + inputSize]();
  this->gates = new float[numUnits * 4]();

  // "Pre-compute" the address of each gate in the gates vector for
  // convenience
  this->iGate = gates;
  this->fGate = &gates[numUnits * 1];
  this->cCandidate = &gates[numUnits * 2];
  this->oGate = &gates[numUnits * 3];

  this->cGate = new float[numUnits]();
}

void LSTM::step(float* destination, float* input) {
  // Concatonate x and h_t-1
  for (int i = 0; i < inputSize; i++) {
    states[i] = input[i];
  }

  matvec(gates, w, states, numUnits * 4, numUnits + inputSize);

  for (int i = 0; i < numUnits; i++) {
    // Apply activation functions and bias
    iGate[i] = sigmoid(iGate[i] + bI[i]);
    fGate[i] = sigmoid(fGate[i] + bF[i]);
    oGate[i] = sigmoid(oGate[i] + bO[i]);
    cCandidate[i] = hypertan(cCandidate[i] + bC[i]);

    // Compute C
    cGate[i] = cGate[i] * fGate[i] + iGate[i] * cCandidate[i];

    // Compute and write output
    destination[i] = states[i + inputSize] = hypertan(cGate[i]) * oGate[i];
  }
}


void LSTM::reset() {
  for (int i = 0; i < numUnits; i++) {
    cGate[i] = 0;
    states[inputSize + i] = 0;
  }
}
