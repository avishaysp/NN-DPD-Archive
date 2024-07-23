addpath('C:\Users\Nimrod\ESG')
addpath('C:\Users\Nimrod\SA')



N5182B = tcpip('132.68.138.201', 5025);
N5182B.InputBufferSize = 2000000;
N5182B.OutputBufferSize = 200e4;
N5182B.ByteOrder = 'littleEndian';
fopen(N5182B);

addr = {'132.68.138.198', '5025'};
SA   = tcpip(addr{1}, str2double(addr{2}));
SA.InputBufferSize = 2000000;
SA.Timeout = 30;
if not(strcmp(SA.Status,'open'))
    fopen(SA);   
end
%%
clc
addpath(genpath('F:\DPD\P12\instrument\ESG'))
load('BW20FS640_QPSK_A.mat')
IQdata = resample(Input_signal2,80,640);
ESG_load_IQ(N5182B,IQdata,80);
% save('sig.mat','Input_signal2');
% sig_name = 'sig';
% sample_clk = 160;

% ESGdn('sig',160)
% [XDelta, Y] = readVSA1(1e9);
% [status,status_descript]     = agt_waveformload(N5182B,IQdata.',sig_name,sample_clk*1e6,'no_play')
% [status, status_description] = agt_sendcommand(N5182B,'SOURce:FREQuency 2450000000')
% [status, status_description] = agt_sendcommand(N5182B, 'POWer -30');
% [status, status_description] = agt_sendcommand(N5182B, [':RADio:ARB:WAVeform "WFM1:' sig_name '"']);
% [status, status_description] = agt_sendcommand(N5182B,[':RADio:ARB:SCLock:RATE ' num2str(sample_clk*1e6)]);
% [status, status_description] = agt_sendcommand(N5182B,':source:rad:arb:state on');
% [status, status_description] = agt_sendcommand(N5182B,':OUTPut:MODulation ON');
