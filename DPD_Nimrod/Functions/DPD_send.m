estimator = comm.DPDCoefficientEstimator( ...
    'DesiredAmplitudeGaindB',1, ...
    'PolynomialType','Memory polynomial', ...
    'Degree',5,'MemoryDepth',3,'Algorithm','Least squares');

coef = estimator(in.',out.');

dpd = comm.DPD('PolynomialType','Memory polynomial', ...
    'Coefficients',coef);

in_dpd = dpd(iqdata);
in_dpd = in_dpd/rms(in_dpd);
%%
fs=40216003.9*1.28;
f = linspace(-fs/2,fs/2,length(in));


plot(f,db(fftshift(fft([in_dpd in.']))))
%%
in_dpd = Input_signal_DPD;
Fs = 32e6;
ESG_load_IQ(ESG, in_dpd.', Fs*1e-6);
set_sg_marker_Nimrod(ESG,1,'MATLAB_WFM.bin',1,round(length(in_dpd)*0.75/100)*100,1)
%%
set_sg_power(ESG,0)
%%
% 12V, 54mA, -6.5+30.5dBm
% 12V, 57mA, -6.5+30.5dBm
(10^((34.5)/10-3)-10^(15/10-3))/(24.32*0.168)*100
(10^((34.5)/10-3)-10^(15/10-3))/(24.32*0.161)*100