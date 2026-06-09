clear;
clc;
close all;

serialNo = '11538/0024';
numAvg = 20;

%create device
dev = pico_setup(serialNo);

% enable transducer channels
pico_enable_channel(dev, 0, 2);
pico_enable_channel(dev, 1, 2);

%set up trigger
pico_set_trigger(dev, 2);

% setup timebase parameters for passing into data collection functions
[interval, maxSamples] = pico_timebase(dev);

%collect averaged data on both channels
[timebase, chA, chB] = pico_averaged_waveform2(dev, numAvg, 5E-6, interval, maxSamples);

%plot
figure;
clf;
plot(timebase, chA, timebase, chB);
legend("chA", "chB");

%close device connection
pico_close(dev);