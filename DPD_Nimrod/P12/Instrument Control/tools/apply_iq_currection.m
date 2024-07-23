function iq_caled=apply_iq_currection(iqdata, fs, iqdata_cal, freq_cal)
% freq_cal=XStart + [0:1:N-1].*XDelta;
 plot_flag=0;

%%
N=length(iqdata);
t = linspace(0, (N-1) / fs, N);
freq = linspace(fs / -2, fs / 2 - fs / N, N);
S_sig=fftshift(fft(iqdata/length(iqdata)));

if plot_flag==1
    figure(11)
    subplot(211)
    plot(t/1e-6,abs(iqdata))
    xlabel('time (usec)')
    ylabel('abs')
    subplot(212)
    plot(freq/1e9, 20*log10(abs(S_sig)) )
    xlabel('freq (GHz)')
    ylabel('(dB)')
end

%% load the currection waveform
N=length(iqdata_cal);

start_freq_index=find(freq>=freq_cal(1),1,'first');
end_freq_index=find(freq>=freq_cal(end),1,'first');
%[freq(start_freq_index)/1e9 freq(end_freq_index)/1e9 ]
BW_index=start_freq_index:1:end_freq_index;

%%  resemple Y to the currect grid
[p,q] = rat(length(BW_index)/length(freq_cal),1e-15);
iqdata_cal_res = resample(iqdata_cal,p,q).';

iiii=100:1:(length(iqdata_cal_res)-100);
BW_index=BW_index(iiii);
iqdata_cal_res=iqdata_cal_res(iiii);
freq_res=freq(BW_index);

if plot_flag==1
    figure
    subplot(211)
    plot(freq_res/1e9,20*log10(real(iqdata_cal_res)))
    grid on
    xlabel('freq (GHz)')
    ylabel('Magnitude (dB)')
    subplot(212)
    plot(freq_res/1e9,(angle(iqdata_cal_res)*180/pi))
    xlabel('freq (GHz)')
    ylabel('Phase (deg)')
    grid on
end
%% apply the currection
[f_sig, X_sig, S_sig] =calc_spectrum_of_xt(iqdata, fs, 0);
power_=calc_signal_power_time_domain(iqdata);
papr_=calc_PAPR(iqdata);
S_sig=set_signal_peak_power(S_sig,0.01); %set the peak power to 1V
%max(abs(S_sig))
amp_equalization=real(iqdata_cal_res);    %in amp
phase_equalization=angle(iqdata_cal_res); %in rad
ttt=S_sig;
%ttt(BW_index)=S_sig(BW_index).*10.^(-amp_equalization/2.5).*exp(-1i*phase_equalization*1);
%ttt(BW_index)=length(S_sig).*S_sig(BW_index).*10.^(-amp_equalization/20).*exp(-1i*phase_equalization);
ttt(BW_index)=length(S_sig).*S_sig(BW_index).*(1./amp_equalization).*exp(-1i*phase_equalization);
iq_caled=ifft(ifftshift( ttt ));
%[std(iqdata) std(iq_caled)]

 iq_caled=set_signal_peak_power(iq_caled,power_*10.^(papr_/10));
 power_2=calc_signal_power_time_domain(iq_caled);

