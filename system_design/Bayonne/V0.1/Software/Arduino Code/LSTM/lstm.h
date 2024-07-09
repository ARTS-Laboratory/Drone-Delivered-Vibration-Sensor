// ARTS Lab, 2024

#ifndef LSTM_H
#define LSTM_H

namespace edgeML {
// The Teensy has an FPU, so we'll use floats for now.
class LSTM {
 public:
  LSTM(int numUnits, int inputSize, float** mergedWeightMatrix,
       float* biasVector);
  void step(float* input, float* destination);

 private:
  int numUnits;
  int inputSize;
  int statesVectorSize;
  int workingVectorSize;
  int weightMatrixNumRows;

  float** mergedWeightMatrix;
  float* biasVector;

  float* statesVector; // Merged input, hidden, and carry vectors
  float* cellState;
  float* gates;
  float* outputVector; // Keeps track of where the output vector is
};
}

#endif  // !LSTM_H
