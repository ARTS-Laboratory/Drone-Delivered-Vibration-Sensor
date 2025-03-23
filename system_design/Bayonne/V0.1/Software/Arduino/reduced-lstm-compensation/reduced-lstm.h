// Copyright ARTS Lab, 2025

#ifndef Reduced_LSTM_H
#define Reduced_LSTM_H

namespace edgeML {
class ReducedLSTM {
 public:
  ReducedLSTM(int numUnits, int inputSize, int rank, float** matrixB, float** matrixC,
       float* bias);

  // LSTM forward pass
  void step(float* input, float* destination);

  // Set h and c to 0's
  void resetState();

 private:
  int numUnits;
  int inputSize;
  int rank;

  float** matrixB;
  float** matrixC;
  float* bias;

  float* inputHidden;  // Merged input and hidden vectors
  float* cellState;
  float* gates;
};
}  // namespace edgeML

#endif  // !LSTM_H
