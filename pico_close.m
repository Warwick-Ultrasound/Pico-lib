function pico_close(device)  
    %Stop the device
    
    invoke(device, 'ps2000aStop');
    
    % Disconnect device
    % Disconnect device object from hardware.
    
    disconnect(device);
    delete(device);
end