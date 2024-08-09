// Copyright ARTS Lab, 2024
// Smart sensing node with online signal compensation

#include "lstm-compensation.h"
#include "lstm.h"
#include "linear-algebra.h"
#include "model-weights.h"
#include <SCA3300.h>
#include <SD.h>
#include <SPI.h>

using edgeML::LSTM;
using edgeML::dotProduct;
using sca3300_library::SCA3300;
using sca3300_library::OperationMode;


File myFile;
unsigned int fileNameCount = 0;

const uint8_t LED_PIN = 3;  // Indicator LED pin
const uint8_t SCA3300_CHIP_SELECT = 1;  // Current PCB Chip Select
const uint8_t SD_CHIP_SELECT = 4;  // PCB Chip Select

constexpr uint32_t SPI_SPEED = 2000000;
constexpr size_t DATA_POINTS = 20000;

constexpr uint32_t FREQUENCY = 1600;  // Sampling rate of the accelerometer (Hz)
constexpr uint32_t DELAY_TIME =
  static_cast<uint32_t>(((1.0 / FREQUENCY) * 1000000);  // Period (us)

SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, OperationMode::MODE3, true);
int16_t data[DATA_POINTS];


LSTM* lstm;
float lstmOutput[NUMUNITS];

void setup() {
  delay(5000);

  Serial.begin(9600);
  pinMode(TRIG_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);

  // Generate pointers to the lstm weight matrix
  Serial.println("Loading Model...");
  float** lstmWeightMatrix = new float*[NUMUNITS * 4];

  for (int i = 0; i < 4 * NUMUNITS; i++) {
    lstmWeightMatrix[i] = lstmW[i];
  }

  lstm = new LSTM(NUMUNITS, INPUTSIZE, lstmWeightMatrix, lstmB);
  Serial.println("Model loaded.");

  Serial.println("Initializing SD card...");

  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Unable to initialize SD Card.");
    return;
  }

  Serial.println("SD card initialized.");
  sca3300.initChip();

  Serial.print("Sampling frequency:");
  Serial.println(1/((DELAY_TIME*.000001)+.00003487893522));
  Serial.print("Test length (s):");
  Serial.println(DATA_POINTS*((DELAY_TIME*.000001)+.00003487893522));

  // Let the accelerometer run for a while. This is a hotfix for a bug
  // in the driver.
  for (int i = 0; i < 10000; i++) {
    sca3300.getAccelRaw(sca3300_library::Axis::Z);
  }
}

void loop() {
  digitalWrite(LED_PIN, HIGH);
  recordData(data, DELAY_TIME);
  char fileName[13];
  sprintf(fileName, "DATA%03d.csv", fileNameCount);
  writeSDConverted(data, sca3300.getOperationMode(), fileName);

  lstm.resetState();
  delay(2000);
}

void recordData(int16_t* data, uint32_t delayTime) {
  unsigned long endTime;
  Serial.println("Start Recording");
 
  for (size_t i = 0; i < DATA_POINTS; ++i) {
    endTime = micros() + delayTime;
    data[i] = sca3300.getAccelRaw(sca3300_library::Axis::Z);

    while (micros() < endTime) {
      // Do nothing
    }
  }

  Serial.println("Finish Recording");
}

void writeSDConverted(int16_t* data,
                      sca3300_library::OperationMode operationMode,
                      char* fileName) {
  File dataFile = SD.open(fileName, FILE_WRITE);
  unsigned long startTime = millis();

  if (SD.exists(fileName)) {

    for (size_t i = 0; i < DATA_POINTS; ++i) {
      float convertedData =
        SCA3300::convertRawAccelToAccel(data[i], operationMode) - 1;

      // Record raw data
      dataFile.print(convertedData, 7);
      dataFile.print(",");

      // Run inference
      dataFile.println(runInference(&convertedData), 7);
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
    lstm->step(&convertedData, lstmOutput);
    return dotProduct(lstmOutput, denseW, NUMUNITS) + denseB;
}
