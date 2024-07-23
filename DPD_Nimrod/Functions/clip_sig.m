
function ax_clip=clip_sig(sig,CF,iter_val)

for iter=1:iter_val,
env_sig=abs(sig);
Rms_OFDM=sqrt(mean(env_sig.^2));
Rms_db=20*log10(Rms_OFDM);
CTR_k=Rms_db+CF;
Vclip_k=10^(CTR_k/20);
I=find(env_sig>=Vclip_k); % finds the index
env_sig(I)=Vclip_k; % hard_clip point
ax_clip=env_sig.*exp(j*angle(sig));
sig=ax_clip;
end
