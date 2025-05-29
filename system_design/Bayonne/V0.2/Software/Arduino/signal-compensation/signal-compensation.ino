// Copyright ARTS Lab, 2024
// Smart sensing node with online signal compensation

#include "signal-compensation.h"
#include "lstm.h"
#include "linear-algebra.h"
#include <SD.h>
#include <SPI.h>

using sca3300_library::SCA3300;
using sca3300_library::OperationMode;
using sca3300_library::Axis;


File myFile;
unsigned int fileNameCount = 0;

const uint8_t LED_PIN = 3;  // Indicator LED pin
const uint8_t SCA3300_CHIP_SELECT = 1;  // Current PCB Chip Select
const uint8_t SD_CHIP_SELECT = 4;  // PCB Chip Select

constexpr uint32_t SPI_SPEED = 2000000;
constexpr size_t DATA_POINTS = 20000;

constexpr uint32_t FREQUENCY = 400;  // Sampling rate of the accelerometer (Hz)
constexpr uint32_t DELAY_TIME =
  static_cast<uint32_t>(((1.0 / FREQUENCY) * 1000000));  // Period (us)

SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, OperationMode::MODE3, true);
float data[DATA_POINTS];

LSTM* lstm;
float lstmOutput[NUMUNITS];

float* lstmWeights;
float* lstmBiases;
float* denseWeights;
float* denseBias;

float* wI;
float* wF;
float* wC;
float* wO;
float* bI;
float* bF;
float* bC;
float* bO;


void setup() {
  delay(5000);

  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);

  Serial.println("Initializing SD card...");

  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Unable to initialize SD Card.");
    return;
  }

  Serial.println("SD card initialized.");

  Serial.println("Loading model.");
  lstmWeights = new float[NUMUNITS * (NUMUNITS + INPUTSIZE) * 4];
  lstmBiases = new float[NUMUNITS * 4];
  denseWeights = new float[NUMUNITS];
  denseBias = new float;
  loadWeights(lstmWeights, lstmBiases, denseWeights, denseBias, NUMUNITS,
              INPUTSIZE);


  wI = &lstmWeights[0];
  wF = &lstmWeights[NUMUNITS * (NUMUNITS + INPUTSIZE)];
  wC = &lstmWeights[2 * NUMUNITS * (NUMUNITS + INPUTSIZE)];
  wO = &lstmWeights[3 * NUMUNITS * (NUMUNITS + INPUTSIZE)];

  bI = &lstmBiases[0];
  bF = &lstmBiases[NUMUNITS];
  bC = &lstmBiases[2 * NUMUNITS];
  bO = &lstmBiases[3 * NUMUNITS];

  lstm = new LSTM(NUMUNITS, INPUTSIZE, wI, wF, wC, wO, bI, bF, bC, bO);

  Serial.println("Model loaded.");
  sca3300.initChip();

  Serial.print("Sampling frequency:");
  Serial.println(1/((DELAY_TIME*.000001)+.00003487893522));
  Serial.print("Test length (s):");
  Serial.println(DATA_POINTS*((DELAY_TIME*.000001)+.00003487893522));

  // Let the accelerometer run for a while. This is a hotfix for a bug
  // in the driver.
  for (int i = 0; i < 10000; i++) {
    sca3300.getAccelRaw(Axis::Z);
  }
}


void loop() {
  digitalWrite(LED_PIN, HIGH);
  recordData(data, DELAY_TIME);
  char fileName[13];
  sprintf(fileName, "DATA%03d.csv", fileNameCount);
  writeSDConverted(data, fileName);

  lstm->reset();
  delay(2000);
}


void recordData(float* data, uint32_t delayTime) {
  unsigned long endTime;

  Serial.println("Start Recording");
 
  for (size_t i = 0; i < DATA_POINTS; ++i) {
    endTime = micros() + delayTime;

    data[i] = SCA3300::convertRawAccelToAccel(sca3300.getAccelRaw(Axis::Z),
                                              sca3300.getOperationMode());

    while (micros() < endTime) {
      // Do nothing
    }
  }

  Serial.println("Finish Recording");
}


void writeSDConverted(float* data,
                      char* fileName) {
  File dataFile = SD.open(fileName, FILE_WRITE);
  unsigned long startTime = millis();
  float convertedData = data[0];

  if (SD.exists(fileName)) {

    for (size_t i = 1; i < DATA_POINTS; ++i) {
      // Record raw data
      dataFile.print(convertedData, 32);
      dataFile.print(",");

      // Run inference
      dataFile.println(runInference(&convertedData), 32);
    }

    ++fileNameCount;
    dataFile.flush();
    dataFile.close();
    Serial.println("Finished writing to SD card.");
    Serial.printf("Data processed in %d ms.\n", millis() - startTime);

    for (int i = 0; i <= 5; i++) {
      digitalWrite(LED_PIN, HIGH);
      delay(200);
      digitalWrite(LED_PIN, LOW);
      delay(200);
    }
  } else {
    Serial.printf("Unable to create %c.\n", fileName);
  }
}


float runInference(float* input) {
    lstm->step(input, lstmOutput);
    return dot(lstmOutput, denseWeights, NUMUNITS) + *denseBias;
}

void loadWeights(float* lstmWeights, float* lstmBiases, float* denseWeights,
                 float* denseBias, int numUnits, int inputSize) {
  uint8_t buffer[4];
  int matrix_size = (numUnits + inputSize) * numUnits;

  // Load LSTM weight matrices
  File file = SD.open("model_binaries/lstm/wI.dat", FILE_READ);
  for (int i = 0; i < matrix_size; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&lstmWeights[i], buffer, 4);
  }

  file.close();

  file = SD.open("model_binaries/lstm/wF.dat", FILE_READ);
  for (int i = matrix_size; i < matrix_size * 2; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&lstmWeights[i], buffer, 4);
  }

  file.close();

  file = SD.open("model_binaries/lstm/wC.dat", FILE_READ);
  for (int i = matrix_size * 2; i < matrix_size * 3; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&lstmWeights[i], buffer, 4);
  }

  file.close();

  file = SD.open("model_binaries/lstm/wO.dat", FILE_READ);
  for (int i = matrix_size * 3; i < matrix_size * 4; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&lstmWeights[i], buffer, 4);
  }

  file.close();

  // Load LSTM bias vectors
  file = SD.open("model_binaries/lstm/bI.dat", FILE_READ);
  for (int i = 0; i < numUnits; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&lstmBiases[i], buffer, 4);
  }

  file.close();

  file = SD.open("model_binaries/lstm/bF.dat", FILE_READ);
  for (int i = numUnits; i < numUnits * 2; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&lstmBiases[i], buffer, 4);
  }

  file.close();

  file = SD.open("model_binaries/lstm/bC.dat", FILE_READ);
  for (int i = numUnits * 2; i < numUnits * 3; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&lstmBiases[i], buffer, 4);
  }

  file.close();

  file = SD.open("model_binaries/lstm/bO.dat", FILE_READ);
  for (int i = numUnits * 3; i < numUnits * 4; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&lstmBiases[i], buffer, 4);
  }

  file.close();

  // Load dense weights
  file = SD.open("model_binaries/dense_top/w.dat", FILE_READ);
  for (int i = 0; i < numUnits; i++) {
    for (int j = 0; j < 4; j++) {
      buffer[j] = file.read();
    }

    memcpy(&denseWeights, buffer, 4);
  }

  file.close();

  // Load dense bias
  file = SD.open("model_binaries/dense_top/b.dat", FILE_READ);
  for (int j = 0; j < 4; j++) {
    buffer[j] = file.read();
  }

  memcpy(&denseBias, buffer, 4);

  file.close();
}
