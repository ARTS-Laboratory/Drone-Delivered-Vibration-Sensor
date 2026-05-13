// Copyright ARTS Lab, 2025
// Dataset collection for training signal compensation models

#include "dataset-collection.h"
#include <SCA3300.h>
#include <SD.h>
#include <SPI.h>

using sca3300_library::SCA3300;
using sca3300_library::OperationMode;

// now file name will be updated based on last file name saved in SD card
unsigned int readFileCounter() {
  if (SD.exists("counter.txt")) {
    File f = SD.open("counter.txt", FILE_READ);
    if (f) {
      unsigned int val = f.parseInt();
      f.close();
      return val;
    }
  }
  return 0; // default if file doesn't exist
}

void writeFileCounter(unsigned int val) {
  File f = SD.open("counter.txt", FILE_WRITE); //opens file
  if (f) {
    f.seek(0); // overwrites from beginning instead of appending
    f.print(val); // writes new value from the position set by seek(0)
    f.close();
  }
}


File myFile;
unsigned int fileNameCount;

const uint8_t LED_PIN = 3;  // Indicator LED pin
const uint8_t SCA3300_CHIP_SELECT = 1;  // Current PCB Chip Select
const uint8_t SD_CHIP_SELECT = 4;  // PCB Chip Select
const uint8_t TRIGGER_PIN = 2;

constexpr uint32_t SPI_SPEED = 2000000;
constexpr size_t DATA_POINTS = 12000; // 12,000 is 30 sec, 120,000 is 5 min

constexpr uint32_t FREQUENCY = 400;  // Sampling rate of the accelerometer (Hz)
constexpr uint32_t DELAY_TIME =
  static_cast<uint32_t>(((1.0 / FREQUENCY) * 1000000));  // Period (us)

// top sensor package -> Y-axis ; bottom sensor package -> Z-axis
// When uploading this code, comment out whichever axis you're not using depending on top or bottom sensor
//const sca3300_library::Axis MEASURE_AXIS = sca3300_library::Axis::Y;
const sca3300_library::Axis MEASURE_AXIS = sca3300_library::Axis::Z;

SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, OperationMode::MODE3, true);
int16_t data[DATA_POINTS];

void setup() {
  delay(5000);

  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);
  pinMode(TRIGGER_PIN, INPUT);


  Serial.println("Initializing SD card...");

  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Unable to initialize SD Card.");
    return;
  }

  Serial.println("SD card initialized.");
  sca3300.initChip();

  Serial.print("Sampling frequency:");
  Serial.println(1/((DELAY_TIME*.000001)));
  Serial.print("Test length (s):");
  Serial.println(DATA_POINTS*((DELAY_TIME*.000001)));

  // Let the accelerometer run for a while. This is a hotfix for a bug
  // in the driver.
  for (int i = 0; i < 10000; i++) {
    sca3300.getAccelRaw(MEASURE_AXIS);
  }

  fileNameCount = readFileCounter();
  Serial.print("Starting file counter at: ");
  Serial.println(fileNameCount);
}

void loop() {

  // Wait for trigger to record data
  while (digitalRead(TRIGGER_PIN) == LOW) {
    // Do nothing
  }

  digitalWrite(LED_PIN, HIGH);
  recordData(data, DELAY_TIME);
  char fileName[20];
  sprintf(fileName, "DATA%03d.csv", fileNameCount);
  writeSDConverted(data, sca3300.getOperationMode(), fileName);
  fileNameCount++; //increment AFTER writing
  writeFileCounter(fileNameCount); // put on SD
  // Wait for 15 seconds to give enough time to setup the next test
  delay(15000);
}

void recordData(int16_t* data, uint32_t delayTime) {
  unsigned long endTime;

  Serial.println("Start Recording");
 
  for (size_t i = 0; i < DATA_POINTS; ++i) {
    endTime = micros() + delayTime;

    data[i] = sca3300.getAccelRaw(MEASURE_AXIS);

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

  if (dataFile) {
    for (size_t i = 0; i < DATA_POINTS; ++i) {
      float convertedData =
        -SCA3300::convertRawAccelToAccel(data[i], operationMode);
        // negative symbol above to account for flipped axis
      // Record raw data
      dataFile.print(convertedData, 32);
      dataFile.println();
    }

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
    Serial.printf("Unable to create %s.\n", fileName);
  }
}
