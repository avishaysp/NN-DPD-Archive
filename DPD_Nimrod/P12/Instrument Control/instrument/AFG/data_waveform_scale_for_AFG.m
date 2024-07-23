function [I,Q,fc] = data_waveform_scale_for_AFG (I,Q, ts)
nthr=2*8190;

ext=max([abs(min(I)), abs(max(I))]);
fct=0.5*nthr/ext;
I=floor(I*fct);
I=I-min(I);
offset=I(end)-0.5*nthr;
I=I-offset;

Q=floor(Q*fct);
Q=Q-min(Q);
offset=Q(end)-0.5*nthr;
Q=Q-offset;

% np_max=5000;  nz=400; ZR=zeros(1,nz);
% np=length(I);
% np=min(np,np_max);
% NN=1:np;
% WV=[WV(NN),ZR];

np=length(I);
fc=1.e3*1/(ts*np);
disp(['Computed center frequency,fc=',num2str(fc),'[MHz]'])
np_str=int2str(np);
n_chr=length(np_str);
hdr_str=['#',int2str(n_chr),int2str(np)];
T=[0:np-1]*ts*1.e-3;

figure(1)
plot(T,I,'b'),
grid,xlabel('[usec]'),ylabel('[Val]')
title(['AFG Input waveform,ch=1 and 2'],'fontweight','bold')
hold on;grid on;
plot(T,Q,'m')
