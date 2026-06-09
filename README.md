# Pico-lib
A MATLAB wrapper library for controlling a picoscope 2000A

Full documentation can be found in the word file in this repository.

## Prerequisites

Note that the drivers for this are fiddly to get working, and if you do things in the wrong order it can be difficult to resolve the resulting mess. Follow the steps below in the correct order. These instructions are for Windows 10/11 - if you are using a different operating system you will need to look at the instructions on each of the following links and resolve any issues that occur. 

1. Install the Picoscope SDK from https://www.picotech.com/library/our-oscilloscope-software-development-kit-sdk#sdk_dl
2. Open MATLAB add-on installer, click "clear filters" in tahe search bar, then find and install the "PicoScope 2000 Series A API MATLAB Generic Instrument Driver".
3. Repeat step 2 for the "PicoScope Support Toolbox".
4. If not already installed, install the Instrumentation control toolbox from the MATLAB add-on installer.
5. From https://github.com/picotech/picosdk-c-wrappers/tree/master/ps2000a, install ps2000aWrap.dll and ps2000aWrap.lib, then place them into the Pico Technology folder in your Programs directory (e.g. C:\Program Files (x86)\Pico Technology\SDK\lib)
6. Go to C:\Users\[username\]\AppData\Roaming\MathWorks\MATLAB Add-Ons\Hardware Supports\PicoScope 2000 Series A API MATLAB Generic Instrument Driver and run:
	a. PS200SetConfig.m
	b. PS2000aConfig.m
	c. PS2000aSetup.m

## Description of functions

### scope = pico_setup(serial)
Takes the serial number of the picoscope device (printed on the back), and opens a connection to it. Returns an object which represents the connection to the scope that is passed to all future functions.

### pico_enable_channel(scope, channel, y_range)
Enables a channel for data collection. The channels are numbered starting at zero, and you do not need to enable the channel used as a trigger as that is done using the trigger functions. The y_range parameter indicates the maximum voltage that can be measured - allowed values are 10mV, 20mV, 50mV, 100mV, 200mV, 500mV, 1V, 2V, 5V, 10V. If you enter a value other than one of these the function will find the closest allowed value for you. This function sets the channel to be AC coupled, for DC coupling, use pico_enable_DC_channel.

### pico_enable_DC_channel(scope, channel, y_range)
Exactly the same as pico_enable_channel, only sets the coupling to DC.

### pico_disable_channel(scope, channel)
Disables a channel. You will rarely need to use this function because all of the channels default to off when the connection to the picoscope is opened - only use this if you need more channels initially than you do later in your script.

### pico_set_trigger(scope, channel)
Sets a simple rising edge trigger with a threshold of 1V on the given channel (numbered starting at zero).

### pico_set_trigger_thresh(scope, channel, mV)
Changes the trigger threshold voltage to the given value.

### \[interval, max_samples\] = pico_timebase(scope)
Asks the picoscope for some values to do with the timebase that you will need to pass to later functions when you collect data.

### \[time, chA, chB\] = pico_single_shot(scope, acquisitionLength, interval, maxSamples)
Gets single shot data for the first two channels, covering a time "acquisitionLength" (in seconds) after a trigger event. Returns the time and voltage arrays.

**Note: the following 3 functions are nominally identical except for allowing for more channels. There isn't really any advantage to using pico_averaged_waveform over pico_averaged_waveform3, but the old functions are retained to keep legacy code working.** All of the following functions will pause code execution until a trigger event occurs, prompting data collection.

### \[time, chA, chB\] = pico_averaged_waveform(scope, numAvg, acquisitionLength, interval, maxSamples)
Just like pico_single_shot only with averaging. The storage on the picoscope is fast, but limited, so if you request lots of averages or long signals then the averaging will be done in chunks on the picoscope then collected in the MATLAB function. For most signals and moderate number of averages, it will all be done on the scope, which is much faster.

### \[time, chA, chB, chC\] = pico_averaged_waveform2(scope, numAvg, acquisitionLength, interval, maxSamples)
Just like pico_averaged_waveform but collects data on all 3 channels (assuming channel D is used for the trigger signal).

### \[time, chA, chB, chC, chD\] = pico_averaged_waveform3(scope, numAvg, acquisitionLength, interval, maxSamples)
The same again but recording all four channels

### pico_close(scope)
Disconnects the scope from the PC. Note that this function **must** always be called before attempting to reopen the connection to the scope. It is helpful to have the following lines:
```
if(exist("scope")==1):
	pico_close(scope);
end
```
At the start of your script (before any clear, clc, or close all commands) to ensure that any previous connections are closed before you try to reopen one. If you do reopen a connection that is already open, the driver goes into an error state that can only be resolved by closing and re-opening MATLAB.

### pico_flash_led(scope, key)
Flashes the LED on the front of the picoscope. Key is a parameter which controls what the LED does:
key < 0: flash LED indefinitely
key = 0: stop LED flashing
key > 0: flash LED \[key\] times.

## Example scripts
Two example scripts are provided to get you started on how to use this library. They are also good for testing that the drivers are set up properly - just make sure that a trigger event actually occurs otherwise the programs will hang.

### Example_script.m
Connects to the scope, then collects single shot and averaged data. Flashes the LED 10 times, then plots the collected data and disconnects from the scope. Ensure that channel A has a signal between +/-2V and channel B has a trigger signal exceeding 1V inputted to it.

### Example_script2.m
Similar to Example_script.m but uses pico_averaged_waveform2 to collect data on channels A and B. The trigger should be input to channel C.
