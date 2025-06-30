// Copyright ARTS Lab, 2025

#ifndef LSTM_H
#define LSTM_H

// This LSTM expects B and C to be flattened and concatenated.
class ReducedLSTM {
 public:
   ReducedLSTM(int numUnits, int inputSize, int rank, float* w, float* bI,
               float* bF, float* bC, float* bO);

   void step(float *destination, float *input);

   void reset();

 private:
  int numUnits, inputSize, rank;

  float* w;

  float* gates;
  float* iGate;
  float* fGate;
  float* cGate;
  float* oGate;
  float* cCandidate;

  float* bI;
  float* bF;
  float* bC;
  float* bO;

  float* states; // [x h_t-1]
};

#endif  // !LSTM_H
