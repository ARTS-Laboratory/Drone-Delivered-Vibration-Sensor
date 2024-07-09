// ARTS Lab, 2024

#include "linear-algebra.h"

// Calculate the dot product of two vectors
float edgeML::dotProduct(float* vectorA, float* vectorB,
                           float* destination, int vectorSize) {
  float output = 0;

  for (int i = 0; i < vectorSize; i++) {
    output += vectorA[i] * vectorB[i];
  }

  return output;
}

// Multiply a vector with a column major matrix and add a bias vector
void edgeML::vectorMatTmultiply(float* vector, float** matrix,
                                float* bias, float* destination, int vectorSize,
                                int matrixNumRows) {
  for (int i = 0; i < matrixNumRows; i++) {
    destination[i] = dotProduct(vector, matrix[i], destination, vectorSize) +
                     bias[i];
  }
}

// Linear approximation of sigm(x)
float edgeML::sigmoid(float x) {
  if (x < -5.0) {
    return 0;
  } else if (x > -5 && x < -4) {
    return 0.0002899522617640371 * (x - -5) + 4.539786870244589e-05;
  } else if (x > -4 && x < -3.0) {
    return 0.002137273026168285 * (x - -4) + 0.000335350130466483;
  } else if (x > -3.0 && x < -2.75) {
    return 0.006390058237045526 * (x - -3.0) + 0.002472623156634768;
  } else if (x > -2.75 && x < -2.5) {
    return 0.010490852833554776 * (x - -2.75) + 0.004070137715896149;
  } else if (x > -2.5 && x < -2.25) {
    return 0.01717636682523338 * (x - -2.5) + 0.006692850924284843;
  } else if (x > -2.25 && x < -2.0) {
    return 0.02799706932599344 * (x - -2.25) + 0.010986942630593188;
  } else if (x > -2.0 && x < -1.75) {
    return 0.04530408315705903 * (x - -2.0) + 0.01798620996209155;
  } else if (x > -1.75 && x < -1.5) {
    return 0.07245456970484199 * (x - -1.75) + 0.029312230751356305;
  } else if (x > -1.5 && x < -1.25) {
    return 0.11372922737470703 * (x - -1.5) + 0.0474258731775668;
  } else if (x > -1.25 && x < -1.0) {
    return 0.17337896800349606 * (x - -1.25) + 0.07585818002124356;
  } else if (x > -1.0 && x < -0.75) {
    return 0.2528904071369551 * (x - -1.0) + 0.11920292202211757;
  } else if (x > -0.75 && x < -0.5) {
    return 0.346063590254555 * (x - -0.75) + 0.18242552380635635;
  } else if (x > -0.5 && x < -0.25) {
    return 0.4343969897126012 * (x - -0.5) + 0.2689414213699951;
  } else if (x > -0.25 && x < 0.0) {
    return 0.4898373248074184 * (x - -0.25) + 0.3775406687981454;
  } else if (x > 0.0 && x < 0.25) {
    return 0.4898373248074184 * (x - 0.0) + 0.5;
  } else if (x > 0.25 && x < 0.5) {
    return 0.4343969897126012 * (x - 0.25) + 0.6224593312018546;
  } else if (x > 0.5 && x < 0.75) {
    return 0.346063590254555 * (x - 0.5) + 0.7310585786300049;
  } else if (x > 0.75 && x < 1.0) {
    return 0.2528904071369551 * (x - 0.75) + 0.8175744761936437;
  } else if (x > 1.0 && x < 1.25) {
    return 0.17337896800349606 * (x - 1.0) + 0.8807970779778824;
  } else if (x > 1.25 && x < 1.5) {
    return 0.11372922737470725 * (x - 1.25) + 0.9241418199787564;
  } else if (x > 1.5 && x < 1.75) {
    return 0.07245456970484199 * (x - 1.5) + 0.9525741268224333;
  } else if (x > 1.75 && x < 2.0) {
    return 0.045304083157058805 * (x - 1.75) + 0.9706877692486438;
  } else if (x > 2.0 && x < 2.25) {
    return 0.02799706932599344 * (x - 2.0) + 0.9820137900379085;
  } else if (x > 2.25 && x < 2.5) {
    return 0.01717636682523338 * (x - 2.25) + 0.9890130573694068;
  } else if (x > 2.5 && x < 2.75) {
    return 0.010490852833554776 * (x - 2.5) + 0.9933071490757152;
  } else if (x > 2.75 && x < 3) {
    return 0.006390058237045526 * (x - 2.75) + 0.9959298622841039;
  } else if (x > 3 && x < 4) {
    return 0.002137273026168285 * (x - 3) + 0.9975273768433652;
  } else if (x > 4 && x < 5) {
    return 0.0002899522617639816 * (x - 4) + 0.9996646498695335;
  } else {
    return 1;
  }
}

// Linear approximation of tanh(x) using sigmoid
float edgeML::hypertan(float x) {
  return 2 * sigmoid(x) - 1;
}
