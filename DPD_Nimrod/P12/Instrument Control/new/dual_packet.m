%%
clear all

% f1      = 10e6;
% f2      = -10e6;
f0      = 5.5e9;
fs      = 160e6;
t = 0:1/fs:(2^15-1)/fs;
% t = linspace(0,(4096*1.75-1)/fs,4096*1.75);

% I   = cos(2*pi*f1*t)+A*cos(2*pi*f2*t+phi);
% Q   = sin(2*pi*f1*t)+A*sin(2*pi*f2*t+phi);
% sig = (I+1j*Q)/max(abs(max(I,Q)));

data = load('C:\Users\nimrodgs\Documents\Nimrod\P12\signals\OFDM_20M_r54_clean_40Ms.mat');
data2 = load('C:\Users\nimrodgs\Documents\Nimrod\For Nimrod\My_Packet.mat');

packet   = resample(data.time_signal,fs,40e6);
packet   = padarray(packet,[0,(length(t)-length(packet))/2],0,'both');

packet2  = 1e3*(data2.packet(:,1)'+1j*data2.packet(:,2)');
packet2  = padarray(packet2,[0,816],0,'both');

packet22 = resample(packet2,fs,40e6);

% packet_cn = resample(packet2,fs,40e6);
% packet_cn = padarray(packet_cn,[0,1700],'circular');



% modsig = zeros(1,length(t));
% modsig((length(modsig)-length(packet))/2+1:end-(length(modsig)-length(packet))/2)=packet;
% sig = sig.*modsig;

f1 = 60e6;
phi = 130/180*pi;
A = 0.1;
% sig = modsig.*(exp(1j*2*pi*f1*t)+1j*0.2*exp(-1j*2*pi*f1*t));
% sig = packet.*(exp(1j*2*pi*f1*t(1:length(packet)))+A*exp(1j*phi)*exp(-1j*2*pi*f1*t(1:length(packet_cn))));
% sig = packet.*(exp(1j*2*pi*f1*t(1:length(packet))))+packet22.*A.*exp(1j*phi).*exp(-1j*2*pi*f1*t(1:length(packet22)));
% sig = packet.*(exp(1j*2*pi*f1*t(1:length(packet))))+packet22.*A.*exp(1j*phi).*exp(-1j*2*pi*f1*t(1:length(packet22)));
sig = fliplr(packet22).*(exp(1j*2*pi*f1*t(1:length(packet))))+packet22.*A.*exp(1j*phi).*exp(-1j*2*pi*f1*t(1:length(packet22)));

%% LOAD SIGNAL TO THE ESG
pin   = 0;
% % load two packets on different CCs
ESG_ip_addr = {'132.68.61.216','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
commandCompleted = ESG_load_IQ(ESG, sig, 160);
% commandCompleted = ESG_load_IQ(ESG, sig, 40/10);
fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
set_sg_on(ESG)
fprintf(ESG,[':freq ' num2str(f0)]);
% fprintf(ESG,[':freq ' num2str(f0+f1/10)]);
fprintf(ESG,['POWer ',num2str(pin(1))]);
fclose(ESG)

% % load one packet
pin   = 0;
ESG_ip_addr = {'132.68.61.212','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
commandCompleted = ESG_load_IQ(ESG,packet2,40/20);
fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
set_sg_on(ESG)
fprintf(ESG,[':freq ' num2str(f0-3e6)]);
fprintf(ESG,['POWer ',num2str(pin(1))]);
fclose(ESG)

%%

packet3 = data.time_signal;
packet3 = [zeros(1,100) packet3(1:2500) zeros(1,100)];

t3 = t(1:length(packet3));
df = 1/t(end);
f  = -1/(2*(t(2)-t(1))):df:1/(2*(t(2)-t(1)));
f3 = f(length(packet)/2-length(packet3)/2) : df :f(length(packet)/2+length(packet3)/2);
plot(f3*1e-6,db(abs(fftshift(fft(packet3)))))
%%
% f1 = 100e6;
% sig1 = packet3.*exp(1j*2*pi*t3*f1);
% sig2 = packet3.*exp(-1j*2*pi*t3*f1);
% plot(f3*1e-6,db(abs(fftshift(fft(sig1)))))

f0    = 5.5e9;
pin   = 0;
ESG_ip_addr = {'132.68.61.216','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
commandCompleted = ESG_load_IQ(ESG, packet3, 40);
fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
set_sg_on(ESG)
fprintf(ESG,[':freq ' num2str(f0)]);
fprintf(ESG,['POWer ',num2str(pin(1))]);
fclose(ESG)

f0    = 5.5e9;
pin   = 0;
ESG_ip_addr = {'132.68.61.212','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
commandCompleted = ESG_load_IQ(ESG, packet3, 40);
fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
set_sg_on(ESG)
fprintf(ESG,[':freq ' num2str(f0)]);
fprintf(ESG,['POWer ',num2str(pin(1))]);
fclose(ESG)
