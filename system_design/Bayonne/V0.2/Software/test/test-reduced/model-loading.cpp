// Copyright (c) ARTS Lab, 2025

// Load the weights of the model from the binary files

#include "model-loading.h"
#include <fstream>

using std::ifstream;

void loadWeights(float* lstmWeights, float* lstmBiases, float* denseWeights,
                 float* denseBias, int numUnits, int inputSize, int rank) {
  ifstream b("./model_binaries/reduced-lstm/b.dat", std::ios::binary);
  ifstream c("./model_binaries/reduced-lstm/c.dat", std::ios::binary);
  
  ifstream bI("./model_binaries/lstm/bI.dat", std::ios::binary);
  ifstream bF("./model_binaries/lstm/bF.dat", std::ios::binary);
  ifstream bC("./model_binaries/lstm/bC.dat", std::ios::binary);
  ifstream bO("./model_binaries/lstm/bO.dat", std::ios::binary);

  ifstream denseW("./model_binaries/dense_top/w.dat", std::ios::binary);
  ifstream denseB("./model_binaries/dense_top/b.dat", std::ios::binary);

  int bMatrixSize = rank * (numUnits + inputSize);
  int cMatrixSize = ((numUnits * 4) - rank) * rank;
  int typeSize = sizeof(float);

  // Read the LSTM weight matrices
  b.read(reinterpret_cast<char*>(lstmWeights), bMatrixSize * typeSize);
  c.read(reinterpret_cast<char*>(&lstmWeights[bMatrixSize]), cMatrixSize * typeSize);

  // Read the LSTM bias
  bI.read(reinterpret_cast<char *>(&lstmBiases[0]), numUnits * typeSize);

  bF.read(reinterpret_cast<char *>(&lstmBiases[numUnits]), numUnits * typeSize);

  bC.read(reinterpret_cast<char *>(&lstmBiases[numUnits * 2]),
                                   numUnits * typeSize);

  bO.read(reinterpret_cast<char *>(&lstmBiases[numUnits * 3]),
                                   numUnits * typeSize);

  // Read the dense weights and biases
  denseW.read(reinterpret_cast<char*>(denseWeights), numUnits * typeSize);
  denseB.read(reinterpret_cast<char*>(denseBias), typeSize);
}
