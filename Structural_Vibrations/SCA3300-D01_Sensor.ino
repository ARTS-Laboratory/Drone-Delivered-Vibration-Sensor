

#include <SPI.h>

SPISettings setting(2500000, MSBFIRST, SPI_MODE0);                                                       //set SPI mode indicated in the datasheet
const byte CS = 10;                                                                                      //chip select
const byte FRAME_LENGTH = 4;                                                                             //number of bytes sent or recieved
const byte SW_RST[] = { 0b10110100, 0b00000000, 0b100000, 0b10011000 };                                  //SW reset command frame
const byte CHANGE_TO_MODE3[] = { 0b10110100, 0b00000000, 0b10000000, 0b100101 };                         //±1.5g acceleration range (desired range) command frame
const byte READ_WHOAMI[] = { 0b10000000, 0b00000000, 0b00000000, 0b10010001 };                           //recommended test for validation command frame
const byte READ_STO[] = { 0b10000000, 0b00000000, 0b00000000, 0b11101001 };                              //Read self-test output command frame
const byte READ_STATUS_SUMMARY[] = { 0b11000,0b00000000,0b00000000,0b11100101 };                         //Read status summary command frame

void send(const byte spiFrame[FRAME_LENGTH], byte ret[FRAME_LENGTH]);                                    // initialize send SPI function
void printFrame(const byte frame[FRAME_LENGTH]);                                                         // initialize printing from SPI function


void setup() {                                                                                           //the setup function runs once when you press reset or power the board
  //Start the Start-up Sequence shown on table 10 page 18 of the datasheet https://www.murata.com/-/media/webrenewal/products/sensor/pdf/datasheet/datasheet_sca3300-d01.ashx?la=en                                                                         
  pinMode(CS, OUTPUT);                                                                                   //Chip select as output
  digitalWrite(CS, HIGH);                                                                                //initially disconnects slave
  Serial.begin(9600);                                                                                    //Start serial communication 
  SPI.begin();                                                                                           //start SPI
                                                              
  
  Serial.println("Step 2 : SW Reset");                                                                   // Step 2                                       
  
  byte data[FRAME_LENGTH];                                                                               //8 bit integer 
  byte res[4];                                                                                           //inialize the responce size [4]                                                              
  send(SW_RST, data);                                                                                    //send write SW Reset command 

  
  delay(1);                                                                                              // Step 3 Recommended delay

  // Step 4
  Serial.println("Step 4 : Set Measurement Mode"); 
  send(CHANGE_TO_MODE3, data);                                                                           //±1.5g acceleration range 
  printFrame(data);                                                                                      // RS should be '11'
  res[0] = data[0];                                                                                      // the first byte is chosen because it includes the two RS bits that validates the steps
  
  delay(15);                                                                                             // Step 5 Recommended delay
                                                                                                         // Step 6 - 8, RS should be '11', '11', '01'
  for (size_t i = 0; i < 3; ++i) {                                                                       // repeats 3 times as shown in table  
    Serial.printf("Step %d : Read Status Summary\n", 6 + i);
    send(READ_STATUS_SUMMARY, data);
    printFrame(data);
    res[i+1] = data[0];
  }
  
  //Loop used to read data (optional) 
  //for (size_t i = 0; i < 4; ++i)   
  //{
  //  Serial.print(res[i],BIN);
  //  Serial.print(" ");
  //}
  //Serial.println();
  
  Serial.println("Do a WHOAMI");                                                                          //Run a WhoAmI test
  send(READ_WHOAMI, data);                                                                                //send once
  send(READ_WHOAMI, data);                                                                                //send twice
  printFrame(data);                                                                                       //aquire the responce 
}

// the loop function runs over and over again until power down or reset
void loop() {

}

void send(const byte spiFrame[FRAME_LENGTH], byte ret[FRAME_LENGTH]) {                                    //Function to utilize SPI for frame data tansfer
  // copy data
  for (size_t i = 0; i < FRAME_LENGTH; ++i) {
    ret[i] = spiFrame[i];
  }
  // transmnit
  SPI.beginTransaction(setting);
  digitalWrite(CS, LOW);
  SPI.transfer(ret, FRAME_LENGTH);
  SPI.endTransaction();
  digitalWrite(CS, HIGH);
}

void printFrame(const byte frame[FRAME_LENGTH]) {                                                         //Function to printout recieved SPI frames
  for (size_t i = 0; i < FRAME_LENGTH; ++i) {
    Serial.print(frame[i], BIN);
    Serial.print(" ");
  }
  Serial.println();
}
