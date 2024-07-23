I
Q
ts

afg_gpib_adress= 5;
awg_ip = open_inst_AFG(afg_gpib_adress); 

AFG_set_amp(awg_ip, 1, 0.1)
AFG_set_amp(awg_ip, 2, 0.2)
AFG_set_freq(awg_ip,1,0.1)
AFG_set_freq(awg_ip,2,0.2)
AFG_set_offset(awg_ip,1,0.1)
AFG_set_offset(awg_ip,2,0.2)
AFG_set_phase(awg_ip, 1, 45)
AFG_set_phase(awg_ip, 2, -45)



%% 
[I,Q,fc] = data_waveform_scale_for_AFG (I,Q, ts);
%fc=1.e3*1/(ts*np);
%set_AFG_sampling_rate(awg_ip, fs_MHz) 

AFG_wave_transfer_binary(I,awg_ip,1);
AFG_set_freq(awg_ip,1,fc)
AFG_set_amp(awg_ip, 1, 1)
AFG_set_offset(awg_ip ,1 ,0.5)

AFG_wave_transfer_binary(Q,awg_ip,2);
AFG_set_freq(awg_ip,2,fc)
AFG_set_amp(awg_ip, 2, 1)
AFG_set_offset(awg_ip ,2 ,0.5)

fclose(awg_ip)
