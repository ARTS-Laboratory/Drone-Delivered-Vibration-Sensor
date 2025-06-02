// Copyright (c) ARTS Lab, 2025

// Simple testbench for the LSTM model

#include "test-lstm.h"
#include "../Arduino/signal-compensation/lstm.h"
#include "../Arduino/signal-compensation/linear-algebra.h"
#include "data-generation.h"
#include "model-loading.h"
#include <fstream>
#include <iostream>
#include <iterator>
#include <vector>
#include <math.h>
#include <cstdlib>

using std::ifstream;
using std::ofstream;
using std::vector;
using std::cout;


int main() {
  vector<float> inputData(2000);
  vector<float> outputData(2000);
  
  int numUnits = 50;
  int inputSize = 1;

  // Dynamically declared, just like it is on edge.
  float* lstmWeights = new float[4 * numUnits * (numUnits + inputSize)];
  float* lstmBias = new float[numUnits + inputSize];
  float* denseWeights = new float[numUnits];
  float* denseBias = new float;

  float* wI = &lstmWeights[0];
  float* wF = &lstmWeights[NUMUNITS * (NUMUNITS + INPUTSIZE)];
  float* wC = &lstmWeights[2 * NUMUNITS * (NUMUNITS + INPUTSIZE)];
  float* wO = &lstmWeights[3 * NUMUNITS * (NUMUNITS + INPUTSIZE)];

  float* bI = &lstmBias[0];
  float* bF = &lstmBias[NUMUNITS];
  float* bC = &lstmBias[2 * NUMUNITS];
  float* bO = &lstmBias[3 * NUMUNITS];

  cout << "Loading weights...\n";
  loadWeights(lstmWeights, lstmBias, denseWeights, denseBias, numUnits,
              inputSize);
  cout << "Weights loaded.\n";

  LSTM* lstm = new LSTM(NUMUNITS, INPUTSIZE, wI, wF, wC, wO, bI, bF, bC, bO);

  // float lstmOut[50];
  float* lstmOut = new float[50];

  genSinwave(inputData, 0.15, 10, false);

  for (int i = 0; i < inputData.size(); i++) {
    outputData[i] = runInference(&inputData[i], lstm, lstmOut, numUnits,
                                 denseWeights, denseBias);
  }

  ofstream outputFile("test-lstm-out.csv");

  for (int i = 0; i < inputData.size(); i++) {
    outputFile << inputData[i] << "," << outputData[i] << "\n";
  }

  outputFile.close();

  return 0;
}


float runInference(float* input, LSTM* lstm, float* lstmOut, int numUnits,
                   float* denseWeights, float* denseBias) {
  lstm->step(lstmOut, input);
  
  return dot(denseWeights, lstmOut, numUnits) + *denseBias;
}
