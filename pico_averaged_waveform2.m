function [timebase, chA, chB, chC] = pico_averaged_waveform2(device, numAvg, acquisitionLength, interval, maxSamples)
    % optimisied function to get averaged waveforms from the picoscope.

    numAvg = numAvg+1; %offsets so 1 average is a single shot, then 2 is 2 traces etc.
    
    %convert interval to seconds
    interval = interval*1E-9;
    
    %calculate number of samples after trigger
    postTrigSamples = ceil(acquisitionLength/interval);
    if postTrigSamples > maxSamples
        postTrigSamples = maxSamples;
        warning("Acquisition length too long: Number of samples required is %d, but max No samples is %d", postTrigSamples, maxSamples);
    end
    set(device, 'numPreTriggerSamples', 0);
    set(device, 'numPostTriggerSamples', postTrigSamples);
    
    %segment the memory to store as many of those waveforms as possible
    storage_capacity = 32E6; %number of samples able to be stored between the two channels
    number_samples_per_waveform = postTrigSamples;
    max_num_segments = floor(storage_capacity/number_samples_per_waveform);
   
    % max num segments is total max for both channels. so chA can only have
    % half of those.
    one_ch_segments = floor(max_num_segments/2);
    
    downsamplingRatio       = 1; % 1 = not downsampled
    downsamplingRatioMode   = 0; % no aggregration / averaging etc. see ps2000aEnumInfo.enPS2000ARatioMode

    if numAvg > one_ch_segments
        warning("Number of averages exceeds memory on picoscope, actually getting %d averages", one_ch_segments);
        numAvg = one_ch_segments;
    end

    [~, nMaxSamples] = invoke(device, "ps2000aMemorySegments", numAvg);

    %check that nMaxSamples > required AcquisitionLength converte into
    %samples
    if nMaxSamples <= ceil(acquisitionLength/interval)
        warning("Memory segmentation error - segments not big enough to hold full waveform");
    end

    rapidBlockGroupObj = get(device, 'Rapidblock');
    rapidBlockGroupObj = rapidBlockGroupObj(1); %object decribing group of blocks

    %set number of captures required
    invoke(rapidBlockGroupObj, "ps2000aSetNoOfCaptures", numAvg);

    blockGroupObj = get(device, 'Block');
    blockGroupObj = blockGroupObj(1); %object descibing individual block

    % now capture each waveform
    invoke(blockGroupObj, 'runBlock', 0);

    %retrieve all data in bulk
    [numSamples,~,chA, chB, chC] = invoke(rapidBlockGroupObj, 'getRapidBlockData', numAvg-1, downsamplingRatio, downsamplingRatioMode);

    %calculate timebase
    timebase = interval * downsamplingRatio * double(0:numSamples - 1);

    %take mean to get averaged traces
    chA = mean(chA, 2);
    chB = mean(chB, 2);
    chC = mean(chC, 2);

    %convert to V
    chA = chA/1000;
    chB = chB/1000;
    chC = chC/1000;

end