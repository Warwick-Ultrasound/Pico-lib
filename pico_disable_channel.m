function pico_disable_channel(device, channel)
    % Channels       : 0 - 1 (ps2000aEnuminfo.enPS2000AChannel.PS2000A_CHANNEL_A & PS2000A_CHANNEL_B)
    % Enabled        : 1 (PicoConstants.TRUE)
    % Type           : 1 (0 = AC coupling, 1 = DC coupling)
    % Range          : 8 (ps2000aEnuminfo.enPS2000ARange.PS2000A_5V)
    % Analog Offset  : 0.0 V
    y_range = 0.05;
    %actual_yrange will need to be passed to the function retrieving data
    % so integer y vals can be converted to voltages
    poss_y_ranges = [10E-3, 20E-3, 50E-3, 100E-3, 200E-3, 500E-3, 1, 2, 5, 10];
    corresponding_ints = 0:length(poss_y_ranges)-1; %set range in y by using integer values corresponding to allowed values
    
    %find closest match for yrange
    [~,min_i] = min(abs(y_range-poss_y_ranges));
    req_int = corresponding_ints(min_i); %required integer to set closest y range value
    
    invoke(device, 'ps2000aSetChannel', channel, 0, 0, req_int, 0.0);
end