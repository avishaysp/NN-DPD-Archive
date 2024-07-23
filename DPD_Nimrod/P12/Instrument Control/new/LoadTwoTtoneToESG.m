%%
clear all

f0      = 5.5e9;              % center frequency
spacing = 20e6;               % frequency spacing
f1      = 10e6;
f2      = -10e6;
% OS      = 160/(spacing*1e-6); % over sampling factor
% fs      = spacing*OS;         % sampling frequency
fs      = 160e6;
% t       = linspace(0,1/fs,2^13*f2/fs);
t = 0:1/fs:(2^13-1)/fs;
% df      = 1/t(end)/1024*80;
% f       = f0-80e6:df:f0+80e6;

phi = 140/180*pi;
A = 0.17*0;
I   = cos(2*pi*f1*t)+A*cos(2*pi*f2*t+phi);
Q   = sin(2*pi*f1*t)+A*sin(2*pi*f2*t+phi);
sig = (I+1j*Q)/max(abs(max(I,Q)));

% stem(f,abs(fftshift(fft(cos(2*pi*f1*t)))))
% plot(t,cos(2*pi*f1*t))
% stem(f_vec*1e-9,abs(fft(sig)))

%% LOAD SIGNAL TO THE ESG
pin   = 5;

ESG_ip_addr = {'132.68.61.159','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
% data = load('C:\Users\nimrodgs\Documents\Nimrod\P12\signals\two_tone.mat');
% commandCompleted = ESG_load_IQ(ESG, data.time_signal, data.fs*1e-6);
commandCompleted = ESG_load_IQ(ESG, sig, fs*1e-6);
idn = query(ESG, '*IDN?');

fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
set_sg_on(ESG)

fprintf(ESG,[':freq ' num2str(f0)]);
fprintf(ESG,['POWer ',num2str(pin(1))]);

fclose(ESG)