function pico_set_trigger_thresh(device, channel, mV)
    % get trigger group from device object
    triggerGroupObj = get(device, 'Trigger');
    triggerGroupObj = triggerGroupObj(1);
    %help triggerGroupObj
    disp(invoke(triggerGroupObj, 'setSimpleTrigger', channel, mV, 2)); %channel, threshold (mV), direction (2 = rising)
end