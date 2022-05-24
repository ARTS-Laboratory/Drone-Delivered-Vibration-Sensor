/*
 * Copyright 2020 ARTS Lab @ University of South Carolina
 * Author: Hung-Tien Huang
 */

#include "SCA3300.h"

const byte chipSelect = 10; // teansy 4.1 dev
//const byte chipSelect = 5; // teansy 4.0 spi
const uint32_t spiSpeed = 2000000; // typ. f_sck = 2 MHz
sca3300_library::SCA3300 sca3300(chipSelect, spiSpeed, sca3300_library::OperationMode::MODE3, true);

// the setup function runs once when you press reset or power the board
void setup() {
	Serial.begin(9600);
	Serial.println(sca3300.initChip());
	Serial.println(sca3300.getWhoAmI());
	Serial.println(sca3300.getWhoAmI());
	Serial.println(sca3300.getWhoAmI());
}

// the loop function runs over and over again until power down or reset
void loop() {
	delay(1);
	//delayMicroseconds(10);
	Serial.println(sca3300.getAccel(sca3300_library::Axis::Z));
}
