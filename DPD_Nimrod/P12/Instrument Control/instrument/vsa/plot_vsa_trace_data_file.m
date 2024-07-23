function plot_vsa_trace_data_file(name, color)
if nargin<2
    color='b';
end
load(name)


figure
subplot(2,1,1)
%subplot(3,1,1)
plot(Data.spect.X/1e9,Data.spect.Y, color)
% Win_length=10000;
% fs=1/( Data.time.X(2)- Data.time.X(1));
% [Psig,Fsig]= pwelch( Data.time.Y, hanning(Win_length),[], Win_length, fs);
% plot(Fsig/1e9,20*log10(Psig), color)
xlabel('freq (GHz)')
ylabel('logMag (dBm)')
axis tight
grid on
ylim([-120 -30])

subplot(2,1,2)
%subplot(3,1,2)
plot(Data.time.X/1e-6, Data.time.Y, color)
iqdata=Data.time.Y;%Data.iq.X+1i.*Data.iq.Y;
PAPR=calc_PAPR(iqdata);
POWER=calc_signal_power_time_domain(iqdata);
txt=['the PAPR is ' num2str(PAPR) ' (dB),    The Power is ' num2str( 10*log10(POWER/1e-3) ) ' (dBm)'];
title(txt)
xlabel('time (usec)')
ylabel('Mag (Vpk)')
grid on
ylim([0 0.2])
% subplot(3,1,3)
% plot(Data.iq.X,Data.iq.Y)
% txt=['the EVM is ' num2str(Data.evm) ' (%)'];
% title(txt)
% xlabel('I')
% ylabel('Q')
% grid on

subplot(2,1,1)
txt=['the EVM is ' num2str(Data.evm) ' (%)'];
title(txt)