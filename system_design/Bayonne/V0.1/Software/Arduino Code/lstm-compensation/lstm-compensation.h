// Copyright ARTS Lab, 2024

#ifndef LSTM_COMPENSATION_H
#define LSTM_COMPENSATION_H

#include <SCA3300.h>
using sca3300_library::OperationMode;

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime);

void writeSDConverted(int16_t* data, uint32_t* timeStamps,
                      OperationMode operationMode, char* fileName);

void printDataConverted(int16_t* data, uint32_t* timeStamps,
                        OperationMode operationMode);

#endif
