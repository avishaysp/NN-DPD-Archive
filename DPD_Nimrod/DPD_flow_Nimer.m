function [Input_signal_DPD] = DPD_flow_Nimer(sig_org,Y,XDelta,BW)

%% Parameters   
fprintf('Running training sequance:\n');
  
signal.Input_signal_BW      = BW;    % [MHz]
signal.signal_sample_rate   = 640;    % [MHz]
signal.esg_sample_rate      = 64e9;    % [MHz]
signal.is_CW                = 0;


model.PA_k = 7;    % PA fitting model - nonlinear 
model.PA_q = 5;     % PA fitting model - memory 

model.k = 7;        % DPD fitting model - nonlinear
model.q = 5;        % DPD fitting model - memory 

model.polynomialType = 'full';  
model.upgraded_polynom = false;
model.add_IQ_nonlinearity_term = false;
% mibs    
mibs.frame_band_width = signal.Input_signal_BW;
mibs.tx_bbf_band_width = signal.Input_signal_BW;
mibs.ofdm_type = 'vht'; mibs.duplicate = 0;
mibs.ht_mcs32 = 0;
mibs.n_tx = 1;


% Define input signal
% curr_input_signal  = [pwd filesep 'DATA' filesep 'OFDM_20M_r54_clean_40Ms.mat'];
% Input_signal = load(curr_input_signal,'time_signal'); Input_signal = Input_signal.time_signal;
% Input_signal = Input_signal(:); signal_sample_rate = 40e6;

% measured_dir       = [pwd filesep 'DATA' filesep]; 
% measured_pa_output = 'OrigSigEvm40_QPSKA';
% Output_signal = load([measured_dir measured_pa_output], 'Y');
% Input_signal = double(Output_signal.Y);
% calculate Output sample frequency
% XDelta = load([measured_dir measured_pa_output], 'XDelta');
% signal.signal_sample_rate = ceil(1e-6/XDelta.XDelta);

% load('C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\BW20FS640_QPSK_A.mat');
signal.signal_sample_rate = 640;
Input_signal = sig_org/max(abs(sig_org));

% Define output signal
% measured_dir       = [pwd filesep 'DATA' filesep]; 
% measured_pa_output = '-2.7dBm_Evm24_QPSKA.mat';
% Output_signal = load([measured_dir measured_pa_output], 'Y');
Output_signal.Y = Y;
Output_signal.XDelta = XDelta;
Output_sample_rate = round(1/Output_signal.XDelta*1e-6);
Output_signal = double(Output_signal.Y);
% calculate Output sample frequency
% XDelta = load([measured_dir measured_pa_output], 'XDelta');
% Output_sample_rate = ceil(1e-6/XDelta.XDelta);



%% Align        
% Resample signals 

mutual_sample_rate   = min(signal.signal_sample_rate,Output_sample_rate);
Input_signal         = resample(Input_signal,mutual_sample_rate,signal.signal_sample_rate);
Output_signal        = resample(Output_signal,mutual_sample_rate,Output_sample_rate);                  

% Align Signals
Display_Aligned_Signals = true; %true\false
[Input_signal,Output_signal] = XCore(Input_signal, Output_signal, 1, 1);
[Input_signal,Output_signal] = MakeSignalsAlignment_FD(Input_signal,Output_signal,Display_Aligned_Signals,signal,0);
linear_gain_1 = rms(Output_signal)./rms(Input_signal); %Estimate_linear_Gain( Input_signal, Output_signal );

%% PA fitting   

% Error analysis 
v_error = (Input_signal).*linear_gain_1 - (Output_signal); 
v_error_rms = 10*log10(  rms(v_error).^2 / 50 * 1000 );

if 1 % Model Specification        
    % Create X_matrix,PA_X_Matrix from the input signal
    X_Matrix_PA = Build_Signal_Matrix(Input_signal,model,'PA');
    X_Matrix = Build_Signal_Matrix(Input_signal,model,'DPD'); %with DPD size k,q
    X_Matrix_orig = Build_Signal_Matrix(Input_signal,model,'DPD'); %with DPD size k,q

    % Estimate PA coefficients - Pseudo Inverse
    PA_coef = Estimate_PA_coeffs(X_Matrix_PA,Output_signal./linear_gain_1);

    % Check PA estimation level
    Output_no_DPD_estimated = X_Matrix_PA * PA_coef;

    % figure; plot(abs(Input_signal),abs(Output_signal)./linear_gain_1,'.b');hold on;
    %         plot(abs(Input_signal),abs(Output_no_DPD_estimated),'.r'); grid on;          
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
    rate = mutual_sample_rate*1e6;                                    
    Nfft  = (round(rate/312.5e3));

    res_error_floor = (Output_signal./rms(Output_signal) - Output_no_DPD_estimated./rms(Output_no_DPD_estimated));
    % Spectral Terms 
    % Around frame #1
    [spec_sig_in,          f1] = psd_dBV(linear_gain_1.*Input_signal,Nfft,rate);                spec_sig_in          = spec_sig_in*(1e3/50);
    [spec_sig_out,         f2] = psd_dBV(Output_signal,Nfft,rate);                              spec_sig_out         = spec_sig_out*(1e3/50);
    [spec_sig_out_fitted,  f3] = psd_dBV(linear_gain_1.*Output_no_DPD_estimated,Nfft,rate);     spec_sig_out_fitted  = spec_sig_out_fitted*(1e3/50);
    [spec_res_noise_floor, f4] = psd_dBV(res_error_floor,Nfft,rate);                            spec_res_noise_floor = spec_res_noise_floor*(1e3/50);

    % Temporary workaround  
    spec_res_noise_floor(find( ( f4 > -500e3 ) & (f4 < 500e3) )) = eps; 

    figureno = 100;
    figure(figureno);  
             plot(f1/1e6, dB10(spec_sig_in)  , 'b', 'LineWidth', 2);
    hold on; plot(f2/1e6, dB10(spec_sig_out) , 'm', 'LineWidth', 2);
    grid on; plot(f3/1e6, dB10(spec_sig_out_fitted) , 'r', 'LineWidth', 2);
             plot(f4/1e6, dB10(spec_res_noise_floor) , 'k', 'LineWidth', 2);
    legend('Ideal', 'Measured' , 'Fitted' , 'floor','Location','SouthWest');   title('Frame #1 - PA out');
    axis([ -80 80 -80 20]);     

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

%% DPD fitting  

PA_estimation_output_error = mean(abs(Output_signal-linear_gain_1 .* Output_no_DPD_estimated).^2)/mean((abs(Output_signal)).^2);
PA_estimation_output_errordB=10*log10(PA_estimation_output_error);
fprintf('Out vs. Out after PA est.    err: %3.1f dB\n', PA_estimation_output_errordB);

% Post-distortion
Y_Matrix = Build_Signal_Matrix(Output_signal./linear_gain_1,model,'DPD');
DPD_coef_Inverse_Matrix = Estimate_DPD_coeffs(Y_Matrix,Input_signal);
Input_signal_post_inv = Y_Matrix*DPD_coef_Inverse_Matrix;

% Pre-distortion 
level = -1; % dB
X_Matrix = Build_Signal_Matrix(Input_signal .* (10.^(level./20)),model,'DPD'); %with DPD size k,q
Input_signal_DPD = X_Matrix*DPD_coef_Inverse_Matrix;
Y_Matrix = Build_Signal_Matrix(Input_signal_DPD,model,'PA');
Output_DPD = linear_gain_1 .* Y_Matrix * PA_coef;

if 1 % Plot spectral desity       

    rate = mutual_sample_rate*1e6;                                    
    Nfft  = (round(rate/312.5e3));
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
    figure(figureno);  plot(f1/1e6, dB10(spec_sig_in)               , 'b', 'LineWidth', 2);
    hold on; plot(f2/1e6, dB10(spec_sig_out)              , 'm', 'LineWidth', 2);
    grid on; plot(f3/1e6, dB10(spec_sig_post_inv)         , 'r', 'LineWidth', 2);
             plot(f4/1e6, dB10(spec_res_noise_floor)      , 'k', 'LineWidth', 2);
             plot(f5/1e6, dB10(spec_Output_DPD)      , 'g', 'LineWidth', 2);

    legend('Ideal', 'Output w/o DPD' , ...
                    ['Output w/DPD: k = ' num2str(model.k) ',m = ' num2str(model.q) ], ...
                    'DPD-Floor' , ...
                    'Pre-Distort'         );
    xlim([-mutual_sample_rate  mutual_sample_rate]); ylim([-60 40])
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
%%
set(0,'DefaultFigureWindowStyle', 'Normal');         