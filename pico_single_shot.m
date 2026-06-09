function [timebase, chA, chB, triggerOffset] = pico_single_shot(device, acquisitionLength, interval, maxSamples)
   % sets up the picoscope to record for the required amount of time, then
   % collects a single waveform and returns it
   
   %interval returned from pico_timebase in ns => convert to seconds
   interval = interval * 1E-9;
   
   %get block group object from device object
   blockGroupObj = get(device, 'Block');
   blockGroupObj = blockGroupObj(1);
   
   %calculate number of samples after trigger
   postTrigSamples = ceil(acquisitionLength/interval);
   fprintf("Calculated # post trigger samples is %d", postTrigSamples);
   if postTrigSamples > maxSamples
      postTrigSamples = maxSamples;
      warning("Acquisition length too long: Number of samples required is %d, but max No samples is %d", postTrigSamples, maxSamples);
   end
   
   set(device, 'numPreTriggerSamples', 0);
   set(device, 'numPostTriggerSamples', postTrigSamples);
   
   % Retrieve data values:
   
   startIndex              = 0; %index to start acquisition on. 0 = where trigger is.
   segmentIndex            = 0; %memory segment its being stored in on the scope
   downsamplingRatio       = 1; % 1 = not downsampled
   downsamplingRatioMode   = 0; %no aggregration / averaging etc. see ps2000aEnumInfo.enPS2000ARatioMode
   
   %initiate data collection into picoscope memory block 0
   invoke(blockGroupObj, 'runBlock', segmentIndex);
   
   [numSamples, ~, chA, chB] = invoke(blockGroupObj, 'getBlockData', startIndex, segmentIndex, ...
       downsamplingRatio, downsamplingRatioMode);
   
   triggerOffset = invoke(blockGroupObj, "ps2000aGetTriggerTimeOffset", segmentIndex);

   %calculate timebase
   timebase = interval * downsamplingRatio * double(0:numSamples - 1);
   
   %convert from ints to volts
   chA = chA/1000;
   chB = chB/1000;
   
end