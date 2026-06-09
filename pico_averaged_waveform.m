function [timebase, chA, chB] = pico_averaged_waveform(device, numAvg, acquisitionLength, interval, maxSamples)
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
    storage_capacity = 128E6; %number of samples able to be stored between the two channels
    number_samples_per_waveform = postTrigSamples;
    max_num_segments = floor(storage_capacity/number_samples_per_waveform);
   
    % max num segments is total max for both channels. so chA can only have
    % half of those.
    one_ch_segments = floor(max_num_segments/2);
    
    downsamplingRatio       = 1; % 1 = not downsampled
    downsamplingRatioMode   = 0; % no aggregration / averaging etc. see ps2000aEnumInfo.enPS2000ARatioMode
    
    %% if there are enough segments to do it all in one go, do that
    if one_ch_segments > numAvg
       
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
       [numSamples,~,chA, chB] = invoke(rapidBlockGroupObj, 'getRapidBlockData', numAvg-1, downsamplingRatio, downsamplingRatioMode);

       %take mean to get averaged traces
       chA = mean(chA, 2);
       chB = mean(chB, 2);
       
       %convert to V
       chA = chA/1000;
       chB = chB/1000;
    end %end if enough segemnts for one go
    
    %% if there aren't enough segments, need to do it in chunks
    if one_ch_segments < numAvg

        [~, nMaxSamples] = invoke(device, "ps2000aMemorySegments", one_ch_segments);
        
        %check that nMaxSamples > required AcquisitionLength converte into
        %samples
        if nMaxSamples < ceil(acquisitionLength/interval)
            warning("Memory segmentation error - segments not big enough to hold full waveform");
        end
        
        % set up arrays for result
        chA = zeros(ceil(acquisitionLength/interval),1);
        chB = zeros(ceil(acquisitionLength/interval),1);
        
        %work out number of times we will need to collect data from the
        %scope
        num_retrieve = ceil(one_ch_segments/numAvg);
        
        %loop through and get all the data, adding it to the average each
        %time
        downsamplingRatio       = 1; % 1 = not downsampled
        downsamplingRatioMode   = 0; % no aggregration / averaging etc. see ps2000aEnumInfo.enPS2000ARatioMode
        
        rapidBlockGroupObj = get(device, 'Rapidblock');
        rapidBlockGroupObj = rapidBlockGroupObj(1); %object decribing group of blocks
        
        for ii = 1:num_retrieve
            %set number of captures required
            invoke(rapidBlockGroupObj, "ps2000aSetNoOfCaptures", one_ch_segments);
            
            blockGroupObj = get(device, 'Block');
            blockGroupObj = blockGroupObj(1); %object descibing individual block
            
            % now capture each waveform
            invoke(blockGroupObj, 'runBlock', 0);
            
            %retrieve all data in bulk
            [numSamples,~,chAnew, chBnew] = invoke(rapidBlockGroupObj, 'getRapidBlockData', numAvg-1, downsamplingRatio, downsamplingRatioMode);
            
            %take mean to get averaged traces
            chAnew = mean(chAnew, 2);
            chBnew = mean(chBnew, 2);
            
            chA = chA + chAnew;
            chB = chB + chBnew;
        end %end loop through chunks
        
        chA = chA/1000;
        chB = chB/1000;
        
    end % end if need multiple chunks
    
    %calculate timebase
    timebase = interval * downsamplingRatio * double(0:numSamples - 1);

end