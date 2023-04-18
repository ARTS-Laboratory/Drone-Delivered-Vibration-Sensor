//Include Libraries
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

//create an RF24 object
//RF24 radio(7, 6);  // CE, CSN
RF24 radio(10, 9);  // CE, CSN Corinne

//address through which two modules communicate.
const byte address[6] = "00001";

int PWM = 2;
int val = 0;
int BTN = 8;

void setup()
{
  Serial.begin(9600);
  pinMode(BTN, INPUT);
  radio.begin();
  
  //set the address
  radio.openWritingPipe(address);
  
  //Set module as transmitter
  radio.stopListening();
}
void loop()
{

  val = digitalRead(BTN);
  //Serial.println(val);

  
  //Send message to receiver
  if (val == 0 ){
  }

  else if (val == 1)  {   
  const int text1 = 1;
  radio.write(&text1, sizeof(text1));
  Serial.println(text1);
  delay(200); 
  }

  else {}

}
