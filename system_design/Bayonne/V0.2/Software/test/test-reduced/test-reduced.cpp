// Copyright (c) ARTS Lab, 2025

// Simple testbench for the LSTM model

#include "test-reduced.h"
#include "../../Arduino/compressed-compensation/reduced-lstm.h"
#include "../../Arduino/compressed-compensation/linear-algebra.h"
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

  ifstream sampleData("measured_reduced.csv");

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

  ifstream trueData("reduced.csv");
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
  int rank = 50;
  int m = numUnits * 4;
  int n = numUnits + inputSize;

  // Dynamically declared, just like it is on edge.
  float* lstmWeights = new float[rank * n + ((m - rank) * rank)];
  float* lstmBias = new float[4 * numUnits];
  float* denseWeights = new float[numUnits];
  float* denseBias = new float;

  float* bI = &lstmBias[0];
  float* bF = &lstmBias[numUnits];
  float* bC = &lstmBias[2 * numUnits];
  float* bO = &lstmBias[3 * numUnits];

  cout << "Loading weights...\n";
  loadWeights(lstmWeights, lstmBias, denseWeights, denseBias, numUnits,
              inputSize, rank);

  float* b = lstmWeights;
  float* c = &lstmWeights[rank * (numUnits + inputSize)];

  cout << "Weights loaded.\n";

  ReducedLSTM *lstm =
      new ReducedLSTM(numUnits, inputSize, rank, b, c, bI, bF, bC, bO);

  float* lstmOut = new float[50];

  for (long unsigned int i = 0; i < inputData.size(); i++) {
    outputData[i] = runInference(&inputData[i], lstm, lstmOut, numUnits,
                                 denseWeights, denseBias);
  }

  ofstream outputFile("test-reduced-out.csv");

  for (long unsigned int i = 0; i < inputData.size(); i++) {
    outputFile << lstmTrue[i] << ",  " << outputData[i] << "\n";
  }

  outputFile.close();

  return 0;
}


float runInference(float* input, ReducedLSTM* lstm, float* lstmOut, int numUnits,
                   float* denseWeights, float* denseBias) {
  lstm->step(lstmOut, input);
  
  return dot(denseWeights, lstmOut, numUnits) + *denseBias;
}
