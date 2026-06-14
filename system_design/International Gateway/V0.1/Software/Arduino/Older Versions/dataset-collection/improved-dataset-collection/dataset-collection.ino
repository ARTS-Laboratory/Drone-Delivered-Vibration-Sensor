// Copyright ARTS Lab, 2025
// Dataset collection for training signal compensation models

#include "dataset-collection.h"
#include <SCA3300.h>
#include <SD.h>
#include <SPI.h>

using sca3300_library::SCA3300;
using sca3300_library::OperationMode;


File myFile;
unsigned int fileNameCount = 0;

const uint8_t LED_PIN = 3;              // Indicator LED pin
const uint8_t SCA3300_CHIP_SELECT = 1;  // Current PCB Chip Select
const uint8_t SD_CHIP_SELECT = 4;       // PCB Chip Select
const uint8_t TRIGGER_PIN = 2;
// DETECT_TRIGGER is currently the same pin as LED 
const uint8_t DETECT_TRIGGER = 3;

constexpr uint32_t SPI_SPEED = 2000000;
constexpr size_t DATA_POINTS = 120000;

constexpr uint32_t FREQUENCY = 400;  // Sampling rate of the accelerometer (Hz)
constexpr uint32_t DELAY_TIME =
  static_cast<uint32_t>(((1.0 / FREQUENCY) * 1000000));  // Period (us)

SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, OperationMode::MODE3, true);
int16_t data[DATA_POINTS];

void setup() {
  delay(5000);

  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);
  pinMode(TRIGGER_PIN, INPUT);
  pinMode(DETECT_TRIGGER, OUTPUT);

  Serial.println("Initializing SD card...");

  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Unable to initialize SD Card.");
    return;
  }

  Serial.println("SD card initialized.");
  sca3300.initChip();

  Serial.print("Sampling frequency:");
  Serial.println(FREQUENCY);
  Serial.print("Test length (s):");
  Serial.println(DATA_POINTS * ((DELAY_TIME * .000001)));

  // Let the accelerometer run for a while. This is a hotfix for a bug
  // in the driver.
  for (int i = 0; i < 10000; i++) {
    sca3300.getAccelRaw(sca3300_library::Axis::Z);
  }
}
void loop() {
  recordData(data, DELAY_TIME);
  char fileName[13];
  sprintf(fileName, "DATA%03d.csv", fileNameCount);
  writeSDConverted(data, sca3300.getOperationMode(), fileName);

  // Wait for 15 seconds to give enough time to setup the next test
  delay(15000);
}

/*
@author Davis Breci
*/
void recordData(int16_t* data, uint32_t delayTime) {
// non-time-sensitive code executes before time-critical sections
  Serial.println("Start Recording");
  unsigned long endTime;
  size_t i;

// wait for trigger
  while (digitalReadFast(TRIGGER_PIN) == LOW) {
    // Do nothing
  }

// for testing trigger latency
  // digitalWriteFast(DETECT_TRIGGER, HIGH);

/*
critical that both teensys' start times are as close as possible.
oscilloscope-measured start delay is approximately 2ns.
*/
  unsigned long startTime = micros();
/*
the goal of the following loop is to simulate a function generator.
all sampling intervals are within a few cpu cycles (0-5ns) of being perfectly consistent,
and any small imperfection in one interval does not affect the next.
*/
  for (i = 0; i < DATA_POINTS; ++i) {
// data write
    data[i] = sca3300.getAccelRaw(sca3300_library::Axis::Z);
// end time for each interval is relative to the initial start time, not the end of the previous interval
    endTime = startTime + (i + 1) * delayTime;
// wait out the rest of the interval
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
      dataFile.print(convertedData, 32);
      dataFile.println();
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
