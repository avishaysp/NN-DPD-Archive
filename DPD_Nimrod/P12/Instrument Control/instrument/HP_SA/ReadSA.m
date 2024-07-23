addpath('C:\Users\nimrodg\Documents\MATLAB_Nimrod\Nimrod\P12\instrument\HP_SA',path)
addr =  {'192.168.137.216','5025'};
SA = tcpip(addr{1}, str2double(addr{2}));
SA.InputBufferSize = 2000000;
SA.Timeout = 10;
fopen(SA);

%%
[freq, data] = SA_get_TRACE(SA);
d_SA = datestr(datetime); d_SA(d_SA==':') = '_';  
FileName1 = ['w_Cn_160MHz_',d_SA];
save(['C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\2D DPD\2D-DPD-NG -Code-share\TraceRead\',FileName1,'.mat'],'data','freq')
%%
[freq, data] = SA_get_TRACE(SA);
FileName2 = ['wo_Cn_160MHz_',d_SA];
save(['C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\2D DPD\2D-DPD-NG -Code-share\TraceRead\',FileName2,'.mat'],'data','freq')
%%
% [freq, data] = SA_get_TRACE(SA);
% FileName3 = ['wo_Cn_wo_DPD_200MHz_',d_SA];
% save(['C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\2D DPD\2D-DPD-NG -Code-share\TraceRead\',FileName3,'.mat'],'data','freq')
%%
load(['C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\2D DPD\2D-DPD-NG -Code-share\TraceRead\',FileName1,'.mat'],'data','freq');
WithCn = data;
% load(['C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\2D DPD\2D-DPD-NG -Code-share\TraceRead\',FileName2,'.mat'],'data','freq');
% OneSide = data;
load(['C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\2D DPD\2D-DPD-NG -Code-share\TraceRead\',FileName2,'.mat'],'data','freq');
WithOutCn = data;
%%
set(0,'DefaultFigureWindowStyle', 'Normal');
% WithCn(2870:2985) = WithCn(2870:2985)+1.7;
% plot(freq*1e-9,WithOutCn,freq*1e-9,WithCn,freq*1e-9,WithCn_lopp)
h = plot(freq*1e-9,(WithOutCn),freq*1e-9,(WithCn));
h(1).LineWidth = 1;
h(2).LineWidth = 1;
grid minor
xlabel 'frequency [GHz]'
ylabel 'Output Power [dB]'

% legend('w/o Cn w 2D-DPD','w Cn w 2D-DPD')
% set(gca,'XTick',4.5:0.4:6.5)
% xlim([4.5 6.5])
% set(gca,'FontSize',14)
% set(gca,'FontName','Times')
% 
% title '160MHz OFDM Signals, \Deltaf = 400MHz'
% hold on
% h1 = plot(freq*1e-9,-55*ones(size(freq)),'--');
% h1.Color = h(2).Color;
% h2 = plot(freq*1e-9,-45*ones(size(freq)),'--');
% h2.Color = h(1).Color;
% hold off

% title '20MHz OFDM Signals, \Deltaf = 400MHz'
% hold on
% h1 = plot(freq*1e-9,-53*ones(size(freq)),'--');
% h1.Color = h(2).Color;
% h2 = plot(freq*1e-9,-41*ones(size(freq)),'--');
% h2.Color = h(1).Color;
% hold off
% 
% load(['C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\2D DPD\2D-DPD-NG -Code-share\TraceRead\NoCnNoDPD',num2str(ind),'.mat'],'data','freq');
% hold on
% plot(freq*1e-9,data,'linewidth',1)
% load(['C:\Users\nimrodg\Documents\MATLAB\Nimrod\DPD\2D DPD\2D-DPD-NG -Code-share\TraceRead\CnNoDPD',num2str(ind),'.mat'],'data','freq');
% plot(freq*1e-9,data,'linewidth',1)
% legend('w/o Cn w 2D-DPD','w Cn w 2D-DPD','w/o Cn w/o 2D-DPD','w Cn w/o 2D-DPD')
% 
% set(gca,'FontName','Times')
% [freq, data] = SA_get_TRACE(SA);
% plot(freq*1e-9,data,'linewidth',1)
% hold off

%%
fclose(SA)