// Copyright ARTS Lab, 2024

#ifndef LSTM_COMPENSATION_H
#define LSTM_COMPENSATION_H

#define NUMUNITS 50
#define INPUTSIZE 1

#include <SCA3300.h>
#include "reduced-lstm.h"

using sca3300_library::OperationMode;

void recordData(float* data, uint32_t delayTime);

void writeSDConverted(float* data, char* fileName);

void printDataConverted(int16_t* data, OperationMode operationMode);

void loadWeights(float* lstmWeights, float* lstmBias, float* denseWeights,
                 float* denseBias);

float runInference(float* input);

#endif  // LSTM_COMPENSATION_H
