// Copyright (c) ARTS Lab, 2025

// Load the weights of the model from the binary files

#include "model-loading.h"
#include <fstream>

using std::ifstream;

void loadWeights(float* lstmWeights, float* lstmBiases, float* denseWeights,
                 float* denseBias, int numUnits, int inputSize) {
  ifstream wI("./model_binaries/lstm/wI.dat", std::ios::binary);
  ifstream wF("./model_binaries/lstm/wF.dat", std::ios::binary);
  ifstream wC("./model_binaries/lstm/wC.dat", std::ios::binary);
  ifstream wO("./model_binaries/lstm/wO.dat", std::ios::binary);
  
  ifstream bI("./model_binaries/lstm/bI.dat", std::ios::binary);
  ifstream bF("./model_binaries/lstm/bF.dat", std::ios::binary);
  ifstream bC("./model_binaries/lstm/bC.dat", std::ios::binary);
  ifstream bO("./model_binaries/lstm/bO.dat", std::ios::binary);

  ifstream denseW("./model_binaries/dense_top/w.dat", std::ios::binary);
  ifstream denseB("./model_binaries/dense_top/b.dat", std::ios::binary);

  int matrixSize = numUnits * (numUnits + inputSize);
  int typeSize = sizeof(float);

  // Read the LSTM weight matrices
  wI.read(reinterpret_cast<char*>(&lstmWeights[0]),
                                  matrixSize * typeSize);

  wF.read(reinterpret_cast<char*>(&lstmWeights[matrixSize]),
                                  matrixSize * typeSize);

  wC.read(reinterpret_cast<char*>(&lstmWeights[matrixSize * 2]),
                                  matrixSize * typeSize);

  wO.read(reinterpret_cast<char*>(&lstmWeights[matrixSize * 3]),
                                  matrixSize * typeSize);


  // Read the LSTM bias
  bI.read(reinterpret_cast<char*>(&lstmBiases[0]),
                                  numUnits * typeSize);

  bF.read(reinterpret_cast<char*>(&lstmBiases[numUnits]),
                                  numUnits * typeSize);

  bC.read(reinterpret_cast<char*>(&lstmBiases[numUnits * 2]),
                                  numUnits * typeSize);

  bO.read(reinterpret_cast<char*>(&lstmBiases[numUnits * 3]),
                                  numUnits * typeSize);

  // Read the dense weights and biases
  denseW.read(reinterpret_cast<char*>(denseWeights), numUnits * typeSize);
  denseB.read(reinterpret_cast<char*>(denseBias), typeSize);
}
