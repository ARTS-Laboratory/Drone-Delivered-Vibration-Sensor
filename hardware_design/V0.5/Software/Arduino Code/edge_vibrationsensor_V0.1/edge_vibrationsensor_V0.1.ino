/*
 * Vibration Sensor Package with edge computing Version: 0.1
 * - This code accurately detects the first mode, but attempts the first 3 modes sometimes unsuccessfully
 */


#include <SCA3300.h>
#include <SD.h>
#include <SPI.h>
#include "arduinoFFT.h"

arduinoFFT FFT; // Create FFT object

File myFile;

boolean Trig = 0;
unsigned int fileNameCount = 0;

const uint8_t LED_PIN = 3; // Indicator LED pin number
const uint8_t SCA3300_CHIP_SELECT = 1;  //Current PCB Chip Select
const uint8_t SD_CHIP_SELECT = 4;    //PCB Chip Select
const uint8_t Trig_PIN = 2;

constexpr uint32_t SPI_SPEED = 2000000;
constexpr size_t DATA_POINT = 16384;     // Must be a power of 2
const uint16_t samples = 16384; // Must be a power of 2

constexpr uint32_t Freq = 1600; // Sampling rate of the accelerometer in Samples/s (change this to change test time)
const double samplingFrequency = 1600; // Sampling frequency for FFT
constexpr uint32_t DELAY_TIME = static_cast<uint32_t>(((1.0/Freq)-.00003487893522)*1000000);

double vReal[samples]; // Real part of the FFT input
double vImag[samples]; // Imaginary part of the FFT input
int dataCount = 0;

sca3300_library::SCA3300 sca3300(SCA3300_CHIP_SELECT, SPI_SPEED, sca3300_library::OperationMode::MODE3, true); // MODE#1 is 3G

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime);
void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName);
void printDataConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode);

void setup() {
  delay(5000);
  Serial.begin(9600);
  pinMode(Trig_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  Serial.println("Initializing SD Card...");
  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Card Failed, or NOT Present");
    return;
  }
  Serial.println("SD Card Initialized.");
  sca3300.initChip();
  Serial.print("Sampling Frequency:");
  Serial.println(1/((DELAY_TIME*.000001)+.00003487893522));
  Serial.print("Test Length (s):");
  Serial.println(DATA_POINT*((DELAY_TIME*.000001)+.00003487893522));
}

void loop() {
  Trig = 1; // Replace with digitalRead(Trig_PIN); for actual trigger
  if (Trig == 1) {
    int16_t data[DATA_POINT];
    uint32_t timeStamps[DATA_POINT];
    digitalWrite(LED_PIN, HIGH);
    recordData(data, timeStamps, DELAY_TIME);
    char fileName[13];
    sprintf(fileName, "DATA%03d.csv", fileNameCount);
//    fileNameCount++;
    writeSDConverted(data, timeStamps, sca3300.getOperationMode(), fileName);
    printDataConverted(data, timeStamps, sca3300.getOperationMode());

    // Open the file for reading:
    myFile = SD.open(fileName);
    if (myFile) {
      Serial.print("Reading from ");
      Serial.println(fileName);
      
      double sum = 0;
      int dataCount = 0;
      
      while (myFile.available() && dataCount < samples) {
      String line = myFile.readStringUntil('\n');
      int commaIndex = line.indexOf(',');
      if (commaIndex != -1) {
        String accelString = line.substring(commaIndex + 1);
        vReal[dataCount] = accelString.toFloat();
        vImag[dataCount] = 0;
        sum += vReal[dataCount];
        dataCount++;
      }
    }
    myFile.close();
    Serial.println("Finished reading file");
    delay(1000);
    double average = sum/dataCount;

    for(int i = 0; i < dataCount; i++){
      vReal[i] -= average;
    }

    // Perform FFT
    FFT.Windowing(vReal, samples, FFT_WIN_TYP_HAMMING, FFT_FORWARD);
    FFT.Compute(vReal, vImag, samples, FFT_FORWARD);
    FFT.ComplexToMagnitude(vReal, vImag, samples);
    delay(1000);

//    for (int i = 0; i < (samples >> 1); i++) {
//      Serial.print("Frequency ");
//      Serial.print((i * 1.0 * samplingFrequency) / samples, 1);
//      Serial.print(" Hz, Magnitude: ");
//      Serial.println(vReal[i], 4);
//    }

   File FFTFile = SD.open("FFT001.csv", FILE_WRITE);
    if (FFTFile) {
      Serial.println("Writing FFT values to FFT file");
      for (int i = 0; i < (samples >> 1); i++) {
        FFTFile.print((i * 1.0 * samplingFrequency) / samples, 1); // Replace 500 with your actual sampling frequency
        FFTFile.print(",");
        FFTFile.println(vReal[i], 4);
      }
      FFTFile.close();
      Serial.println("Finished writing FFT values to file");
    } else {
      Serial.println("Error opening FFT file for writing");
    }

    // Apply smoothing
//    int windowSize = 5; // Choose an appropriate window size
//    double temp[samples]; // Temporary array to store the smoothed data
//
//    // Apply moving average on the magnitude data
//    for (int i = 0; i < samples; i++) {
//      temp[i] = 0; // Initialize temporary storage
//      for (int j = -windowSize / 2; j <= windowSize / 2; j++) {
//        int index = i + j;
//        if (index < 0 || index >= samples) continue; // Skip out-of-bounds indices
//        temp[i] += vReal[index];
//      }
//      temp[i] /= windowSize; // Calculate the average
//    }
//
//    for (int i = 0; i < samples; i++) {
//      vReal[i] = temp[i];
//    }

    // Peak Detection
    const int peakThreshold = 10; // Set this based on your data
    int peakCount = 0;
    double peakFrequencies[3] = {0, 0, 0}; // Store top 3 peak frequencies
    double peakMagnitudes[3] = {0, 0, 0}; // Store top 3 peak magnitudes

    for (int i = 1; i < (samples >> 1) - 1; i++) {
      if (vReal[i] > vReal[i - 1] && vReal[i] > vReal[i + 1] && vReal[i] > peakThreshold) {
        // Check if current peak is larger than the smallest peak in top 3
        if (vReal[i] > peakMagnitudes[2]) {
          peakMagnitudes[2] = vReal[i];
          peakFrequencies[2] = (i * 1.0 * samplingFrequency) / samples;

          // Sort the top 3 peaks
          for (int j = 0; j < 2; j++) {
            if (peakMagnitudes[j] < peakMagnitudes[j + 1]) {
              double tempMag = peakMagnitudes[j];
              double tempFreq = peakFrequencies[j];
              peakMagnitudes[j] = peakMagnitudes[j + 1];
              peakFrequencies[j] = peakFrequencies[j + 1];
              peakMagnitudes[j + 1] = tempMag;
              peakFrequencies[j + 1] = tempFreq;
            }
          }
        }
      }
    }

    // Print the top 3 peaks
    for (int i = 0; i < 3; i++) {
      Serial.print("Peak ");
      Serial.print(i + 1);
      Serial.print(" Frequency: ");
      Serial.print(peakFrequencies[i], 1);
      Serial.print(" Hz, Magnitude: ");
      Serial.println(peakMagnitudes[i], 4);
    }
    File peakFile = SD.open("peaks1.txt", FILE_WRITE);
    if (peakFile) {
      Serial.println("Writing top frequencies to peaks1.txt");
      for (int i = 0; i < 3; i++) {
        peakFile.print("Peak ");
        peakFile.print(i + 1);
        peakFile.print(" Frequency: ");
        peakFile.print(peakFrequencies[i], 1);
        peakFile.print(" Hz, Magnitude: ");
        peakFile.println(peakMagnitudes[i], 4);
      }
      peakFile.close(); // Close the file
      Serial.println("Finished writing to peaks1.txt");
    } else {
      Serial.println("Error opening peaks1.txt for writing");
    }
    
    }
    else {
      Serial.print("Error opening ");
      Serial.println(fileName);
    }
  }
  delay(10000); // Delay before the next loop iteration
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

void writeSDConverted(int16_t* data, uint32_t* timeStamps, sca3300_library::OperationMode operationMode, char* fileName) {
  File dataFile = SD.open(fileName, FILE_WRITE);
  if (SD.exists(fileName)) {
  //double period = (static_cast<double>(timeStamps[1] - timeStamps[0]) * .000001) / static_cast<double>(DATA_POINT);


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

    for (int i = 0; i <= 5; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(200);
    digitalWrite(LED_PIN, LOW);
    delay(200);
  }

  }
  else {
    Serial.printf("%c NOT Created", fileName);
  }
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
