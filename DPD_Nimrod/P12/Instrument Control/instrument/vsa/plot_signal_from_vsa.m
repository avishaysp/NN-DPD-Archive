function plot_signal_from_vsa(Y, XDelta)

fs_vsa=1/XDelta;
N_vsa=length(Y);
t_vsa = linspace(0, (N_vsa-1) / fs_vsa, N_vsa);
freq = linspace(fs_vsa / -2, fs_vsa / 2 - fs_vsa / N_vsa, N_vsa);
figure
subplot(211)
plot(t_vsa/1e-6,abs(Y))
PAPR=calc_PAPR(Y);
POWER=calc_signal_power_time_domain(Y);
txt=['the PAPR is ' num2str(PAPR) ' (dB),    The Power is ' num2str( 10*log10(POWER/1e-3) ) ' (dBm)'];
%disp([PAPR 10*log10(POWER/1e-3)]);
title(txt)
xlabel('time (usec)')
ylabel('abs')
axis tight
grid on
subplot(212)
plot(freq/1e9,20 * log10(abs(fftshift(fft(Y/length(Y))))))
xlabel('freq (GHz)')
ylabel('(dB)')
axis tight
grid on