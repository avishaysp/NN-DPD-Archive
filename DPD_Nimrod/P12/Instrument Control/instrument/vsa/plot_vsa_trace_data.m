function plot_vsa_trace_data(Data)

figure
subplot(2,1,1)
%subplot(3,1,1)
plot(Data.spect.X,Data.spect.Y)
xlabel('freq (Hz)')
ylabel('logMag (dBm)')
axis tight
grid on

subplot(2,1,2)
%subplot(3,1,2)
plot(Data.time.X, Data.time.Y)
iqdata=Data.time.Y;%Data.iq.X+1i.*Data.iq.Y;
PAPR=calc_PAPR(iqdata);
POWER=calc_signal_power_time_domain(iqdata);
txt=['the PAPR is ' num2str(PAPR) ' (dB),    The Power is ' num2str( 10*log10(POWER/1e-3) ) ' (dBm)'];
title(txt)
xlabel('time (sec)')
ylabel('Mag (Vpk)')
grid on

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