// Copyright (c) ARTS Lab, 2025

// Simple testbench for the LSTM model

#include "test-lstm.h"
#include "../../Arduino/signal-compensation/lstm.h"
#include "../../Arduino/signal-compensation/linear-algebra.h"
#include "model-loading.h"
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
#include <math.h>

using std::ifstream;
using std::ofstream;
using std::vector;
using std::cout;
using std::string;


int main() {
  vector<float> inputData;

  ifstream sampleData("measured.csv");

  if (!sampleData.is_open()) {
    cout << "The data file cannot be opened.\n";
    return 1;
  }


  string line;
  while (std::getline(sampleData, line)) {
    try {
      inputData.push_back(std::stof(line));
    } catch (const std::invalid_argument& e) {
      std::cerr << "This float could not be read.\n"; 
    } catch (const std::out_of_range& e) {
      std::cerr << "This float is out of range.\n";
    }
  }

  vector<float> lstmTrue;

  ifstream trueData("uncompressed.csv");
  while (std::getline(trueData, line)) {
    try {
      lstmTrue.push_back(std::stof(line));
    } catch (const std::invalid_argument& e) {
      std::cerr << "This float could not be read.\n"; 
    } catch (const std::out_of_range& e) {
      std::cerr << "This float is out of range.\n";
    }
  }


  vector<float> outputData = inputData;
  
  int numUnits = 50;
  int inputSize = 1;

  // Dynamically declared, just like it is on edge.
  float* lstmWeights = new float[4 * numUnits * (numUnits + inputSize)];
  float* lstmBias = new float[4 * numUnits];
  float* denseWeights = new float[numUnits];
  float* denseBias = new float;

  float* bI = &lstmBias[0];
  float* bF = &lstmBias[NUMUNITS];
  float* bC = &lstmBias[2 * NUMUNITS];
  float* bO = &lstmBias[3 * NUMUNITS];

  cout << "Loading weights...\n";
  loadWeights(lstmWeights, lstmBias, denseWeights, denseBias, numUnits,
              inputSize);

  cout << "Weights loaded.\n";

  LSTM* lstm = new LSTM(NUMUNITS, INPUTSIZE, lstmWeights, bI, bF, bC, bO);

  // float lstmOut[50];
  float* lstmOut = new float[50];

  for (long unsigned int i = 0; i < inputData.size(); i++) {
    outputData[i] = runInference(&inputData[i], lstm, lstmOut, numUnits,
                                 denseWeights, denseBias);
  }

  ofstream outputFile("test-lstm-out.csv");

  for (long unsigned int i = 0; i < inputData.size(); i++) {
    outputFile << lstmTrue[i] << ",  " << outputData[i] << "\n";
  }

  outputFile.close();

  return 0;
}


float runInference(float* input, LSTM* lstm, float* lstmOut, int numUnits,
                   float* denseWeights, float* denseBias) {
  lstm->step(lstmOut, input);
  
  return dot(denseWeights, lstmOut, numUnits) + *denseBias;
}
