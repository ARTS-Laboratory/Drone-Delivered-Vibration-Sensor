// Copyright ARTS Lab, 2024

#ifndef LSTM_H
#define LSTM_H

namespace edgeML {
class LSTM {
 public:
  LSTM(int numUnits, int inputSize, float* mergedWeightMatrix[],
       float* biasVector);

  // LSTM forward pass
  void step(float* input, float* destination);

  // Set h and c to 0's
  void resetState();

 private:
  int numUnits;
  int inputSize;

  float** mergedWeightMatrix;
  float* biasVector;

  float* statesVector; // Merged input and hidden vectors
  float* cellState;
  float* gates;
};
}

#endif  // !LSTM_H
