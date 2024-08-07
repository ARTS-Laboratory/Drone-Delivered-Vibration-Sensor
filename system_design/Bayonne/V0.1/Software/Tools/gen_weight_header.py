# Generates a header file with the weights for the model

# Run this script in the Software/ directory, and make sure the model is
# present in .csv format in the Weights/ directory.

import numpy as np


def main():
    lstm_dir = 'Weights/0_lstm/'
    dense_dir = 'Weights/1_dense/'
    input_size = 1
    numUnits = 50

    lstm_w = arr_2D_to_C(np.loadtxt(lstm_dir + "mergedW.csv", delimiter=','))
    lstm_b = arr_1D_to_C(np.loadtxt(lstm_dir + "b.csv", delimiter=','))

    dense_w = arr_1D_to_C(np.loadtxt(dense_dir + "weights.csv", delimiter=','))

    with open(dense_dir + 'bias.csv') as file:
        dense_b = file.read().strip('\n')

    file_contents = f"""
// LSTM model header file
// Generated by gen_weight_header.py
#ifndef MODELWEIGHTS
#define MODELWEIGHTS

#define NUMUNITS {numUnits}
#define INPUTSIZE {input_size}

float lstmW[][{numUnits + input_size}] = {lstm_w};
float lstmB[] = {lstm_b};
float denseW[] = {dense_w};
float denseB = {dense_b};

#endif  // MODELWEIGHTS
"""
    with open('Arduino/test.h', 'w') as file:
        file.write(file_contents)


# Converts a 1D numpy array into a C array literal
def arr_1D_to_C(array) -> str:
    output = '{'

    for number in array:
        output += str(number) + ','

    return output[:-1] + '}'


# Converts a 2D numpy array into a C array literal
def arr_2D_to_C(array) -> str:
    output = '{'

    for row in array:
        output += arr_1D_to_C(row) + ','

    return output[:-1] + '}'


if __name__ == '__main__':
    main()
