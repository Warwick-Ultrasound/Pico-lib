function device = pico_setup(Serial_No) %codegen
    %load config info
    PS2000aConfig;
    
    % Check if an Instrument session using the device object |ps2000aDeviceObj|
    % is still open, and if so, disconnect if the User chooses 'Yes' when prompted.
    if (exist('ps2000aDeviceObj', 'var') && ps2000aDeviceObj.isvalid && strcmp(ps2000aDeviceObj.status, 'open'))
        
%         openDevice = questionDialog(['Device object ps2000aDeviceObj has an open connection. ' ...
%             'Do you wish to close the connection and continue?'], ...
%             'Device Object Connection Open');
        openDevice = PicoConstants.TRUE;
        
        if (openDevice == PicoConstants.TRUE)
            
            % Close connection to device.
            disconnect(ps2000aDeviceObj);
            delete(ps2000aDeviceObj);
            
        else
            
            % Exit script if User selects 'No'.
            return;
            
        end
        
    end
    
    % Create a device object.
    % The serial number can be specified as a second input parameter.
    ps2000aDeviceObj = icdevice('picotech_ps2000a_generic.mdd', Serial_No);
    device = ps2000aDeviceObj; %so can pass to calling script
    
    % Connect device object to hardware.
    
    connect(device);
    
end