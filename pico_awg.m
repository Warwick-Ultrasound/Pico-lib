function pico_awg(device, waveform)
    % takes the device and an arbitrary waveform and sets the awg output to
    % output that waveform. The timebase for the aribitrary waveform should
    % be the same as that on the captured signal i.e. it should have points
    % in time separated by the "interval" returned by pico_timebase.

    wf = waveform;
    switch wf.type
        case "sine"
            type = PS2000A_SINE
    invoke(device, "ps2000aSetSigGenBuiltIn", ...
        wf.offset, ...
        wf.pkpk, ...
        wf.)
end

