function [interval, maxSamples] = pico_timebase(device)
   timebase_index = 2; % corresponds to 2ns sample interval, max poss because we need channel 2 for trigger
   [~, interval, maxSamples] = invoke(device, 'ps2000aGetTimebase2', timebase_index, 0); 
   % Configure the device object's |timebase| property value.
   set(device, 'timebase', timebase_index);
end