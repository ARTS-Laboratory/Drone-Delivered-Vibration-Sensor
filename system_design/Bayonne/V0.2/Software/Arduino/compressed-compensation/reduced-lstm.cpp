#include "reduced-lstm.h"
#include "linear-algebra.h"

ReducedLSTM::
   ReducedLSTM(int numUnits, int inputSize, int rank, float* b, float* c,
               float* bI, float* bF, float* bC, float* bO) :
               numUnits(numUnits), inputSize(inputSize), rank(rank),
               b(b), c(c), bI(bI), bF(bF), bC(bC), bO(bO) {
  this->states = new float[numUnits + inputSize]();
  this->gates = new float[numUnits * 4]();

  // "Pre-compute" the address of each gate in the gates vector for
  // convenience (similarity to the original LSTM implementation)
  this->iGate = gates;
  this->fGate = &gates[numUnits * 1];
  this->cCandidate = &gates[numUnits * 2];
  this->oGate = &gates[numUnits * 3];

  this->cGate = new float[numUnits]();
}


void ReducedLSTM::step(float* destination, float* input) {
  // Concatenate x and h_t-1
  for (int i = 0; i < inputSize; i++) {
    states[i] = input[i];
  }

  dofMatvec(gates, b, c, states, numUnits * 4, numUnits + inputSize, rank);

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


void ReducedLSTM::reset() {
  for (int i = 0; i < numUnits; i++) {
    cGate[i] = 0;
    states[inputSize + i] = 0;
  }
}
