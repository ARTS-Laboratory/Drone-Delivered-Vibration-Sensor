/*
   Copyright 2020 ARTS_LAB

   Modified:
   - Triggered acquisition
   - Finds next available CSV filename on SD card
   - Timestamp written to SD starts at zero
   - LED ON during acquisition
   - LED flashes while writing to SD
   - LED OFF when complete
*/

#include <SCA3300.h>
#include <SD.h>

constexpr uint8_t SCA3300_CHIP_SELECT = 1;
constexpr uint8_t SD_CHIP_SELECT = 4;
constexpr uint8_t LED_PIN = 3;
constexpr uint8_t WRITE_PIN = 2;

constexpr uint32_t SPI_SPEED = 2000000;
constexpr size_t DATA_POINT = 74000;
constexpr uint32_t DELAY_TIME = 6722;

constexpr uint32_t LED_FLASH_INTERVAL = 250;

// Set axis and sign depending on which sensor you are uploading code to

// Top sensor package:
//const sca3300_library::Axis MEASURE_AXIS = sca3300_library::Axis::Z;
//constexpr int AXIS_SIGN = 1;

// Bottom sensor package:
const sca3300_library::Axis MEASURE_AXIS = sca3300_library::Axis::Y;
constexpr int AXIS_SIGN = -1;

sca3300_library::SCA3300 sca3300(
  SCA3300_CHIP_SELECT,
  SPI_SPEED,
  sca3300_library::OperationMode::MODE3,
  true
);

unsigned int fileNameCount = 0;

void findNextFileName(char* fileName);
void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime);
void writeSDConvertedWithBlink(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName);
void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode);

void setup() {
  Serial.begin(9600);

  pinMode(LED_PIN, OUTPUT);
  pinMode(WRITE_PIN, INPUT);

  digitalWrite(LED_PIN, LOW);

  Serial.println("Initializing SD Card...");

  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Card Failed, or NOT Present");

    while (true) {
      digitalWrite(LED_PIN, HIGH);
      delay(300);
      digitalWrite(LED_PIN, LOW);
      delay(300);
    }
  }

  Serial.println("SD Card Initialized.");

  sca3300.initChip();

  Serial.println("System Ready.");
  Serial.println("Waiting For Trigger...");
}

void loop() {
  while (digitalRead(WRITE_PIN) == LOW) {
    digitalWrite(LED_PIN, LOW);
  }

  Serial.println("Trigger Received");

  digitalWrite(LED_PIN, HIGH);

  int16_t data[DATA_POINT];
  uint32_t timeStamps[DATA_POINT];

  recordData(data, timeStamps, DELAY_TIME);

  char fileName[8];
  findNextFileName(fileName);

  writeSDConvertedWithBlink(data, timeStamps, sca3300.getOperationMode(), fileName);

  digitalWrite(LED_PIN, LOW);

  Serial.println("Logging Complete");
  Serial.println("Waiting For Trigger Release");

  while (digitalRead(WRITE_PIN) == HIGH) {
    delay(10);
  }

  Serial.println("Ready For New Trigger");
}

void findNextFileName(char* fileName) {
  while (true) {
    sprintf(fileName, "%03d.csv", fileNameCount);

    if (!SD.exists(fileName)) {
      return;
    }

    fileNameCount++;
  }
}

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime) {
  Serial.println("Start Recording");

  for (size_t i = 0; i < DATA_POINT; ++i) {
    data[i] = sca3300.getAccelRaw(MEASURE_AXIS);
    timeStamps[i] = micros();
    delayMicroseconds(delayTime);
  }

  Serial.println("Finish Recording");
}

void writeSDConvertedWithBlink(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName) {
  File dataFile = SD.open(fileName, FILE_WRITE);

  if (dataFile) {
    Serial.print("Writing To SD Card: ");
    Serial.println(fileName);

    bool ledState = HIGH;
    unsigned long lastBlinkTime = millis();

    uint32_t startTime = timeStamps[0];

    for (size_t i = 0; i < DATA_POINT; ++i) {
      unsigned long currentTime = millis();

      if (currentTime - lastBlinkTime >= LED_FLASH_INTERVAL) {
        ledState = !ledState;
        digitalWrite(LED_PIN, ledState);
        lastBlinkTime = currentTime;
      }

      uint32_t relativeTime = timeStamps[i] - startTime;

      dataFile.print(relativeTime);
      dataFile.print(",");

      double convertedData = sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);

      dataFile.println(convertedData, 7);
    }

    fileNameCount++;

    dataFile.flush();
    dataFile.close();

    Serial.println("Finish Writing To SD Card");
  }
  else {
    Serial.print("ERROR: Could Not Create ");
    Serial.println(fileName);

    while (true) {
      digitalWrite(LED_PIN, HIGH);
      delay(100);
      digitalWrite(LED_PIN, LOW);
      delay(100);
    }
  }
}

void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode) {
  uint32_t startTime = timeStamps[0];

  for (size_t i = 0; i < DATA_POINT; ++i) {
    double convertedData = sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);

    Serial.print(convertedData, 7);
    Serial.print(",");
    Serial.println(timeStamps[i] - startTime);
  }

  double frequencyAverage = static_cast<double>(DATA_POINT) / static_cast<double>(timeStamps[DATA_POINT - 1] - timeStamps[0]) * 1000000.0;

  Serial.print("Average Frequency: ");
  Serial.println(frequencyAverage);
}
