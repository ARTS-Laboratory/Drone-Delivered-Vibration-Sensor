// Copyright ARTS Lab, 2025

#ifndef LSTM_H
#define LSTM_H

// This LSTM expects W and U to be concatenated, then flattened.
// Weight matrices should be in the order [Wi Wf Wc Wo].
class LSTM {
 public:
   LSTM(int numUnits, int inputSize, float* w, float* bI, float* bF, float* bC,
        float* bO);

   void step(float *destination, float *input);

   void reset();

 private:
  int numUnits, inputSize;

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
