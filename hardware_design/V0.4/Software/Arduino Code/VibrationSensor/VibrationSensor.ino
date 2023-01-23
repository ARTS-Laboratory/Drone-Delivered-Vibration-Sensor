

/*
   Copyright 2020 ARTS_LAB
*/

#include <SCA3300.h>
#include <SD.h>

//constexpr uint8_t SCA3300_CHIP_SELECT = 5; //PCB Chip Select
//constexpr uint8_t SD_CHIP_SELECT = 10; //PCB Chip Select
const uint8_t SCA3300_CHIP_SELECT = 10;  //Development Board Chip Select
const uint8_t SD_CHIP_SELECT = 2;    //Development Board Chip Select
const uint8_t WRITE_PIN = 4 ;

constexpr uint32_t SPI_SPEED = 2000000;   //typ. f_sck = 2 MHz
//constexpr size_t DATA_POINT = 222220;      // No time stamp
constexpr size_t DATA_POINT = 74000;     //74295 time stamped
//constexpr uint32_t DELAY_TIME = 1316;  //740Hz
//constexpr uint32_t DELAY_TIME = 965;  //1000Hz
//constexpr uint32_t DELAY_TIME = 570;     //1652Hz
//constexpr uint32_t DELAY_TIME = 551;     //1705Hz
//constexpr uint32_t DELAY_TIME = 121;   //6.4kHz
//constexpr uint32_t DELAY_TIME = 0;     //28670.60Hz Period .00003487893522
//constexpr uint32_t DELAY_TIME = 415;     //2222.2Hz
//constexpr uint32_t DELAY_TIME = 4965;     //200Hz
//constexpr uint32_t DELAY_TIME = 2215;     //444Hz
//constexpr uint32_t DELAY_TIME = 6722;      //140
//constexpr uint32_t DELAY_TIME = 776;      //1233
//constexpr uint32_t DELAY_TIME = 100;      //7400
//constexpr uint32_t DELAY_TIME = 640;      //1480



// MODE#1 is 3G
// MODE#3 is 1.5G
sca3300_library::SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, sca3300_library::OperationMode::MODE3, true); // MODE#1 is 3G

boolean Trig = 0;
unsigned int fileNameCount = 0;

constexpr uint32_t Freq = 7200;
constexpr uint32_t DELAY_TIME = static_cast<uint32_t>(((1.0/Freq)-.00003487893522)*1000000);

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime);
void writeSDRaw(int16_t* data, uint32_t* timeStamps, char* fileName);
void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName);
void printDataRaw(int16_t* data, uint32_t* timeStamps);
void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode);

void setup() {
  delay(5000);
  Serial.begin(9600);
  pinMode(WRITE_PIN, INPUT);
  //pinMode(LED_PIN, OUTPUT);
  Serial.println("Initializing SD Card...");
  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Card Failed, or NOT Present");
    return;
  }
  Serial.println("SD Card Initialized.");
  sca3300.initChip();

  //Sampling Frequency Input
  Serial.print("Sampling Frequency:");
  Serial.println(1/((DELAY_TIME*.000001)+.00003487893522));
  Serial.print("Test Length (s):");
  Serial.println(DATA_POINT*((DELAY_TIME*.000001)+.00003487893522));
}

void loop() {
  // Serial.println(sca3300.getWhoAmI(),BIN); 
  //Trig = digitalRead(WRITE_PIN);
  //if (Trig == 1){
  int16_t data[DATA_POINT];
  uint32_t timeStamps[DATA_POINT]; 
  digitalWrite(WRITE_PIN, HIGH);
  //delayMicroseconds(5625);
  recordData(data, timeStamps, DELAY_TIME);
  // generate file name
  //digitalWrite(LED_PIN, HIGH);
  char fileName[8];
  sprintf(fileName, "%03d.csv", fileNameCount);
  writeSDConverted(data, timeStamps, sca3300.getOperationMode(), fileName);
  //printDataRaw(data, timeStamps);
  printDataConverted(data, timeStamps, sca3300.getOperationMode());
  //digitalWrite(WRITE_PIN, LOW);
  //}
}

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime) {
  Serial.println("Start Recording");
  //  timeStamps[0] = micros();
  // record data

  
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
    Serial.printf("%c NOT Created", fileName);
  }
}

void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName) {
  File dataFile = SD.open(fileName, FILE_WRITE);
  if (SD.exists(fileName)) {
  //double period = (static_cast<double>(timeStamps[1] - timeStamps[0]) * .000001) / static_cast<double>(DATA_POINT);


    for (size_t i = 0; i < DATA_POINT; ++i) {
      double convertedData = sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);
      //      dataFile.print(period * static_cast<double>(i), 7);
      //      dataFile.print(",");
      dataFile.print(String((timeStamps[i]-timeStamps[0])*.000001, 10));
      dataFile.print(",");
      dataFile.println(convertedData, 7);
      //dataFile.print(",");
      //dataFile.println(timeStamps[i]);
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


void printDataRaw(int16_t* data, uint32_t* timeStamps) {
    for (size_t i = 0; i < DATA_POINT; ++i) {
      //Serial.printf("%d, %llu\n", data[i], timeStamps[i]);
      Serial.print(data[i]);
      Serial.print(",");
      Serial.println(timeStamps[i]);
    }
    
  double periodAverage =  static_cast<double>(timeStamps[1] - timeStamps[0]) / static_cast<double>(DATA_POINT);
  //  double frequencyAverage = static_cast<double>(DATA_POINT) / static_cast<double>(timeStamps[DATA_POINT - 1] - timeStamps[0]) * 1000000.0;
  Serial.print("Average Frequency: ");
  Serial.println(1 / periodAverage*.000001);
}

void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode) {
  //  for (size_t i = 0; i < DATA_POINT; ++i) {
  //    double convertedData = sca3300_library::SCA3300::convertRawAccelToAccel(data[i], operationMode);
  //    Serial.printf("%Lf, %llu\n", convertedData, timeStamps[i]);
  //    Serial.print(convertedData, 7);
  //    Serial.print(",");
  //    Serial.println(timeStamps[i]);
  //  }
  double periodAverage =  static_cast<double>(timeStamps[DATA_POINT-1] - timeStamps[0]) / static_cast<double>(DATA_POINT);
  //  double frequencyAverage = static_cast<double>(DATA_POINT)/static_cast<double>(timeStamps[DATA_POINT-1] - timeStamps[0]) * 1000000.0;
  Serial.print("Average Frequency: ");
  Serial.print(1 / (periodAverage * .000001));
  Serial.println(" Hz");
}
