Author: Davis Breci
I was tasked to locate the cause for the variability of signal synchronization. The purpose of this file is to make a case for the modified dataset-collection.ino file included in this directory.

Within the original file's recordData function, the loop intended to collect data at fixed rate contained this line of code:
endTime = micros() + delayTime;
which calculates the end of each interval based on the start time of that interval.
This results in drift over time, as there is no constant reference point for timing. Consequently, the frequency of the data collection is less than 400Hz by a significant and variable amount.

This issue is addressed in the updated file.
The methodology is to synchronize the board's start time as much as possible, minimize the potential for random interruptions, and maintain a constant frequency by keeping time relative to the start time.
The start time delay measured with an oscilloscope is about 1-2ns, about one clock cycle on the Teensy 4.0.
All code that is not time-critical is executed outside the core data collection loop, particularly the slow Serial.println calls.
endTime is simply the start time + delayTime*(iterator).

Potential areas for improvement:
The most obvious thing to test is using a function generator as the trigger, rather than a wait loop.

Other files in this directory:
Screenshots of data taken with the updated code, with particular emphasis on the signals' minimally delayed response to a pulse, even 20+ seconds into recording.
A data csv file, and
A very crappy python script I used to make the plots.
