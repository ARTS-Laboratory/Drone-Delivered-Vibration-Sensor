/*
   Copyright 2020 ARTS_LAB
*/

#include <SCA3300.h>
#include <SD.h>

constexpr uint8_t SCA3300_CHIP_SELECT = 5; //PCB Chip Select
//const uint8_t SCA3300_CHIP_SELECT = 10; //Development Board Chip Select
constexpr uint8_t SD_CHIP_SELECT = 10;
//constexpr uint8_t LED_PIN = 2;
constexpr uint8_t WRITE_PIN = 3;
constexpr uint32_t SPI_SPEED = 2000000; // typ. f_sck = 2 MHz
//const size_t DATA_POINT = 222220;
constexpr size_t DATA_POINT = 70000; // 74295
constexpr uint32_t DELAY_TIME = 0;
// MODE#1 is 3G
// MODE#3 is 1.5G
sca3300_library::SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, sca3300_library::OperationMode::MODE3, true); // MODE#1 is 3G

unsigned int fileNameCount = 0;

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime);
void writeSDRaw(int16_t* data, uint32_t* timeStamps, char* fileName);
void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName);
void printDataRaw(int16_t* data, uint32_t* timeStamps);
void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode);

void setup() {
	Serial.begin(9600);
	//pinMode(LED_PIN, OUTPUT);
	Serial.println("Initializing SD Card...");
	if (!SD.begin(SD_CHIP_SELECT)) {
		Serial.println("Card Failed, or NOT Present");
		return;
	}
	Serial.println("SD Card Initialized.");
	sca3300.initChip();
}

void loop() {
	//digitalWrite(LED_PIN, HIGH);
	int16_t data[DATA_POINT];
	uint32_t timeStamps[DATA_POINT];
	recordData(data, timeStamps, DELAY_TIME);
	// generate file name
	char fileName[8];
	sprintf(fileName, "%03d.csv", fileNameCount);
	writeSDConverted(data, timeStamps, sca3300.getOperationMode(), fileName);
	//printDataRaw(data, timeStamps);
	printDataConverted(data, timeStamps, sca3300.getOperationMode());
}

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime) {
	Serial.println("Start Recording");
	// record data
	for (size_t i = 0; i < DATA_POINT; ++i) {
		data[i] = sca3300.getAccelRaw(sca3300_library::Axis::Z);
		timeStamps[i] = micros();
		delayMicroseconds(delayTime);
	}
	Serial.println("Finish Recording");
}

void writeSDRaw(int16_t* data, uint32_t* timeStamps, char* fileName) {
	File dataFile = SD.open(fileName, FILE_WRITE);
	if (SD.exists(fileName)) {
		for (size_t i = 0; i < DATA_POINT; ++i) {
			//dataFile.printf("%d, %llu\n", data[i], timeStamps[i]);
			dataFile.print(data[i]);
			dataFile.print(",");
			dataFile.println(timeStamps[i]);
		}
		++fileNameCount;
		dataFile.flush();
		dataFile.close();
		Serial.println("Finish Writing to SD Card");
	}
	else {
		Serial.printf("%c NOT Created", fileName);
	}
}

void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName) {
	File dataFile = SD.open(fileName, FILE_WRITE);
	if (SD.exists(fileName)) {
		for (size_t i = 0; i < DATA_POINT; ++i) {
			double convertedData = sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);
			//dataFile.printf("%Lf, %llu\n", convertedData, timeStamps[i]);
			dataFile.print(convertedData, 7);
			dataFile.print(",");
			dataFile.println(timeStamps[i]);
		}
		++fileNameCount;
		dataFile.flush();
		dataFile.close();
		Serial.println("Finish Writing to SD Card");
		//digitalWrite(LED_PIN, LOW);
	}
	else {
		Serial.printf("%c NOT Created", fileName);
	}
}


void printDataRaw(int16_t* data, uint32_t* timeStamps) {
	for (size_t i = 0; i < DATA_POINT; ++i) {
		//Serial.printf("%d, %llu\n", data[i], timeStamps[i]);
		Serial.print(data[i]);
		Serial.print(",");
		Serial.println(timeStamps[i]);
	}
	double frequencyAverage = static_cast<double>(DATA_POINT) / static_cast<double>(timeStamps[DATA_POINT - 1] - timeStamps[0]) * 1000000.0;
	Serial.print("Average Frequency: ");
	Serial.println(frequencyAverage);
}

void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode) {
	for (size_t i = 0; i < DATA_POINT; ++i) {
		double convertedData = sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);
		//Serial.printf("%Lf, %llu\n", convertedData, timeStamps[i]);
		Serial.print(convertedData, 7);
		Serial.print(",");
		Serial.println(timeStamps[i]);
	}
	double frequencyAverage = static_cast<double>(DATA_POINT)/static_cast<double>(timeStamps[DATA_POINT-1] - timeStamps[0]) * 1000000.0;
	Serial.print("Average Frequency: ");
	Serial.println(frequencyAverage);
}
