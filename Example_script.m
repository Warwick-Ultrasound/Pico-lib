clear;
clc;
close all;

%set up device
device = pico_setup('IU908/0031');

%enable channel A with a +/- 2V y range
pico_enable_channel(device, 0, 2);

%set up trigger on channel B
pico_set_trigger(device, 1);

% setup timebase parameters for passing into data collection functions
[interval, maxSamples] = pico_timebase(device);

%collect single shot data on both channels
[timebase, chA, chB] = pico_single_shot(device, 5E-6, interval, maxSamples);

%plot single shot waveforms
figure;
clf;
plot(timebase, chA);
hold on;
plot(timebase, chB);
hold off;
title("Single shot waveforms");
legend("Channel A", "Channel B");
xlabel("Time /\mu{s}");
ylabel("Voltage /V");

%set number of averages and invoke function to collect them
numAvg = 12;
[timebase, chA, chA2] = pico_averaged_waveform(device, numAvg, 500E-6, interval, maxSamples);

%plot averaged waveform
figure;
clf;
plot(timebase, chA);
hold on;
plot(timebase, chA2);
hold off;
title("Averaged waveforms");
legend("Channel A", "Channel B");
xlabel("Time /\mu{s}");
ylabel("Voltage /V");

%flash LED
pico_flash_led(device, 10);

%close device connection
pico_close(device);
