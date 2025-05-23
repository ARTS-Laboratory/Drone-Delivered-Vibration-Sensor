// Copyright ARTS Lab, 2025

#ifndef LSTM_H
#define LSTM_H

class LSTM {
 public:
  LSTM(int numUnits, int inputSize, float* wI,
       float* wF, float* wC, float* wO, float* b);

  void step(float* destination, float* input);

  void reset();

 private:
  int numUnits, inputSize;

  float* wI;
  float* wF;
  float* wC;
  float* wO;
  float* b;

  float* c;
  float* states;
  float* gates;
};

#endif  // !LSTM_H
