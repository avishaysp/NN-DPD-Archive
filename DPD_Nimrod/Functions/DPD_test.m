addpath(genpath('C:\merlin2-python-master\KU1500'))
addpath('C:\Program Files\MATLAB\R2020b\iqtools')
ESG_addr = {'169.254.53.12','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_addr); % open ESG
VSA = open_vsa_visa();                    % open VSA, tcpip address inside
%% generate QPSK
M = 16; Fs = 32e6; num_samples = 50e3; alpha = 0.15; OS = 8;
% M = 4; Fs = 60e6; num_samples = 312*5; alpha = 0.15; OS = 3;
iqdata = genQAM(M,num_samples,OS,alpha);
% iqdata = [zeros(1,64)  iqdata.'  zeros(1,64)].';
PAPR = db(max(abs(iqdata))/rms(iqdata)); disp(PAPR)
close all
plot(1e-6*linspace(-Fs/2,Fs/2,length(iqdata)),db(fftshift(fft(iqdata))))
% xlim([-4 4])
grid
movegui
figure
t = 0:1/Fs:(1/Fs)*(length(iqdata)-1);
plot(1e6*t,abs(iqdata))
movegui('west')
% write QPSK to ESG
fRF   = 566e6;        % center frequency
Pout  = 18;           % dBm
set_sg_freq(ESG, fRF) % center frequency
set_sg_power(ESG,Pout)    % output power
ESG_load_IQ(ESG, iqdata.', Fs*1e-6);
set_sg_marker_Nimrod(ESG,1,'MATLAB_WFM.bin',1,round(length(iqdata)*0.75/100)*100,1)
%%
fprintf(VSA, ':INIT:CONT 0');
pause(6)
in = readVSA_visa_Yaxis(VSA, 2);
out = readVSA_visa_Yaxis(VSA, 5);
% t = readVSA_visa_Xaxis(VSA, 1, 5);
fprintf(VSA, ':INIT:CONT 1');

plot(real(in)/rms(in));hold on;plot(real(out)/rms(out))
figure
plot(imag(in)/rms(in));hold on;plot(imag(out)/rms(out))

movegui

% Model Parameters
fprintf('Running training sequance:\n');
  
signal.Input_signal_BW      = 4;    % [MHz]
signal.signal_sample_rate   = 32;    % [MHz]

model.polynomialType = 'full';  
model.upgraded_polynom = false;
model.add_IQ_nonlinearity_term = false;
% mibs    
mibs.frame_band_width = signal.Input_signal_BW;
mibs.tx_bbf_band_width = signal.Input_signal_BW;
mibs.ofdm_type = 'vht'; mibs.duplicate = 0;
mibs.ht_mcs32 = 0;
mibs.n_tx = 1;

%% PA fitting   
close all

level = -2;

model.PA_k = 5;     % PA fitting model - nonlinear 
model.PA_q = 2;     % PA fitting model - memory 

model.k = model.PA_k;        % DPD fitting model - nonlinear
model.q = model.PA_q;        % DPD fitting model - memory 

Input_signal = resample(in.',32,32);
Output_signal = resample(out.',32,32);
linear_gain_1 = rms(Output_signal)./rms(Input_signal);
% Input_signal = Input_signal/rms(Input_signal);
% Output_signal = Output_signal/rms(Output_signal);

% Error analysis 
v_error = (Input_signal).*linear_gain_1 - (Output_signal); 
v_error_rms = 10*log10(  rms(v_error).^2 / 50 * 1000 );

if 1 % Model Specification        
    % Create X_matrix,PA_X_Matrix from the input signal
    X_Matrix_PA = Build_Signal_Matrix(Input_signal,model,'PA');
    % Estimate PA coefficients - Pseudo Inverse
    PA_coef = Estimate_DPD_coeffs_open(X_Matrix_PA,Output_signal./linear_gain_1);
    % Check PA estimation level
    Output_no_DPD_estimated = X_Matrix_PA * PA_coef;         
end       
if 1 % Plot AM/AM - AM/PM core    
    figure; subplot(2,1,1); hold on; grid on;
    % 1. AM/AM RAW data 
    plot(10.*log10(linear_gain_1.*(abs(Input_signal)).^2/50*1000), ...
            20*log10( abs(Output_signal./linear_gain_1) ./ abs(Input_signal) ),'or','MarkerSize',2);
    % 2. AM/AM Fitted data
    plot(10.*log10(linear_gain_1 .* abs(Input_signal).^2/50*1000), ...
                20*log10(abs(Output_no_DPD_estimated)./abs(Input_signal)),'kx','MarkerSize',5);   
    axis([ -10 20 -10 5]);
    title('AM2AM Results'); xlabel('Pout [dBm]'); ylabel('AM/AM [dB]');

    subplot(2,1,2);  hold on; grid on;
    % 1. AM/PM RAW data 
    plot(10.*log10(linear_gain_1.*(abs(Input_signal)).^2/50*1000), ...
             ( angle(Output_signal./linear_gain_1 ./ Input_signal ) )./pi*180,'or','MarkerSize',2);        
    % 2. AM/PM Fitted data
    plot(10.*log10(linear_gain_1 .* abs(Input_signal).^2/50*1000), ...
            (angle(Output_no_DPD_estimated./Input_signal))./pi*180,'kx','MarkerSize',5);        
    xlabel('Pout [dBm]'); ylabel('AM/PM [Degrees]'); 
    title(['AM2PM Results']); axis([-10 20 -50 50]);    
end
if 1 % Plot PSD & Evaluate Fitting
    rate = signal.signal_sample_rate*1e6;                                    
    Nfft  = (round(rate/312.5e3));

    res_error_floor = (Output_signal./rms(Output_signal) - Output_no_DPD_estimated./rms(Output_no_DPD_estimated));
    % Spectral Terms 
    % Around frame #1
    [spec_sig_in,          f1] = psd_dBV(linear_gain_1.*Input_signal,Nfft,rate);                spec_sig_in          = spec_sig_in*(1e3/50);
    [spec_sig_out,         f2] = psd_dBV(Output_signal,Nfft,rate);                              spec_sig_out         = spec_sig_out*(1e3/50);
    [spec_sig_out_fitted,  f3] = psd_dBV(linear_gain_1.*Output_no_DPD_estimated,Nfft,rate);     spec_sig_out_fitted  = spec_sig_out_fitted*(1e3/50);
    [spec_res_noise_floor, f4] = psd_dBV(res_error_floor,Nfft,rate);                            spec_res_noise_floor = spec_res_noise_floor*(1e3/50);

    % Temporary workaround  
    spec_res_noise_floor( ( f4 > -500e3 ) & (f4 < 500e3) ) = eps; 

    figureno = 100;
    figure(figureno);  
             plot(f1/1e6, dB10(spec_sig_in)  , 'b', 'LineWidth', 2);
    hold on; plot(f2/1e6, dB10(spec_sig_out) , 'm', 'LineWidth', 2);
    grid on; plot(f3/1e6, dB10(spec_sig_out_fitted) , 'r', 'LineWidth', 2);
             plot(f4/1e6, dB10(spec_res_noise_floor) , 'k', 'LineWidth', 2);
    legend('Ideal', 'Measured' , 'Fitted' , 'floor','Location','SouthWest');   title('Frame #1 - PA out');
%     axis([ -80 80 -80 20]);     

    Vout_band = rms_in_band(f2/1e6, 2*spec_sig_out, 0, signal.Input_signal_BW ,figureno, 1, 'm');
    Vin_band = rms_in_band(f4/1e6, 2*spec_res_noise_floor, 0, signal.Input_signal_BW ,figureno, 1, 'k');

    inband_floor = (2*dB10(Vin_band /Vout_band));
    rout = Output_signal./rms(Output_signal) - Output_no_DPD_estimated./rms(Output_no_DPD_estimated);
end    
 
fprintf('\n');   
fprintf('Debug PA Fitting Core:\n');
fprintf('==================== \n');
fprintf('Training Sequance results\n')
fprintf('PA fitting poly K = %d , M = %d \n', model.PA_k, model.PA_q);
fprintf('In-band floor = %3.2f [dBc]\n', inband_floor);
fprintf('Training MSE  = %3.3f [dB]\n', 10*log10(sum(abs(rout).^2)./length(rout)));

% DPD fitting  

PA_estimation_output_error = mean(abs(Output_signal-linear_gain_1 .* Output_no_DPD_estimated).^2)/mean((abs(Output_signal)).^2);
PA_estimation_output_errordB=10*log10(PA_estimation_output_error);
fprintf('Out vs. Out after PA est.    err: %3.1f dB\n', PA_estimation_output_errordB);

model.K = model.k;
model.M = model.q;
% model.calc2 = 0;
% model.calc3 = 0;
% model.k_for_q = 0;
% model.calc2_q = 0;
% model.pulling_q = 0;
% model.SF = 1;
% Post-distortion
Y_Matrix = Build_Signal_Matrix_open(Output_signal./linear_gain_1,model,'DPD');
DPD_coef_Inverse_Matrix = Estimate_DPD_coeffs_open(Y_Matrix,Input_signal);
Input_signal_post_inv = Y_Matrix*DPD_coef_Inverse_Matrix;

% Pre-distortion 
% level = -4; % dB
X_Matrix = Build_Signal_Matrix(Input_signal .* (10.^(level./20)),model,'DPD'); %with DPD size k,q
Input_signal_DPD = X_Matrix*DPD_coef_Inverse_Matrix;
Y_Matrix = Build_Signal_Matrix(Input_signal_DPD,model,'PA');
Output_DPD = linear_gain_1 .* Y_Matrix * PA_coef;

if 1 % Plot spectral desity       

    rate = signal.signal_sample_rate*1e6;                                    
    Nfft  = (round(rate/312.5e3))*10;
    res_error_floor = (Input_signal - Input_signal_post_inv);% ./ (linear_gain_1.*sig_out_raw);
    res_error_floor = res_error_floor - mean(res_error_floor);


    % Spectral Terms 
    % Around frame #1
    [spec_sig_in,          f1] = psd_dBV(linear_gain_1.*Input_signal,Nfft,rate);          spec_sig_in          = spec_sig_in*(1e3/50);
    [spec_sig_out,         f2] = psd_dBV(Output_signal,Nfft,rate);                        spec_sig_out         = spec_sig_out*(1e3/50);
    [spec_sig_post_inv,    f3] = psd_dBV(linear_gain_1.*Input_signal_post_inv,Nfft,rate); spec_sig_post_inv    = spec_sig_post_inv*(1e3/50);
    [spec_res_noise_floor, f4] = psd_dBV(res_error_floor,Nfft,rate);                      spec_res_noise_floor = spec_res_noise_floor*(1e3/50);
    [spec_Output_DPD, f5]      = psd_dBV(Output_DPD,Nfft,rate);                           spec_Output_DPD = spec_Output_DPD*(1e3/50);

    
    figureno = 200;
    figure(figureno);  plot(f1/1e6, dB10(spec_sig_in)     , 'b', 'LineWidth', 2);
    hold on; plot(f2/1e6, dB10(spec_sig_out)              , 'm', 'LineWidth', 2);
    grid on; plot(f3/1e6, dB10(spec_sig_post_inv)         , 'r', 'LineWidth', 2);
             plot(f4/1e6, dB10(spec_res_noise_floor)      , 'k', 'LineWidth', 2);
             plot(f5/1e6, dB10(spec_Output_DPD)      , 'g', 'LineWidth', 2);

    legend('Ideal', 'Output w/o DPD' , ...
                    ['Output w/DPD: k = ' num2str(model.k) ',m = ' num2str(model.q) ], ...
                    'DPD-Floor' , ...
                    'Pre-Distort'         );
    xlim([-signal.signal_sample_rate  signal.signal_sample_rate]/2); 
    ylim([-100 0])
%     ylim([-60 40])
    % RMS calculation 
    Vout_band = rms_in_band(f4/1e6, 2*spec_sig_out, 0, signal.Input_signal_BW ,figureno, 1, 'm');
    Vin_band = rms_in_band(f4/1e6, 2*spec_res_noise_floor, 0, signal.Input_signal_BW ,figureno, 1, 'k');

    inband_floor = (2*dB10(Vin_band /Vout_band));

end    

fprintf('\n');   
fprintf('DPD performance:\n');
fprintf('=============== \n');
fprintf('PA fitting poly K = %d , M = %d \n', model.k, model.q);
fprintf('RMS Error [meas - Fit] = %3.2f [dBc]\n', inband_floor);

disp(['PAPR = ',num2str(db(max(abs(Input_signal_DPD))/rms(Input_signal_DPD)))])


% send predistorted signal to ESG
% in_dpd = Input_signal_DPD;
in_dpd = clip_sig(Input_signal_DPD,15,5);
Fs = 32e6;
% ESG_load_IQ(ESG, in_dpd_clip.', Fs*1e-6);
ESG_load_IQ(ESG, in_dpd.', Fs*1e-6);
% ESG_load_IQ(ESG, iqdata.', Fs*1e-6);
set_sg_marker_Nimrod(ESG,1,'MATLAB_WFM.bin',1,round(length(in_dpd)*0.75/100)*100,1)