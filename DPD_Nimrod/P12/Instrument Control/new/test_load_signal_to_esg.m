% LOAD SIGNAL TO THE ESG
clear all
%TCPIP0::WINDOWS-6GC2E4C::5025::SOCKET
%init_ESG_with_ipaddr;

% PAInput_Raw = csvread('C:\Users\nimrodgs\Desktop\Nimrod\P12\MCS7SR20MHz.csv');
%PAInput_Raw = csvread('J:\beneli\P12\signals\Legacy20MHz.csv');
% PAInput_Raw = csvread('J:\beneli\P12\signals\64QAM.csv');
% IQData = PAInput_Raw(:,2) + 1i.*PAInput_Raw(:,1);
%data=load('J:\beneli\P12\signals\qam64_bb.mat');
% data=load('J:\beneli\P12\signals\qam64_eb.mat');
% IQData=data.iqdata; %(data.Y).';
% figure
% plot(abs(IQData))
freq = 5.0e9;
% freq2= 5.5e9;
pin = -5;

ESG_ip_addr = {'132.68.55.60','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
data = load('C:\Users\nimrodg\Documents\MATLAB\AXI\BW20FS640_QPSK_A.mat');
commandCompleted = ESG_load_IQ(ESG, resample(data.Input_signal2,160,640).', 160);
fprintf(ESG,[':freq ' num2str(5.44e9)])
fprintf(ESG,['POWer ',num2str(-10)]);
fclose(ESG)

ESG_ip_addr = {'132.68.55.66','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
data = load('C:\Users\nimrodg\Documents\MATLAB\AXI\BW20FS640_QPSK_B.mat');
commandCompleted = ESG_load_IQ(ESG, resample(data.Input_signal2,60,640).', 60);
fprintf(ESG,[':freq ' num2str(5.56e9)])
fprintf(ESG,['POWer ',num2str(-10)])
fclose(ESG)

% data = load('C:\Users\nimrodgs\Documents\Nimrod\DPD\DPD.mat');
% commandCompleted = ESG_load_IQ(ESG, data.Input_signal_DPD, 40);

% data=load('C:\Users\nimrodgs\Desktop\Nimrod\P12\signals\two_tone.mat');
% commandCompleted=ESG_load_IQ(ESG, data.time_signal, data.fs/1e6);

fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
set_sg_on(ESG)


% ESG2_ip_addr = {'132.68.61.207','5025'};
% ESG2 = initiate_ESG_with_ipaddr(ESG2_ip_addr); %with ip address
% idn = query(ESG2, '*IDN?');
% data=load('C:\Users\nimrodgs\Desktop\Nimrod\P12\signals\two_tone.mat');
% commandCompleted=ESG_load_IQ(ESG2, data.time_signal, data.fs/1e6);
% 
% fprintf(ESG2,':RADio:ARB:HCRest ON');  % Turn on high crest mode.
% fprintf(ESG2,':RADio:ARB ON');         % Turn on arbitraty generator.
% fprintf(ESG2,':OUTPut:MODulation ON'); % Make sure modulation is on.
% set_sg_on(ESG2)

fprintf(ESG,[':freq ' num2str(freq)])
fprintf(ESG,['POWer ',num2str(pin(1))]);
% fprintf(ESG2,[':freq ' num2str(freq2)])
% fprintf(ESG2,['POWer ',num2str(pin(1))]);

fclose(ESG)
% fclose(ESG2)