// Copyright (c) ARTS Lab, 2025

#ifndef TEST_LSTM_H
#define TEST_LSTM_H

#include "../../Arduino/compressed-compensation/reduced-lstm.h"

float runInference(float* input, ReducedLSTM* lstm, float* lstmOut, int numUnits,
                   float* denseWeights, float* denseBias);

#endif
