function pico_set_trigger(device, channel)
    % get trigger group from device object
    triggerGroupObj = get(device, 'Trigger');
    triggerGroupObj = triggerGroupObj(1);
    
    invoke(triggerGroupObj, 'setSimpleTrigger', channel, 1000, 2); %channel, threshold (mV), direction (2 = rising)
end