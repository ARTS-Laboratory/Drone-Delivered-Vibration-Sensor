EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Vibration_Sensor-rescue:Teensy4.0-teensy-ARTS-Lab U2
U 1 1 6290ED71
P 3200 3950
F 0 "U2" H 3200 2335 50  0000 C CNN
F 1 "Teensy4.0-teensy" H 3200 2426 50  0000 C CNN
F 2 "custom:teensy4.0" H 2800 4150 50  0001 C CNN
F 3 "" H 2800 4150 50  0001 C CNN
	1    3200 3950
	-1   0    0    1   
$EndComp
$Comp
L Vibration_Sensor-rescue:microSD_small-ARTS-Lab Micro_SD1
U 1 1 62911122
P 6900 4350
F 0 "Micro_SD1" V 6854 4378 50  0000 L CNN
F 1 "microSD_small" V 6945 4378 50  0000 L CNN
F 2 "custom:small_microSD_v2" H 6900 4350 50  0001 C CNN
F 3 "" H 6900 4350 50  0001 C CNN
	1    6900 4350
	0    1    1    0   
$EndComp
$Comp
L Vibration_Sensor-rescue:main_board_top_rail-ARTS-Lab U5
U 1 1 629135F7
P 6650 5400
F 0 "U5" V 6599 5428 50  0000 L CNN
F 1 "main_board_top_rail" V 6690 5428 50  0000 L CNN
F 2 "custom:top_rail" H 6650 5400 50  0001 C CNN
F 3 "" H 6650 5400 50  0001 C CNN
	1    6650 5400
	0    1    1    0   
$EndComp
Wire Wire Line
	6250 4950 4800 4950
Wire Wire Line
	4800 4700 4300 4700
Wire Wire Line
	6250 5050 4500 5050
Wire Wire Line
	6100 4300 5250 4300
Wire Wire Line
	5250 4300 5250 4100
Wire Wire Line
	5250 4100 4300 4100
Wire Wire Line
	6250 5250 5250 5250
Wire Wire Line
	5250 5250 5250 4300
Connection ~ 5250 4300
Wire Wire Line
	5500 4000 4300 4000
Wire Wire Line
	6100 4500 5500 4500
Wire Wire Line
	5500 4500 5500 4000
Wire Wire Line
	6250 5150 5500 5150
Wire Wire Line
	5500 5150 5500 4500
Connection ~ 5500 4500
Wire Wire Line
	6100 4400 5050 4400
Wire Wire Line
	6250 5350 5050 5350
Wire Wire Line
	5050 5350 5050 4400
Connection ~ 5050 4400
$Comp
L power:GND #PWR0101
U 1 1 6291E9D0
P 6250 6500
F 0 "#PWR0101" H 6250 6250 50  0001 C CNN
F 1 "GND" H 6255 6327 50  0000 C CNN
F 2 "" H 6250 6500 50  0001 C CNN
F 3 "" H 6250 6500 50  0001 C CNN
	1    6250 6500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 6291F184
P 4300 6550
F 0 "#PWR0102" H 4300 6300 50  0001 C CNN
F 1 "GND" H 4305 6377 50  0000 C CNN
F 2 "" H 4300 6550 50  0001 C CNN
F 3 "" H 4300 6550 50  0001 C CNN
	1    4300 6550
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0104
U 1 1 629206E1
P 7150 4900
F 0 "#PWR0104" H 7150 4650 50  0001 C CNN
F 1 "GND" H 7155 4727 50  0000 C CNN
F 2 "" H 7150 4900 50  0001 C CNN
F 3 "" H 7150 4900 50  0001 C CNN
	1    7150 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6100 4600 6100 4750
Wire Wire Line
	4300 5300 4300 6550
Wire Wire Line
	6250 5850 6250 6500
Wire Wire Line
	6100 4750 7150 4750
Wire Wire Line
	7150 4750 7150 4900
Wire Wire Line
	4800 4950 4800 4700
Wire Wire Line
	4500 5050 4500 5100
Wire Wire Line
	4500 5100 4300 5100
$Comp
L Device:LED D1
U 1 1 6297D60E
P 7950 5400
F 0 "D1" H 7943 5617 50  0000 C CNN
F 1 "LED" H 7943 5526 50  0000 C CNN
F 2 "LED_THT:LED_D3.0mm" H 7950 5400 50  0001 C CNN
F 3 "~" H 7950 5400 50  0001 C CNN
	1    7950 5400
	0    1    1    0   
$EndComp
$Comp
L Device:R R1
U 1 1 629808D5
P 7950 5900
F 0 "R1" H 8020 5946 50  0000 L CNN
F 1 "R" H 8020 5855 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric_Pad1.30x1.75mm_HandSolder" V 7880 5900 50  0001 C CNN
F 3 "~" H 7950 5900 50  0001 C CNN
	1    7950 5900
	1    0    0    -1  
$EndComp
Wire Wire Line
	7950 5750 7950 5550
$Comp
L power:GND #PWR07
U 1 1 629822A6
P 7950 4950
F 0 "#PWR07" H 7950 4700 50  0001 C CNN
F 1 "GND" H 7955 4777 50  0000 C CNN
F 2 "" H 7950 4950 50  0001 C CNN
F 3 "" H 7950 4950 50  0001 C CNN
	1    7950 4950
	-1   0    0    1   
$EndComp
Wire Wire Line
	7950 5250 7950 4950
$Comp
L Vibration_Sensor-rescue:power_input-ARTS-Lab U1
U 1 1 629E65AA
P 3050 1600
F 0 "U1" H 3050 1001 50  0000 C CNN
F 1 "power_input" H 3050 1084 39  0000 C CNN
F 2 "custom:XT60PW" H 3050 1600 50  0001 C CNN
F 3 "" H 3050 1600 50  0001 C CNN
	1    3050 1600
	-1   0    0    1   
$EndComp
$Comp
L Device:Fuse F1
U 1 1 629E72CE
P 3850 1400
F 0 "F1" V 3653 1400 50  0000 C CNN
F 1 "Fuse" V 3744 1400 50  0000 C CNN
F 2 "Capacitor_SMD:C_1206_3216Metric_Pad1.33x1.80mm_HandSolder" V 3780 1400 50  0001 C CNN
F 3 "~" H 3850 1400 50  0001 C CNN
	1    3850 1400
	0    1    1    0   
$EndComp
$Comp
L Vibration_Sensor-rescue:grounded_DIP_switch-ARTS-Lab switch1
U 1 1 629E7EFF
P 4650 950
F 0 "switch1" H 4675 1115 50  0000 C CNN
F 1 "grounded_DIP_switch" H 4675 1024 50  0000 C CNN
F 2 "custom:grounded_switch" H 4650 950 50  0001 C CNN
F 3 "" H 4650 950 50  0001 C CNN
	1    4650 950 
	1    0    0    -1  
$EndComp
Wire Wire Line
	3350 1400 3700 1400
Wire Wire Line
	4000 1400 4450 1400
Wire Wire Line
	4450 1400 4450 1300
$Comp
L power:GND #PWR01
U 1 1 62A076E8
P 2600 1600
F 0 "#PWR01" H 2600 1350 50  0001 C CNN
F 1 "GND" H 2605 1427 50  0000 C CNN
F 2 "" H 2600 1600 50  0001 C CNN
F 3 "" H 2600 1600 50  0001 C CNN
	1    2600 1600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR02
U 1 1 62A07DE9
P 4100 1100
F 0 "#PWR02" H 4100 850 50  0001 C CNN
F 1 "GND" V 4105 972 50  0000 R CNN
F 2 "" H 4100 1100 50  0001 C CNN
F 3 "" H 4100 1100 50  0001 C CNN
	1    4100 1100
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR04
U 1 1 62A0860F
P 5250 1100
F 0 "#PWR04" H 5250 850 50  0001 C CNN
F 1 "GND" V 5255 972 50  0000 R CNN
F 2 "" H 5250 1100 50  0001 C CNN
F 3 "" H 5250 1100 50  0001 C CNN
	1    5250 1100
	0    -1   -1   0   
$EndComp
Wire Wire Line
	2750 1500 2600 1500
Wire Wire Line
	2600 1500 2600 1600
Wire Wire Line
	4250 1100 4100 1100
Wire Wire Line
	5100 1100 5250 1100
$Comp
L power:GND #PWR05
U 1 1 62A0D188
P 6050 2150
F 0 "#PWR05" H 6050 1900 50  0001 C CNN
F 1 "GND" H 6055 1977 50  0000 C CNN
F 2 "" H 6050 2150 50  0001 C CNN
F 3 "" H 6050 2150 50  0001 C CNN
	1    6050 2150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6250 5550 5000 5550
Wire Wire Line
	5000 5550 5000 2800
Wire Wire Line
	5000 2800 4300 2800
Wire Wire Line
	6250 5450 4450 5450
Wire Wire Line
	4450 5450 4450 2900
Wire Wire Line
	4450 2900 4300 2900
Wire Wire Line
	6600 2600 5850 2600
Wire Wire Line
	5850 4100 6100 4100
Wire Wire Line
	5850 4100 5850 5750
Wire Wire Line
	5850 5750 6250 5750
Connection ~ 5850 4100
Wire Wire Line
	7950 6050 4650 6050
Wire Wire Line
	4650 6050 4650 4900
Wire Wire Line
	4650 4900 4300 4900
Wire Wire Line
	5850 2600 5850 3400
Wire Wire Line
	1800 3000 2100 3000
Wire Wire Line
	6350 1600 6600 1600
Wire Wire Line
	6600 1600 6600 1800
Wire Wire Line
	6050 1900 6050 2000
$Comp
L power:GND #PWR03
U 1 1 62A97B4A
P 5150 2050
F 0 "#PWR03" H 5150 1800 50  0001 C CNN
F 1 "GND" H 5155 1877 50  0000 C CNN
F 2 "" H 5150 2050 50  0001 C CNN
F 3 "" H 5150 2050 50  0001 C CNN
	1    5150 2050
	1    0    0    -1  
$EndComp
Wire Wire Line
	1800 2250 1800 3000
Wire Wire Line
	5150 1900 5150 2000
$Comp
L Device:C C1
U 1 1 62AA8A79
P 4650 1850
F 0 "C1" H 4765 1896 50  0000 L CNN
F 1 "C" H 4765 1805 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric_Pad1.33x1.80mm_HandSolder" H 4688 1700 50  0001 C CNN
F 3 "~" H 4650 1850 50  0001 C CNN
	1    4650 1850
	1    0    0    -1  
$EndComp
$Comp
L Device:C C2
U 1 1 62AA97E3
P 5600 1850
F 0 "C2" H 5715 1896 50  0000 L CNN
F 1 "C" H 5715 1805 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric_Pad1.33x1.80mm_HandSolder" H 5638 1700 50  0001 C CNN
F 3 "~" H 5600 1850 50  0001 C CNN
	1    5600 1850
	1    0    0    -1  
$EndComp
$Comp
L Device:C C3
U 1 1 62AAA1A5
P 6500 1950
F 0 "C3" H 6615 1996 50  0000 L CNN
F 1 "C" H 6615 1905 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric_Pad1.33x1.80mm_HandSolder" H 6538 1800 50  0001 C CNN
F 3 "~" H 6500 1950 50  0001 C CNN
	1    6500 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	4650 2000 5150 2000
Connection ~ 5150 2000
Wire Wire Line
	5150 2000 5150 2050
Wire Wire Line
	5450 1600 5600 1600
Wire Wire Line
	5600 1600 5600 1700
Connection ~ 5600 1600
Wire Wire Line
	5600 1600 5750 1600
Wire Wire Line
	5600 1700 5450 1700
Wire Wire Line
	5450 1700 5450 2250
Connection ~ 5600 1700
Wire Wire Line
	5450 2250 1800 2250
Wire Wire Line
	5600 2000 6050 2000
Connection ~ 6050 2000
Wire Wire Line
	6050 2000 6050 2150
Wire Wire Line
	6600 1800 6500 1800
Connection ~ 6600 1800
Wire Wire Line
	6600 1800 6600 2600
$Comp
L power:GND #PWR06
U 1 1 62ABC621
P 6500 2100
F 0 "#PWR06" H 6500 1850 50  0001 C CNN
F 1 "GND" H 6505 1927 50  0000 C CNN
F 2 "" H 6500 2100 50  0001 C CNN
F 3 "" H 6500 2100 50  0001 C CNN
	1    6500 2100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 2250 5450 2500
Wire Wire Line
	5450 5650 6250 5650
Connection ~ 5450 2250
$Comp
L Regulator_Linear:AP7361C-33E U3
U 1 1 62B2E2F7
P 5150 1600
F 0 "U3" H 5150 1842 50  0000 C CNN
F 1 "AP7361C-33E" H 5150 1751 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-223-3_TabPin2" H 5150 1825 50  0001 C CIN
F 3 "https://www.diodes.com/assets/Datasheets/AP7361C.pdf" H 5150 1550 50  0001 C CNN
	1    5150 1600
	1    0    0    -1  
$EndComp
$Comp
L Regulator_Linear:AP7361C-33E U4
U 1 1 62B2EE61
P 6050 1600
F 0 "U4" H 6050 1842 50  0000 C CNN
F 1 "AP7361C-33E" H 6050 1751 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-223-3_TabPin2" H 6050 1825 50  0001 C CIN
F 3 "https://www.diodes.com/assets/Datasheets/AP7361C.pdf" H 6050 1550 50  0001 C CNN
	1    6050 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	4650 1300 4650 1600
Wire Wire Line
	4650 1600 4850 1600
Connection ~ 4650 1600
Wire Wire Line
	4650 1600 4650 1700
Wire Wire Line
	5050 3400 4300 3400
Wire Wire Line
	5050 3400 5050 4400
$Comp
L Vibration_Sensor-rescue:nRF24L01+-ARTS-Lab U6
U 1 1 62C72ED1
P 7050 3300
F 0 "U6" V 7461 2925 50  0000 C CNN
F 1 "nRF24L01+" V 7372 2925 47  0000 C CNN
F 2 "custom:nRF24L01+" H 7050 3300 50  0001 C CNN
F 3 "" H 7050 3300 50  0001 C CNN
	1    7050 3300
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6950 3400 5850 3400
Connection ~ 5850 3400
Wire Wire Line
	5850 3400 5850 4100
$Comp
L power:GND #PWR08
U 1 1 62C75A10
P 8050 3550
F 0 "#PWR08" H 8050 3300 50  0001 C CNN
F 1 "GND" H 8055 3377 50  0000 C CNN
F 2 "" H 8050 3550 50  0001 C CNN
F 3 "" H 8050 3550 50  0001 C CNN
	1    8050 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 3400 8050 3400
Wire Wire Line
	8050 3400 8050 3550
$Comp
L Timer_RTC:DS3231M U7
U 1 1 62EC2776
P 8200 2100
F 0 "U7" H 8200 1611 50  0000 C CNN
F 1 "DS3231M" H 8200 1520 50  0000 C CNN
F 2 "Package_SO:SOIC-16W_7.5x10.3mm_P1.27mm" H 8200 1500 50  0001 C CNN
F 3 "http://datasheets.maximintegrated.com/en/ds/DS3231.pdf" H 8470 2150 50  0001 C CNN
	1    8200 2100
	1    0    0    -1  
$EndComp
$Comp
L Device:Battery_Cell BT1
U 1 1 62EC8089
P 8400 1550
F 0 "BT1" V 8655 1600 50  0000 C CNN
F 1 "Battery_Cell" V 8564 1600 50  0000 C CNN
F 2 "custom:battery_holder_10mm" V 8400 1610 50  0001 C CNN
F 3 "~" V 8400 1610 50  0001 C CNN
	1    8400 1550
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8200 1700 8200 1550
$Comp
L power:GND #PWR010
U 1 1 62ECB357
P 8500 1550
F 0 "#PWR010" H 8500 1300 50  0001 C CNN
F 1 "GND" H 8505 1377 50  0000 C CNN
F 2 "" H 8500 1550 50  0001 C CNN
F 3 "" H 8500 1550 50  0001 C CNN
	1    8500 1550
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR09
U 1 1 62ECBC49
P 8200 2500
F 0 "#PWR09" H 8200 2250 50  0001 C CNN
F 1 "GND" H 8205 2327 50  0000 C CNN
F 2 "" H 8200 2500 50  0001 C CNN
F 3 "" H 8200 2500 50  0001 C CNN
	1    8200 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 2500 7050 2500
Wire Wire Line
	7050 2500 7050 1700
Wire Wire Line
	7050 1700 8100 1700
Connection ~ 5450 2500
Wire Wire Line
	5450 2500 5450 5650
Wire Wire Line
	7700 2000 6850 2000
Wire Wire Line
	6850 2000 6850 2900
Wire Wire Line
	6850 2900 4450 2900
Connection ~ 4450 2900
Wire Wire Line
	7700 1900 6900 1900
Wire Wire Line
	6900 1900 6900 2800
Wire Wire Line
	6900 2800 5000 2800
Connection ~ 5000 2800
Wire Wire Line
	6950 3100 4550 3100
Wire Wire Line
	4550 3100 4550 5200
Wire Wire Line
	4550 5200 4300 5200
Wire Wire Line
	6950 3200 5250 3200
Wire Wire Line
	5250 3200 5250 4100
Connection ~ 5250 4100
Wire Wire Line
	7900 3000 5500 3000
Wire Wire Line
	5500 3000 5500 4000
Connection ~ 5500 4000
Wire Wire Line
	4700 4800 4300 4800
Wire Wire Line
	6100 4200 4700 4200
Wire Wire Line
	4700 4200 4700 4800
Wire Wire Line
	7900 3300 8350 3300
Wire Wire Line
	8350 3300 8350 3900
Wire Wire Line
	8350 3900 4750 3900
Wire Wire Line
	4750 3900 4750 4500
Wire Wire Line
	4750 4500 4300 4500
Wire Wire Line
	6950 3300 4650 3300
Wire Wire Line
	4650 3300 4650 4600
Wire Wire Line
	4650 4600 4300 4600
Wire Wire Line
	5050 2950 5050 3400
Connection ~ 5050 3400
Wire Wire Line
	7900 3000 7900 3100
Wire Wire Line
	7950 2950 7950 3200
Wire Wire Line
	7950 3200 7900 3200
Wire Wire Line
	5050 2950 7950 2950
$EndSCHEMATC
