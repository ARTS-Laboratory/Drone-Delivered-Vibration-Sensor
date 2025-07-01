

/*
   Copyright 2020 ARTS_LAB
*/

#include <SCA3300.h>
#include <SD.h>
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

//create an RF24 object

RF24 radio(7, 6);  // CE, CSN
const byte address[6] = "00001";//address through which two modules communicate.


//constexpr uint8_t SCA3300_CHIP_SELECT = 5; //PCB Chip Select
constexpr uint8_t SCA3300_CHIP_SELECT = 1; //PCB Chip Select
//constexpr uint8_t SD_CHIP_SELECT = 10; //PCB Chip Select
constexpr uint8_t SD_CHIP_SELECT = 4; //Ryan PCB Chip Select
//const uint8_t LED = 4 ;//PCB
const uint8_t LED = 3 ;//Ryan PCB
int num=0;



constexpr uint32_t SPI_SPEED = 2000000;   //typ. f_sck = 2 MHz
constexpr size_t DATA_POINT = 74000;     //74295 time stamped


sca3300_library::SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, sca3300_library::OperationMode::MODE3, true); // MODE#1 is 3G // MODE#3 is 1.5G
unsigned int fileNameCount = 0;
constexpr uint32_t Freq = 1600;
constexpr uint32_t DELAY_TIME = static_cast<uint32_t>(((1.0/Freq)-.00003487893522)*1000000);

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime);
void writeSDRaw(int16_t* data, uint32_t* timeStamps, char* fileName);
void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName);
void printDataRaw(int16_t* data, uint32_t* timeStamps);
void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode);

void setup() {
  delay(5000);
  Serial.begin(9600);
  pinMode(LED, OUTPUT);

  // SD Card initialization
  Serial.println("Initializing SD Card...");
  if (!SD.begin(SD_CHIP_SELECT)) {
     Serial.println("Card Failed, or NOT Present");
     return;
  }
  Serial.println("SD Card Initialized.");
  sca3300.initChip();

  // RF module initialization
  radio.begin();
  radio.setPALevel(RF24_PA_MAX); // Max Power Wirless
  //set the address
  radio.openReadingPipe(0, address); 
  //Set module as receiver
  radio.startListening();
  
  //Sampling Frequency Input
  Serial.print("Sampling Frequency:");
  Serial.println(1/((DELAY_TIME*.000001)+.00003487893522));
  Serial.print("Test Length (s):");
  Serial.println(DATA_POINT*((DELAY_TIME*.000001)+.00003487893522));
}

void loop() {
  // Serial.println(sca3300.getWhoAmI(),BIN); 
  //Read the data if available in buffer
  digitalWrite(LED, LOW);
  while (radio.available())
  {
  int msg = 0;
  radio.read(&msg, sizeof(msg));
  Serial.println(msg);
  if (msg==1){
  digitalWrite(LED, HIGH);
  int16_t data[DATA_POINT];
  uint32_t timeStamps[DATA_POINT]; 
  recordData(data, timeStamps, DELAY_TIME);
  // generate file name
  char fileName[8];
  sprintf(fileName, "%03d.csv", fileNameCount);
  writeSDConverted(data, timeStamps, sca3300.getOperationMode(), fileName);

  for (int i = 0; i <= 5; i++) {
    digitalWrite(LED, LOW);
    delay(200);
    digitalWrite(LED, HIGH);
    delay(200);
  }
 
  printDataConverted(data, timeStamps, sca3300.getOperationMode());
  }
  else if (msg==2){  
      digitalWrite(LED, LOW); 
  }
  else {
      digitalWrite(LED, LOW);
  }
 }
}

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime) {
  Serial.println("Start Recording");
  //  timeStamps[0] = micros();
  //  record data

  
  for (size_t i = 0; i < DATA_POINT; ++i) {
    data[i] = sca3300.getAccelRaw(sca3300_library::Axis::Z);
    timeStamps[i] = micros();
    delayMicroseconds(delayTime);
  }
  //  timeStamps[1] = micros();
  Serial.println("Finish Recording");
}

void writeSDRaw(int16_t* data, uint32_t* timeStamps, char* fileName) {
  File dataFile = SD.open(fileName, FILE_WRITE);

  if (SD.exists(fileName)) {
    //    dataFile.print((timeStamps[1] - timeStamps[0])*.000001);
    for (size_t i = 0; i < DATA_POINT; ++i) {
      dataFile.print(data[i]);
      dataFile.print(",");
      dataFile.println(timeStamps[i]*.000001);
    }

    ++fileNameCount;
    dataFile.flush();
    dataFile.close();
    Serial.println("Finish Writing to SD Card");
  }
  else {
    Serial.print("NOT Created");
  }
}

void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName) {
  File dataFile = SD.open(fileName, FILE_WRITE);
  if (SD.exists(fileName)) {
    for (size_t i = 0; i < DATA_POINT; ++i) {
      double convertedData = sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);
      dataFile.print(String((timeStamps[i]-timeStamps[0])*.000001, 10));
      dataFile.print(",");
      dataFile.println(convertedData, 7);
    }
    ++fileNameCount;
    dataFile.flush();
    dataFile.close();
    Serial.println("Finish Writing to SD Card");
  }
  else {
    Serial.print("NOT Created");
  }
}


void printDataRaw(int16_t* data, uint32_t* timeStamps) {
    for (size_t i = 0; i < DATA_POINT; ++i) {
      Serial.print(data[i]);
      Serial.print(",");
      Serial.println(timeStamps[i]);
    }
  double periodAverage =  static_cast<double>(timeStamps[1] - timeStamps[0]) / static_cast<double>(DATA_POINT);
  Serial.print("Average Frequency: ");
  Serial.println(1 / periodAverage*.000001);
}

void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode) {
  double periodAverage =  static_cast<double>(timeStamps[DATA_POINT-1] - timeStamps[0]) / static_cast<double>(DATA_POINT);
  Serial.print("Average Frequency: ");
  Serial.print(1 / (periodAverage * .000001));
  Serial.println(" Hz");
}
