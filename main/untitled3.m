t = (0:length(iqdata)-1)/fs;
tau = 2e-6;%1/fs*10;
t_new = t+tau;
iqdata_tau = interp1(t,iqdata,t_new);
close all
[a,b]=max(xcorr(iqdata,iqdata_tau));
plot(abs(xcorr(iqdata,iqdata_tau)))
%%
close all
ind = b-length(iqdata);
plot(abs(iqdata_tau(1:end-ind)))
hold on
plot(abs(iqdata(ind+1:end)))
