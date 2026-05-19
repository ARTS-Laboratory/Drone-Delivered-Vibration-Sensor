/*
   Copyright 2026 ARTS_LAB
*/

#include <SCA3300.h>
#include <SD.h>

constexpr uint8_t SCA3300_CHIP_SELECT = 5; //PCB Chip Select
//const uint8_t SCA3300_CHIP_SELECT = 10; //Development Board Chip Select
constexpr uint8_t SD_CHIP_SELECT = 10;
//constexpr uint8_t LED_PIN = 2;
constexpr uint32_t SPI_SPEED = 2000000; // typ. f_sck = 2 MHz
//const size_t DATA_POINT = 222220;
constexpr size_t DATA_POINT = 74000; // 74295 Samples
constexpr uint8_t TRIGGER_PIN = 2;

// Set axis and sign depending on which sensor you are uploading code to

// Top sensor package:
// const sca3300_library::Axis MEASURE_AXIS = sca3300_library::Axis::Z;
// constexpr int AXIS_SIGN = 1;

// Bottom sensor package:
// const sca3300_library::Axis MEASURE_AXIS = sca3300_library::Axis::Y;
// constexpr int AXIS_SIGN = -1;


//constexpr uint32_t DELAY_TIME = 0;
constexpr uint32_t DELAY_TIME = 6722;  //MicroSeconds

// MODE#1 is 3G
// MODE#3 is 1.5G
sca3300_library::SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, sca3300_library::OperationMode::MODE3, true); // MODE#1 is 3G

unsigned int fileNameCount;

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime);
void writeSDRaw(int16_t* data, uint32_t* timeStamps, char* fileName);
void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName);
void printDataRaw(int16_t* data, uint32_t* timeStamps);
void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode);

unsigned int readFileCounter();
void writeFileCounter(unsigned int val);

void setup() {
	Serial.begin(9600);
	//pinMode(LED_PIN, OUTPUT);

  pinMode(TRIGGER_PIN, INPUT);
 
	Serial.println("Initializing SD Card...");
	if (!SD.begin(SD_CHIP_SELECT)) {
		Serial.println("Card Failed, or NOT Present");
		return;
	}
	Serial.println("SD Card Initialized.");
	sca3300.initChip();
  
  fileNameCount = readFileCounter();
  Serial.print("Starting file counter at: ");
  Serial.println(fileNameCount);
}

void loop() {
  
  while (digitalRead(TRIGGER_PIN) == LOW) {
    // Do nothing
  }

	//digitalWrite(LED_PIN, HIGH);
	int16_t data[DATA_POINT];
	uint32_t timeStamps[DATA_POINT];

	recordData(data, timeStamps, DELAY_TIME);

	// generate file name
	char fileName[20];
	sprintf(fileName, "DATA%03d.csv", fileNameCount);
	writeSDConverted(data, timeStamps, sca3300.getOperationMode(), fileName);
	//printDataRaw(data, timeStamps);
	printDataConverted(data, timeStamps, sca3300.getOperationMode());
}

unsigned int readFileCounter() {
  if (SD.exists("counter.txt")) {
    File f = SD.open("counter.txt", FILE_READ);

    if (f) {
      unsigned int val = f.parseInt();
      f.close();
      return val;
    }
  }
  return 0;
}
void writeFileCounter(unsigned int val) {
  File f = SD.open("counter.txt", FILE_WRITE);
  if (f) {
    f.seek(0);
    f.print(val);
    f.close();
  }
}
void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime) {
	Serial.println("Start Recording");
	// record data
	for (size_t i = 0; i < DATA_POINT; ++i) {
		data[i] = sca3300.getAccelRaw(MEASURE_AXIS);
		timeStamps[i] = micros();
		delayMicroseconds(delayTime);
	}
	Serial.println("Finish Recording");
}

void writeSDRaw(int16_t* data, uint32_t* timeStamps, char* fileName) {
	File dataFile = SD.open(fileName, FILE_WRITE);
	if (dataFile) {
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
		Serial.printf("%s NOT Created", fileName);
	}
}

void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName) {
	File dataFile = SD.open(fileName, FILE_WRITE);
	if (dataFile) {
		for (size_t i = 0; i < DATA_POINT; ++i) {
			double convertedData = AXIS_SIGN * sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);
			//dataFile.printf("%Lf, %llu\n", convertedData, timeStamps[i]);
			dataFile.print(convertedData, 7);
			dataFile.print(",");
			dataFile.println(timeStamps[i]);
		}
		dataFile.flush();
		dataFile.close();
    ++fileNameCount;
    writeFileCounter(fileNameCount);
		Serial.println("Finish Writing to SD Card");
		//digitalWrite(LED_PIN, LOW);
	}
	else {
		Serial.printf("%s NOT Created", fileName);
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
		double convertedData = AXIS_SIGN * sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);
		//Serial.printf("%Lf, %llu\n", convertedData, timeStamps[i]);
		Serial.print(convertedData, 7);
		Serial.print(",");
		Serial.println(timeStamps[i]);
	}
	double frequencyAverage = static_cast<double>(DATA_POINT)/static_cast<double>(timeStamps[DATA_POINT-1] - timeStamps[0]) * 1000000.0;
	Serial.print("Average Frequency: ");
	Serial.println(frequencyAverage);
}
