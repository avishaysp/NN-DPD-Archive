
%%% simple calculation of PAPR - peak to average ratio

function PAPR_res=PAPR_calc(sig)
env_sig=abs(sig);
Rms_sig=sqrt(mean(env_sig.^2));
PAPR_res=20*log10(max(abs(sig))/Rms_sig);
end