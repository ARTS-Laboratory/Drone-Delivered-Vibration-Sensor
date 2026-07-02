#include <SCA3300.h>
#include <SD.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>

/* ============================================================
   Teensy 4.0 UAV Sensor Package
   Buffered acquisition + SD-based LSTM compensation

   Required model files on SD card root:
   WI.CSV
   WH.CSV
   B.CSV
   FCW.CSV
   FCB.CSV
   NORM.CSV
   META.CSV
   ============================================================ */

constexpr uint8_t SCA3300_CHIP_SELECT = 1;
constexpr uint8_t SD_CHIP_SELECT = 4;
constexpr uint8_t LED_PIN = 3;
constexpr uint8_t WRITE_PIN = 2;

constexpr uint32_t SPI_SPEED = 2000000;
constexpr size_t DATA_POINT = 69000;

float targetFrequency = 400.0;
uint32_t DELAY_TIME = (1000000.0 / targetFrequency) - 35.0;

constexpr uint32_t LED_FLASH_INTERVAL = 250;

/* ---------------- LSTM Settings ---------------- */

#define INPUT_SIZE 1
#define HIDDEN_SIZE 50
#define GATE_SIZE (4 * HIDDEN_SIZE)

/* ---------------- Dynamic LSTM Memory ---------------- */

float* Wi  = nullptr;
float* Wh  = nullptr;
float* B   = nullptr;
float* Wfc = nullptr;
float* h   = nullptr;
float* c   = nullptr;

float Bfc = 0.0;

float inputMu = 0.0;
float inputSig = 1.0;
float targetMu = 0.0;
float targetSig = 1.0;

/* ---------------- Sensor Axis ---------------- */

// Top sensor package:
const sca3300_library::Axis MEASURE_AXIS = sca3300_library::Axis::Z;
constexpr int AXIS_SIGN = 1;

// Bottom sensor package:
// const sca3300_library::Axis MEASURE_AXIS = sca3300_library::Axis::Y;
// constexpr int AXIS_SIGN = -1;

sca3300_library::SCA3300 sca3300(
  SCA3300_CHIP_SELECT,
  SPI_SPEED,
  sca3300_library::OperationMode::MODE3,
  true
);

unsigned int fileNameCount = 0;

/* ---------------- Function Prototypes ---------------- */

void listFiles();
void errorBlink();

void findNextFileNames(char* rawFileName, char* compensatedFileName);

bool allocateAcquisitionBuffers(int16_t*& data, uint32_t*& timeStamps);
void freeAcquisitionBuffers(int16_t*& data, uint32_t*& timeStamps);

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime);

void writeRawCSV(int16_t* data,
                 uint32_t* timeStamps,
                 sca3300_library::OperationMode operationMode,
                 const char* fileName);

bool allocateLSTMModel();
void freeLSTMModel();

bool loadLSTMModelFromSD();
bool loadMatrixCSV(const char* fileName, float* destination, int rows, int cols);
bool loadVectorCSV(const char* fileName, float* destination, int length);

void resetLSTMState();
float runLSTMStep(float x);
float sigmoidFast(float x);

void compensateRawFile(const char* rawFileName, const char* compensatedFileName);

bool readLine(File& file, char* buffer, size_t maxLen);
int parseCSVFloats(char* line, float* values, int maxValues);

/* ============================================================
   Setup
   ============================================================ */

void setup() {
  Serial.begin(9600);
  delay(1500);

  pinMode(LED_PIN, OUTPUT);
  pinMode(WRITE_PIN, INPUT);

  digitalWrite(LED_PIN, LOW);

  Serial.println("Initializing SD Card...");

  if (!SD.begin(SD_CHIP_SELECT)) {
    Serial.println("Card Failed, or NOT Present");

    while (true) {
      digitalWrite(LED_PIN, HIGH);
      delay(100);
      digitalWrite(LED_PIN, LOW);
      delay(100);
    }
  }

  Serial.println("SD Card Initialized.");

  listFiles();

  sca3300.initChip();

  Serial.println("System Ready.");
  Serial.print("Sampling rate: ");
  Serial.print(targetFrequency);
  Serial.print(" S/s; Test time: ");
  Serial.print(DATA_POINT / targetFrequency);
  Serial.println(" seconds.");
  Serial.println("Waiting For Trigger...");
}

/* ============================================================
   Loop
   ============================================================ */

void loop() {

  /*
  while (digitalRead(WRITE_PIN) == LOW) {
    digitalWrite(LED_PIN, LOW);
  }
  */

  Serial.println("Trigger Received");

  char rawFileName[13];
  char compensatedFileName[13];

  findNextFileNames(rawFileName, compensatedFileName);

  int16_t* data = nullptr;
  uint32_t* timeStamps = nullptr;

  if (!allocateAcquisitionBuffers(data, timeStamps)) {
    Serial.println("ERROR: Could not allocate acquisition buffers.");
    errorBlink();
    return;
  }

  digitalWrite(LED_PIN, HIGH);

  recordData(data, timeStamps, DELAY_TIME);

  writeRawCSV(data,
              timeStamps,
              sca3300.getOperationMode(),
              rawFileName);

  freeAcquisitionBuffers(data, timeStamps);

  Serial.println("Acquisition buffers released.");

  if (!allocateLSTMModel()) {
    Serial.println("ERROR: Could not allocate LSTM model memory.");
    errorBlink();
    return;
  }

  Serial.println("Loading LSTM model from SD...");

  if (!loadLSTMModelFromSD()) {
    Serial.println("ERROR: Failed to load LSTM model.");
    freeLSTMModel();
    errorBlink();
    return;
  }

  Serial.println("LSTM model loaded successfully.");

  Serial.println("Running on-device LSTM compensation...");

  compensateRawFile(rawFileName, compensatedFileName);

  freeLSTMModel();

  digitalWrite(LED_PIN, LOW);

  Serial.println("Logging and compensation complete.");
  Serial.print("Raw file: ");
  Serial.println(rawFileName);
  Serial.print("Compensated file: ");
  Serial.println(compensatedFileName);

  Serial.println("Waiting For Trigger Release");

  while (digitalRead(WRITE_PIN) == HIGH) {
    delay(10);
  }

  for (int i = 0; i < 3; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(500);
    digitalWrite(LED_PIN, LOW);
    delay(500);
  }

  Serial.println("Ready For New Trigger");
}

/* ============================================================
   Diagnostics
   ============================================================ */

void listFiles() {
  File root = SD.open("/");

  Serial.println();
  Serial.println("========== SD CARD CONTENTS ==========");

  while (true) {
    File entry = root.openNextFile();

    if (!entry) {
      break;
    }

    Serial.print(entry.name());
    Serial.print("    ");
    Serial.println(entry.size());

    entry.close();
  }

  root.close();

  Serial.println("======================================");
  Serial.println();
}

void errorBlink() {
  while (true) {
    digitalWrite(LED_PIN, HIGH);
    delay(150);
    digitalWrite(LED_PIN, LOW);
    delay(150);
  }
}

/* ============================================================
   File Naming
   ============================================================ */

void findNextFileNames(char* rawFileName, char* compensatedFileName) {
  while (true) {
    sprintf(rawFileName, "R%03d.CSV", fileNameCount);
    sprintf(compensatedFileName, "C%03d.CSV", fileNameCount);

    if (!SD.exists(rawFileName) && !SD.exists(compensatedFileName)) {
      fileNameCount++;
      return;
    }

    fileNameCount++;
  }
}

/* ============================================================
   Acquisition Buffer Allocation
   ============================================================ */

bool allocateAcquisitionBuffers(int16_t*& data, uint32_t*& timeStamps) {
  data = new int16_t[DATA_POINT];

  if (data == nullptr) {
    return false;
  }

  timeStamps = new uint32_t[DATA_POINT];

  if (timeStamps == nullptr) {
    delete[] data;
    data = nullptr;
    return false;
  }

  return true;
}

void freeAcquisitionBuffers(int16_t*& data, uint32_t*& timeStamps) {
  if (data != nullptr) {
    delete[] data;
    data = nullptr;
  }

  if (timeStamps != nullptr) {
    delete[] timeStamps;
    timeStamps = nullptr;
  }
}

/* ============================================================
   Data Acquisition
   ============================================================ */

void recordData(int16_t* data, uint32_t* timeStamps, uint32_t delayTime) {
  Serial.println("Start Recording");

  for (size_t i = 0; i < DATA_POINT; ++i) {
    data[i] = sca3300.getAccelRaw(MEASURE_AXIS);
    timeStamps[i] = micros();
    delayMicroseconds(delayTime);
  }

  Serial.println("Finish Recording");
}

/* ============================================================
   Write Raw CSV
   ============================================================ */

void writeRawCSV(int16_t* data,
                 uint32_t* timeStamps,
                 sca3300_library::OperationMode operationMode,
                 const char* fileName) {
  File dataFile = SD.open(fileName, FILE_WRITE);

  if (!dataFile) {
    Serial.print("ERROR: Could Not Create ");
    Serial.println(fileName);
    return;
  }

  Serial.print("Writing raw data to SD: ");
  Serial.println(fileName);

  dataFile.println("time_us,raw_accel");

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

    double rawAccel = sca3300_library::SCA3300::convertRawAccelToAccel(
      data[i],
      operationMode
    );

    rawAccel = AXIS_SIGN * rawAccel;

    dataFile.print(relativeTime);
    dataFile.print(",");
    dataFile.println(rawAccel, 7);
  }

  dataFile.flush();
  dataFile.close();

  Serial.println("Finished writing raw data.");
}

/* ============================================================
   LSTM Model Allocation
   ============================================================ */

bool allocateLSTMModel() {
  Wi  = new float[GATE_SIZE * INPUT_SIZE];
  Wh  = new float[GATE_SIZE * HIDDEN_SIZE];
  B   = new float[GATE_SIZE];
  Wfc = new float[HIDDEN_SIZE];
  h   = new float[HIDDEN_SIZE];
  c   = new float[HIDDEN_SIZE];

  if (Wi == nullptr || Wh == nullptr || B == nullptr ||
      Wfc == nullptr || h == nullptr || c == nullptr) {
    freeLSTMModel();
    return false;
  }

  return true;
}

void freeLSTMModel() {
  if (Wi != nullptr) {
    delete[] Wi;
    Wi = nullptr;
  }

  if (Wh != nullptr) {
    delete[] Wh;
    Wh = nullptr;
  }

  if (B != nullptr) {
    delete[] B;
    B = nullptr;
  }

  if (Wfc != nullptr) {
    delete[] Wfc;
    Wfc = nullptr;
  }

  if (h != nullptr) {
    delete[] h;
    h = nullptr;
  }

  if (c != nullptr) {
    delete[] c;
    c = nullptr;
  }
}

/* ============================================================
   Load LSTM Model
   ============================================================ */

bool loadLSTMModelFromSD() {
  bool ok = true;

  ok &= loadMatrixCSV("WI.CSV", Wi, GATE_SIZE, INPUT_SIZE);
  ok &= loadMatrixCSV("WH.CSV", Wh, GATE_SIZE, HIDDEN_SIZE);
  ok &= loadVectorCSV("B.CSV", B, GATE_SIZE);
  ok &= loadVectorCSV("FCW.CSV", Wfc, HIDDEN_SIZE);
  ok &= loadVectorCSV("FCB.CSV", &Bfc, 1);

  float normData[4];

  ok &= loadVectorCSV("NORM.CSV", normData, 4);

  inputMu = normData[0];
  inputSig = normData[1];
  targetMu = normData[2];
  targetSig = normData[3];

  Serial.println("Model parameter summary:");
  Serial.print("inputMu: "); Serial.println(inputMu, 8);
  Serial.print("inputSig: "); Serial.println(inputSig, 8);
  Serial.print("targetMu: "); Serial.println(targetMu, 8);
  Serial.print("targetSig: "); Serial.println(targetSig, 8);
  Serial.print("Wi[0]: "); Serial.println(Wi[0], 8);
  Serial.print("Wh[0]: "); Serial.println(Wh[0], 8);
  Serial.print("B[0]: "); Serial.println(B[0], 8);
  Serial.print("Wfc[0]: "); Serial.println(Wfc[0], 8);
  Serial.print("Bfc: "); Serial.println(Bfc, 8);

  return ok;
}

/* ============================================================
   CSV Loading Utilities
   ============================================================ */

bool loadMatrixCSV(const char* fileName, float* destination, int rows, int cols) {
  File file = SD.open(fileName, FILE_READ);

  if (!file) {
    Serial.print("ERROR opening ");
    Serial.println(fileName);
    return false;
  }

  Serial.print("Loading ");
  Serial.println(fileName);

  const int MAX_LINE = 2048;
  char line[MAX_LINE];

  int row = 0;

  while (file.available() && row < rows) {
    if (!readLine(file, line, MAX_LINE)) {
      break;
    }

    if (strlen(line) == 0) {
      continue;
    }

    float values[HIDDEN_SIZE];

    int n = parseCSVFloats(line, values, cols);

    if (n < cols) {
      Serial.print("ERROR parsing ");
      Serial.print(fileName);
      Serial.print(" row ");
      Serial.println(row);
      file.close();
      return false;
    }

    for (int col = 0; col < cols; col++) {
      destination[row * cols + col] = values[col];
    }

    row++;
  }

  file.close();

  if (row != rows) {
    Serial.print("ERROR: Expected rows ");
    Serial.print(rows);
    Serial.print(" but read ");
    Serial.println(row);
    return false;
  }

  return true;
}

bool loadVectorCSV(const char* fileName, float* destination, int length) {
  File file = SD.open(fileName, FILE_READ);

  if (!file) {
    Serial.print("ERROR opening ");
    Serial.println(fileName);
    return false;
  }

  Serial.print("Loading ");
  Serial.println(fileName);

  const int MAX_LINE = 2048;
  char line[MAX_LINE];

  int index = 0;

  while (file.available() && index < length) {
    if (!readLine(file, line, MAX_LINE)) {
      break;
    }

    if (strlen(line) == 0) {
      continue;
    }

    char* token = strtok(line, ",");

    while (token != NULL && index < length) {
      destination[index] = atof(token);
      index++;
      token = strtok(NULL, ",");
    }
  }

  file.close();

  if (index != length) {
    Serial.print("ERROR: Expected ");
    Serial.print(length);
    Serial.print(" values from ");
    Serial.print(fileName);
    Serial.print(" but read ");
    Serial.println(index);
    return false;
  }

  return true;
}

bool readLine(File& file, char* buffer, size_t maxLen) {
  size_t index = 0;

  while (file.available() && index < maxLen - 1) {
    char ch = file.read();

    if (ch == '\r') {
      continue;
    }

    if (ch == '\n') {
      break;
    }

    buffer[index++] = ch;
  }

  buffer[index] = '\0';

  return index > 0;
}

int parseCSVFloats(char* line, float* values, int maxValues) {
  int count = 0;

  char* token = strtok(line, ",");

  while (token != NULL && count < maxValues) {
    values[count] = atof(token);
    count++;
    token = strtok(NULL, ",");
  }

  return count;
}

/* ============================================================
   LSTM Inference
   ============================================================ */

void resetLSTMState() {
  for (int i = 0; i < HIDDEN_SIZE; i++) {
    h[i] = 0.0f;
    c[i] = 0.0f;
  }
}

float runLSTMStep(float x) {
  float xNorm = (x - inputMu) / inputSig;

  float iGate[HIDDEN_SIZE];
  float fGate[HIDDEN_SIZE];
  float gGate[HIDDEN_SIZE];
  float oGate[HIDDEN_SIZE];

  for (int j = 0; j < HIDDEN_SIZE; j++) {
    float zi = Wi[j * INPUT_SIZE] * xNorm + B[j];
    float zf = Wi[(HIDDEN_SIZE + j) * INPUT_SIZE] * xNorm + B[HIDDEN_SIZE + j];
    float zg = Wi[(2 * HIDDEN_SIZE + j) * INPUT_SIZE] * xNorm + B[2 * HIDDEN_SIZE + j];
    float zo = Wi[(3 * HIDDEN_SIZE + j) * INPUT_SIZE] * xNorm + B[3 * HIDDEN_SIZE + j];

    for (int k = 0; k < HIDDEN_SIZE; k++) {
      zi += Wh[j * HIDDEN_SIZE + k] * h[k];
      zf += Wh[(HIDDEN_SIZE + j) * HIDDEN_SIZE + k] * h[k];
      zg += Wh[(2 * HIDDEN_SIZE + j) * HIDDEN_SIZE + k] * h[k];
      zo += Wh[(3 * HIDDEN_SIZE + j) * HIDDEN_SIZE + k] * h[k];
    }

    iGate[j] = sigmoidFast(zi);
    fGate[j] = sigmoidFast(zf);
    gGate[j] = tanhf(zg);
    oGate[j] = sigmoidFast(zo);
  }

  for (int j = 0; j < HIDDEN_SIZE; j++) {
    c[j] = fGate[j] * c[j] + iGate[j] * gGate[j];
    h[j] = oGate[j] * tanhf(c[j]);
  }

  float yNorm = Bfc;

  for (int j = 0; j < HIDDEN_SIZE; j++) {
    yNorm += Wfc[j] * h[j];
  }

  float y = yNorm * targetSig + targetMu;

  return y;
}

float sigmoidFast(float x) {
  if (x > 20.0f) return 1.0f;
  if (x < -20.0f) return 0.0f;

  return 1.0f / (1.0f + expf(-x));
}

/* ============================================================
   Compensate Raw File
   ============================================================ */

void compensateRawFile(const char* rawFileName, const char* compensatedFileName) {
  File rawFile = SD.open(rawFileName, FILE_READ);

  if (!rawFile) {
    Serial.print("ERROR opening raw file: ");
    Serial.println(rawFileName);
    return;
  }

  File compensatedFile = SD.open(compensatedFileName, FILE_WRITE);

  if (!compensatedFile) {
    Serial.print("ERROR creating compensated file: ");
    Serial.println(compensatedFileName);
    rawFile.close();
    return;
  }

  compensatedFile.println("time_us,raw_accel,lstm_compensated_accel");

  resetLSTMState();

  const int MAX_LINE = 128;
  char line[MAX_LINE];

  bool firstLine = true;
  size_t sampleCount = 0;

  bool ledState = HIGH;
  unsigned long lastBlinkTime = millis();

  while (rawFile.available()) {
    if (!readLine(rawFile, line, MAX_LINE)) {
      continue;
    }

    if (strlen(line) == 0) {
      continue;
    }

    if (firstLine) {
      firstLine = false;

      if (strstr(line, "time") != NULL) {
        continue;
      }
    }

    char* tokenTime = strtok(line, ",");
    char* tokenRaw = strtok(NULL, ",");

    if (tokenTime == NULL || tokenRaw == NULL) {
      continue;
    }

    uint32_t timeUS = strtoul(tokenTime, NULL, 10);
    float rawAccel = atof(tokenRaw);

    float compensatedAccel = runLSTMStep(rawAccel);

    compensatedFile.print(timeUS);
    compensatedFile.print(",");
    compensatedFile.print(rawAccel, 7);
    compensatedFile.print(",");
    compensatedFile.println(compensatedAccel, 7);

    sampleCount++;

    unsigned long currentTime = millis();

    if (currentTime - lastBlinkTime >= LED_FLASH_INTERVAL) {
      ledState = !ledState;
      digitalWrite(LED_PIN, ledState);
      lastBlinkTime = currentTime;
    }
  }

  rawFile.close();
  compensatedFile.flush();
  compensatedFile.close();

  Serial.print("Compensated samples written: ");
  Serial.println(sampleCount);
}
