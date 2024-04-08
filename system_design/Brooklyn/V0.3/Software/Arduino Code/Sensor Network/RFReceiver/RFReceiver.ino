/*
* Arduino Wireless Communication Tutorial
*       Example 1 - Receiver Code
*                
* by Dejan Nedelkovski, www.HowToMechatronics.com
* 
* Library: TMRh20/RF24, https://github.com/tmrh20/RF24/
*/

#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

RF24 radio(9, 10); // CE, CSN

const byte address[6] = "00001";
const int rled = 13;

void setup() {
  pinMode(rled, OUTPUT);
  Serial.begin(9600);
  radio.begin();
  radio.openReadingPipe(0, address);
  radio.setPALevel(RF24_PA_MAX);
  radio.startListening();
}

void loop() {
  digitalWrite(rled, LOW);
//  if (radio.available()) {
//    char text[32] = "";
//    radio.read(&text, sizeof(text));
//    Serial.println(text);
//    digitalWrite(rled, HIGH);
//  }
  while(radio.available()){
    char text[32] = "";
    int msg = 0;
//    radio.read(&text, sizeof(text));
    radio.read(&msg, sizeof(msg));
    // Serial.println(text);
    Serial.println(msg);
    if(msg == 1){
      digitalWrite(9, HIGH);
      // delay(10);
    }
  }
}
