// Copyright (c) ARTS Lab, 2025

// Load the weights of the model from the binary files

#ifndef MODEL_LOADING_H
#define MODEL_LOADING_H

void loadWeights(float* lstmWeights, float* lstmBiases, float* denseWeights,
                 float* denseBias, int numUnits, int inputSize, int rank);

#endif  //MODEL_LOADING_H
