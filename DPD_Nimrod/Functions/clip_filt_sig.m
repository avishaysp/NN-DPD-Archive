%%% clip and filter simple implementation 

function ax_clip=clip_filt_sig(sig,CF,iter_val,cutoff,R1)

CF_act=CF;
ax_new=resample([zeros(2,1); sig ;zeros(2,1)],R1,1);
[Bt,At]=cheby1(3,0.01,cutoff/R1*2);

while PAPR_calc(ax_new)>CF,
    CF_act=CF_act-0.1;
    ax_new=clip_sig(ax_new,CF_act,iter_val);
    ax_new=filtfilt(Bt,At,ax_new);
end
%ax_clip=resample(ax_new,1,R1);
ax_clip=ax_new;
end