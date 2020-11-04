/*
   Copyright 2020 ARTS_LAB
*/

#include <SCA3300.h>
#include <SPI.h>
#include <SD.h>

const uint8_t SCA3300_CHIP_SELECT = 5;
const uint8_t SD_CHIP_SELECT = 10;
const uint8_t LED_PIN = 2;
const uint8_t WRITE_PIN = 3;
const uint32_t SPI_SPEED = 2000000; // typ. f_sck = 2 MHz
const size_t DATA_POINT = 222220;

sca3300_library::SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, sca3300_library::OperationMode::MODE3);

unsigned int fileNameCount = 0;

void recordData(int16_t* data, uint32_t* recordStartTime, uint32_t* recordEndTime);
void writeSD(int16_t* data, uint32_t* recordStartTime, uint32_t* recordEndTime, char* fileName);

void setup() {
	Serial.begin(9600);
	pinMode(LED_PIN, OUTPUT);
	sca3300.initChip(false);
	Serial.println("Initializing SD Card...");
	if (!SD.begin(BUILTIN_SDCARD)) {
		Serial.println("Card Failed, or NOT Present");
		return;
	}
	Serial.println("SD Card Initialized.");
}

void loop() {
	if (digitalRead(WRITE_PIN)) {
		digitalWrite(LED_PIN, HIGH);
		int16_t data[DATA_POINT];
		uint32_t recordStartTime = 0;
		uint32_t recordEndTime = 0;
		recordData(data, &recordStartTime, &recordEndTime);
		// generate file name
		char fileName[8];
		sprintf(fileName, "%03d.csv", fileNameCount);
		writeSD(data, &recordStartTime, &recordEndTime, fileName);
	}
}

void recordData(int16_t* data, uint32_t* recordStartTime, uint32_t* recordEndTime) {
	Serial.println("Start Recording");
	// record data
	*recordStartTime = millis();
	for (size_t i = 0; i < DATA_POINT; ++i) {
		data[i] = sca3300.getAccelRaw(sca3300_library::Axis::Z);
	}
	*recordEndTime = millis();
	Serial.println("Finish Recording");
}

void writeSD(int16_t* data, uint32_t* recordStartTime, uint32_t* recordEndTime, char* fileName) {
	File dataFile = SD.open(fileName, FILE_WRITE);
	if (SD.exists(fileName)) {
		dataFile.printf("%lu\n", 1 / (DATA_POINT / (*recordStartTime - *recordEndTime) * 1000));
		for (size_t i = 0; i < DATA_POINT; ++i) {
			dataFile.println(data[i]);
		}
		++fileNameCount;
		dataFile.flush();
		dataFile.close();
		Serial.println("Finish Writing to SD Card");
		digitalWrite(LED_PIN, LOW);
		Serial.print("Frequency:");
		Serial.println(DATA_POINT / ((*recordEndTime - *recordStartTime) * .001));
		Serial.println("_______________________________");
	}
	else {
		Serial.printf("%c NOT Created", fileName);
	}
}
