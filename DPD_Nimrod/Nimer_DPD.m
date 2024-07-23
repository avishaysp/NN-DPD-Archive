load('C:\Users\nimrodg\Google Drive\CommCas\measurements\Nimrod\DPD\DATA\time_pout_9.6dBm.mat');
fs_out = 1/XDelta;
t_out  = XStart:XDelta:(length(Y)-1)*XDelta+XStart;
out = 10.^(Y/20);

load('C:\Users\nimrodg\Google Drive\CommCas\measurements\Nimrod\DPD\DATA\time_pout_-4.67dBm.mat');
fs_in = 1/XDelta;
t_in  = XStart:XDelta:(length(Y)-1)*XDelta+XStart;
in = 10.^(Y/20);

load('C:\Users\nimrodg\Google Drive\CommCas\measurements\Nimrod\DPD\DATA\PA_AM_PM.mat');
AM  = Gain(:,1)+Pin;
PM  = Gain(:,2);
Vin  = 10.^(Pin/20);
Phi  = 0.5*PM;
Vout = 10.^(AM/20).*exp(1j*Phi);

% Inverse PA polynomial fit
n   = 5;
P   = polyfit(Vout,Vin,n);
in1 = 20*log10(filter(P,1,in));
in  = 20*log10(in);
in1(1:900) = 0; in1(9200:end) = 0;
in(1:900)  = 0; in(9200:end) = 0;

plot(abs(in));hold on;plot(abs(in1)-3)
