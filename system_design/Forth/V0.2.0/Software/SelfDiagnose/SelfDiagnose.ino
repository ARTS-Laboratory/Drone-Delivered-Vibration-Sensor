#include <SCA3300.h>
#include <SD.h>
#include <SPI.h>
#include <Wire.h>
#include <RTClib.h>

constexpr uint8_t SCA3300_CHIP_SELECT = 1;
constexpr uint8_t SD_CHIP_SELECT = 4;
constexpr uint8_t LED_PIN = 3;
constexpr uint32_t SPI_SPEED = 2000000;

const char FILE_NAME[] = "SYSCHK.TXT";

sca3300_library::SCA3300 sca3300(
  SCA3300_CHIP_SELECT,
  SPI_SPEED,
  sca3300_library::OperationMode::MODE3,
  true
);

RTC_DS3231 rtc;

void failBlink() {
  while (true) {
    digitalWrite(LED_PIN, HIGH);
    delay(300);
    digitalWrite(LED_PIN, LOW);
    delay(300);
  }
}

void setup() {
  Serial.begin(9600);
  while (!Serial) {}

  pinMode(LED_PIN, OUTPUT);
  pinMode(SD_CHIP_SELECT, OUTPUT);
  pinMode(SCA3300_CHIP_SELECT, OUTPUT);

  digitalWrite(LED_PIN, LOW);
  digitalWrite(SD_CHIP_SELECT, HIGH);
  digitalWrite(SCA3300_CHIP_SELECT, HIGH);

  Wire.begin();

  Serial.println("Starting system check...");

  Serial.print("Initializing SD card...");
  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Card failed, or not present");
    failBlink();
  }
  Serial.println("card initialized.");

  File checkFile = SD.open(FILE_NAME, FILE_WRITE);

  if (!checkFile) {
    Serial.println("error opening SYSCHK.TXT");
    failBlink();
  }

  checkFile.println("SYSTEM CHECK");
  checkFile.println("SD card checked successfully.");
  Serial.println("SD card checked successfully.");

  Serial.println("Checking RTC...");

  if (!rtc.begin()) {
    Serial.println("RTC not detected.");
    checkFile.println("RTC check FAILED.");
    checkFile.close();
    failBlink();
  }

  DateTime now = rtc.now();

  checkFile.println("RTC checked successfully.");
  checkFile.print("Timestamp: ");
  checkFile.print(now.year());
  checkFile.print("-");
  checkFile.print(now.month());
  checkFile.print("-");
  checkFile.print(now.day());
  checkFile.print(" ");
  checkFile.print(now.hour());
  checkFile.print(":");
  checkFile.print(now.minute());
  checkFile.print(":");
  checkFile.println(now.second());

  Serial.println("RTC checked successfully.");

  checkFile.flush();

  Serial.println("Checking accelerometer...");

  digitalWrite(SD_CHIP_SELECT, HIGH);
  digitalWrite(SCA3300_CHIP_SELECT, HIGH);
  delay(10);

  sca3300.initChip();

  delay(100);

  int16_t rawX = sca3300.getAccelRaw(sca3300_library::Axis::X);
  int16_t rawY = sca3300.getAccelRaw(sca3300_library::Axis::Y);
  int16_t rawZ = sca3300.getAccelRaw(sca3300_library::Axis::Z);

  uint32_t timeStamp = micros();

  double accelX = sca3300_library::SCA3300::convertRawAccelToAccel(rawX, sca3300.getOperationMode());
  double accelY = sca3300_library::SCA3300::convertRawAccelToAccel(rawY, sca3300.getOperationMode());
  double accelZ = sca3300_library::SCA3300::convertRawAccelToAccel(rawZ, sca3300.getOperationMode());

  checkFile.println("Accelerometer checked successfully.");
  checkFile.print("X Axis: ");
  checkFile.println(accelX, 7);
  checkFile.print("Y Axis: ");
  checkFile.println(accelY, 7);
  checkFile.print("Z Axis: ");
  checkFile.println(accelZ, 7);
  checkFile.print("Micros Timestamp: ");
  checkFile.println(timeStamp);

  checkFile.println("System check completed successfully.");
  checkFile.close();

  Serial.println("Accelerometer checked successfully.");
  Serial.println("SYSTEM CHECK PASSED");

  digitalWrite(LED_PIN, HIGH);
}

void loop() {
  int16_t rawX;
  int16_t rawY;
  int16_t rawZ;
  uint32_t timeStamp;

  rawX = sca3300.getAccelRaw(sca3300_library::Axis::X);
  rawY = sca3300.getAccelRaw(sca3300_library::Axis::Y);
  rawZ = sca3300.getAccelRaw(sca3300_library::Axis::Z);

  timeStamp = micros();

  double accelX = sca3300_library::SCA3300::convertRawAccelToAccel(rawX, sca3300.getOperationMode());
  double accelY = sca3300_library::SCA3300::convertRawAccelToAccel(rawY, sca3300.getOperationMode());
  double accelZ = sca3300_library::SCA3300::convertRawAccelToAccel(rawZ, sca3300.getOperationMode());

  Serial.print(accelX, 7);
  Serial.print(",");
  Serial.print(accelY, 7);
  Serial.print(",");
  Serial.println(accelZ, 7);
//  Serial.print(",");
//  Serial.println(timeStamp);

  delayMicroseconds(6722);
  delayMicroseconds(10000);
}
