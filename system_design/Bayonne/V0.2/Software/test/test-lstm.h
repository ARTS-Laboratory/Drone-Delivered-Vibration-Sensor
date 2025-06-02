// Copyright (c) ARTS Lab, 2025

#ifndef TEST_LSTM_H
#define TEST_LSTM_H

#include "../Arduino/signal-compensation/lstm.h"
#include "../Arduino/signal-compensation/linear-algebra.h"

float runInference(float* input, LSTM* lstm, float* lstmOut, int numUnits,
                   float* denseWeights, float* denseBias);

#endif
