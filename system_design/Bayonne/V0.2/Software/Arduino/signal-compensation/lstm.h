// Copyright ARTS Lab, 2025

#ifndef LSTM_H
#define LSTM_H

// This LSTM expects U and W to be concatenated, then flattened.
class LSTM {
 public:
  LSTM(int numUnits, int inputSize, float* wI,
       float* wF, float* wC, float* wO, float* bias);

  void step(float* destination, float* input);

  void reset();

 private:
  int numUnits, inputSize;

  float* wI;
  float* wF;
  float* wC;
  float* wO;
  float* bias;

  float* iGate;
  float* fGate;
  float* cGate;
  float* oGate;
  float* cCandidate;

  float* states; // [x h_t-1]
};

#endif  // !LSTM_H
