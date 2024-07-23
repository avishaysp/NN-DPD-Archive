% clear all
clc

f0 = 5.5e9;
f1 = 0e6;
fs = 20e6;
Ns = 13;
t = 0:1/fs:(2^Ns+2)/fs;

I   = cos(2*pi*f1*t);
Q   = sin(2*pi*f1*t);
sig = I+1j*Q;
% sig = padarray(sig,[0,length(t)/2],0,'both');

% t = 0:1/fs:(2^(Ns+1)-1)/fs/20;
plot(t*1e6,real(sig))
f   = linspace(-fs/2,fs/2,length(t));
plot(f,db(abs(fftshift(fft(sig)))))
%%
pin   = 9;

ESG_ip_addr = {'132.68.61.216','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
commandCompleted = ESG_load_IQ(ESG, sig, fs*1e-6);
fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
set_sg_on(ESG)
fprintf(ESG,[':freq ' num2str(f0)]);
fprintf(ESG,['POWer ',num2str(pin(1))]);
fclose(ESG)

ESG_ip_addr = {'132.68.61.212','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
commandCompleted = ESG_load_IQ(ESG,sig,fs*1e-6);
fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
set_sg_on(ESG)
fprintf(ESG,[':freq ' num2str(f0)]);
fprintf(ESG,['POWer ',num2str(pin(1))]);
fclose(ESG)