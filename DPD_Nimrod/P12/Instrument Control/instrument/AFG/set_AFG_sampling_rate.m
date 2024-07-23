function set_AFG_sampling_rate(awg_ip, fs_MHz) 
 global awg_type

switch(awg_type)
    case('tek_afg')
        fprintf(awg_ip,['SOURCE1:FREQUENCY ',num2str(fs_MHz),'M'])
    case('tabor')
        fprintf(awg_ip, [':freq:rast ',num2str(1.e9*fs_MHz)]);   %%%%%%%%%%%% the sampling rate can be changed here
end

pause(0.5)