function  sig_sync=signal_sync(sig,ref,fs)

N=length(sig);
t = linspace(0, (N-1) / fs, N);

s1=abs(sig);
s2=abs(ref);
[acor,lag] = xcorr(s2,s1);
[~,I] = max(abs(acor));
lagDiff = lag(I);
timeDiff = lagDiff/(fs);

if abs(timeDiff) > 1e-20
    sig_sync = interp1(t, sig  , t - 0.99995*timeDiff,'spline'); % perform the time delay
else
    sig_sync = sig;
end
disp('perform Time sync - xcorr');
disp(['time_delay   timeDiff   (nSec)' num2str(timeDiff/1e-9) ' (nSec)']);

sig_sync=phase_reduction(sig_sync, ref);