// Copyright ARTS Lab, 2024

#ifndef LSTM_COMPENSATION_H
#define LSTM_COMPENSATION_H

#include <SCA3300.h>
#include "reduced-lstm.h"

using sca3300_library::OperationMode;
using edgeML::ReducedLSTM;

void recordData(float* data, uint32_t delayTime);

void writeSDConverted(float* data, char* fileName);

void printDataConverted(int16_t* data, OperationMode operationMode);

float runInference(float* input);

#endif  // LSTM_COMPENSATION_H
