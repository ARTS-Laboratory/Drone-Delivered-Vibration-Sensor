#include "lstm.h"
#include "linear-algebra.h"

LSTM::LSTM(int numUnits, int inputSize, float* wI, float* wF,
          float* wC, float* wO, float* bI, float* bF, float* bC, float* bO) :
          numUnits(numUnits), inputSize(inputSize), wI(wI), wF(wF),
          wC(wC), wO(wO), bI(bI), bF(bF), bC(bC), bO(bO) {
  this->states = new float[numUnits + inputSize]();

  this->iGate = new float[numUnits]();
  this->fGate = new float[numUnits]();
  this->cGate = new float[numUnits]();
  this->oGate = new float[numUnits]();

  this->cCandidate = new float[numUnits]();
}


void LSTM::step(float* destination, float* input) {
  // Concatonate x and h_t-1
  for (int i = 0; i < inputSize; i++) {
    states[i + numUnits] = input[i];
  }

  matvec(iGate, wI, states, numUnits, numUnits + inputSize);
  matvec(fGate, wF, states, numUnits, numUnits + inputSize);
  matvec(oGate, wO, states, numUnits, numUnits + inputSize);
  matvec(cCandidate, wC, states, numUnits, numUnits + inputSize);

  for (int i = 0; i < numUnits; i++) {
    // Apply activation functions and bias
    iGate[i] = sigmoid(iGate[i] + bI[i]);
    fGate[i] = sigmoid(fGate[i] + bF[i]);
    oGate[i] = sigmoid(oGate[i] + bO[i]);
    cCandidate[i] = hypertan(cCandidate[i] + bC[i]);

    // Compute C
    cGate[i] = cGate[i] * fGate[i] + iGate[i] * cCandidate[i];

    // Compute and write output
    destination[i] = states[i] = hypertan(cGate[i]) * oGate[i];
  }
}


void LSTM::reset() {
  for (int i = 0; i < numUnits; i++) {
    cGate[i] = 0;
    states[inputSize + i] = 0;
  }
}
