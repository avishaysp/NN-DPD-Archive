%% Generate OFDM Signal - 

%% Enviornment Setting

addpath('Modem11a');  clc; clear all; 

%% Parameter Settings
% Set Modulation 64QAM, Code Rate = 3/4
rate = 9; % 54 
packet_data_length= 2000;

%% Create OFDM Signal 
BW_wifi=1;  %%% 1- 20MHz 2- 40MHz 4 - 80MHz
Samp_rate = 40*BW_wifi*1e6;
Fsamp_new = 1*1600*1e6;       
R1=Fsamp_new/Samp_rate;
CF_limit=8;

for ii = 1:1:2
    % Build 20MHz (centered) Signal with sampling rate of 40MHz
    rand('state',mod(sum(datestr(now)),ii*5));
    time_sig_modem=transmiter(rate,packet_data_length);
    time_signal=clip_filt_sig(time_sig_modem,CF_limit,3,0.2,R1);  %% perform clip filter on the signal
    time_signal_out(:,ii) = time_signal(:);
end

%% Store Signals 
sig_in_1 = time_signal_out(:,1);
sig_in_2 = time_signal_out(:,2);
save([pwd filesep 'Frames\OFDM_Frame_1_BPSK.mat'],'sig_in_1');
save([pwd filesep 'Frames\OFDM_Frame_2_BPSK.mat'],'sig_in_2');





%% Evaluate frames 
% Statistics
Nfft  = round(Fsamp_new) /312.5e3;
[spec_sig_in,f]  = psd_dBV(time_signal_out(:,1) + time_signal_out(:,2),Nfft,Fsamp_new);
figure;  plot(f/1e6, dB10(spec_sig_in), 'b', 'LineWidth', 2);
grid on; 

% warning('off','MATLAB:Axes:NegativeDataInLogAxis');
% crest = signal_crest(time_signal.',1,50);
% PAPR  = dB10( 10^(crest.real.peak_999/20)^2 / 10^(crest.real.rms/20)^2 );
% title(['Crest Analysis - Output Signal after DPD - PAPR = ',num2str(PAPR),'dB']);

%% 
% sig_in_2 = time_signal;
% save('Emanuel_File_2.mat','sig_in_2');

