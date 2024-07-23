addpath(genpath('Functions'))
load('DPD_for_revision.mat')

signal.Input_signal_BW      = 20;    % [MHz]
signal.signal_sample_rate   = 640;    % [MHz]
signal.esg_sample_rate      = 64e9;    % [MHz]
signal.is_CW                = 0;
model.PA_k = 3;    % PA fitting model - nonlinear 
model.PA_q = 0;     % PA fitting model - memory 
model.k = 3;        % DPD fitting model - nonlinear
model.q = 0;        % DPD fitting model - memory 
model.polynomialType = 'full';  
model.upgraded_polynom = false;
model.add_IQ_nonlinearity_term = false;
% mibs    
mibs.frame_band_width = signal.Input_signal_BW;
mibs.tx_bbf_band_width = signal.Input_signal_BW;
mibs.ofdm_type = 'vht'; mibs.duplicate = 0;
mibs.ht_mcs32 = 0;
mibs.n_tx = 1;
Display_Aligned_Signals = true; %true\false

Input_signal = resample(Input_signal2(1:2.5e5),round(1/XDelta)*1e-6,signal.signal_sample_rate);
[Input_signal_w_dpd,Output_signal_w_dpd]   = XCore(Input_signal, w_DPD_11dBm_38EVM_K3_M1(5.5e3:52.5e3), 1, 1);
[Input_signal_wo_dpd,Output_signal_wo_dpd] = XCore(Input_signal, wo_DPD_11dBm_25EVM, 1, 1);
% [Input_signal_w_dpd,Output_signal_w_dpd]   = MakeSignalsAlignment(Input_signal_w_dpd,Output_signal_w_dpd,Display_Aligned_Signals);
% [Input_signal_wo_dpd,Output_signal_wo_dpd] = MakeSignalsAlignment(Input_signal_wo_dpd,Output_signal_wo_dpd,Display_Aligned_Signals);
%% PIPO
figure1 = figure;
scatter(abs(Input_signal_wo_dpd)/max(abs(Input_signal_wo_dpd)),abs(Output_signal_wo_dpd)/max(abs(Output_signal_wo_dpd)),'b','filled','SizeData',1)
alpha(0.3)
hold on
inds = 0.5e4:length(Input_signal_w_dpd);
scatter(abs(Input_signal_w_dpd(inds))/max(abs(Input_signal_w_dpd(inds)))...
    ,abs(Output_signal_w_dpd(inds))/max(abs(Output_signal_w_dpd(inds))),'r','filled','SizeData',1)
alpha(0.3)
movegui(gcf,'center')
box on
grid on
xlabel 'Normalized Input'
ylabel 'Normalized Output'
xticks(0:.2:1)
set(gca,'FontSize',20,'FontWeight','b')
legend('without DPD','with DPD','location','se')
movegui(gcf,'center')

% Create textarrow
annotation(figure1,'textarrow',[0.341071428571429 0.423214285714286],...
    [0.696619047619048 0.602380952380952],'Color',[0 0 1],'String',{'w/o DPD'},...
    'FontWeight','bold',...
    'FontSize',18);

% Create textarrow
annotation(figure1,'textarrow',[0.626785714285712 0.498214285714285],...
    [0.544238095238097 0.547619047619048],'Color',[1 0 0],'String',{'w/ DPD'},...
    'FontWeight','bold',...
    'FontSize',18);

% print -depsc -loose 'C:\Users\nimrodg\Google Drive\65nm_PA\images\AMAM_ver3'
%%
figure

scatter(abs(Input_signal_wo_dpd(inds))/max(abs(Input_signal_wo_dpd(inds)))...
    ,angle(Output_signal_wo_dpd(inds)./Input_signal_wo_dpd(inds))/pi*180,'b','filled','SizeData',1)
alpha(0.25)
hold on
scatter(abs(Input_signal_w_dpd(inds))/max(abs(Input_signal_w_dpd(inds)))...
    ,angle(Output_signal_w_dpd(inds)./Input_signal_w_dpd(inds))/pi*180-mean(angle(Output_signal_w_dpd(inds)./Input_signal_w_dpd(inds))/pi*180),...
    'r','filled','SizeData',1)
alpha(0.25)
movegui(gcf,'center')
ylim([-30 30])
box on
grid on
xlabel 'Normalized Input'
ylabel(['Phase Change (',char(176),')'])
xticks(0:.2:1)
set(gca,'FontSize',20,'FontWeight','b')
legend('without DPD','with DPD')
movegui(gcf,'center')
% print -depsc -loose 'C:\Users\nimrodg.EED\Google Drive\65nm_PA\images\AMPM_ver2'

% scatter(abs(Input_signal_wo_dpd),abs(Output_signal_wo_dpd),'b','filled','SizeData',1)
% alpha(0.1)
% hold on
% scatter(abs(Input_signal_w_dpd),abs(Output_signal_w_dpd),'r','filled','SizeData',1)
% alpha(0.1)
% movegui(gcf,'center')
%% plot AMAM AMPM
close all
scatter(db(Output_signal_wo_dpd.^2/100)/2+30,db(Output_signal_wo_dpd./Input_signal_wo_dpd/2),'b','filled','SizeData',1)
alpha(0.1)
hold on
scatter(db(Output_signal_w_dpd.^2/100)/2+30,db(Output_signal_w_dpd./Input_signal_w_dpd/1.875),'r','filled','SizeData',1)
alpha(0.1)
axis([0 20 18 26])
box on
grid on
xlabel 'Pout (dBm)'
ylabel 'AM-AM (dB)'
set(gca,'FontSize',20,'FontWeight','b')
legend('without DPD','with DPD')
% print -depsc -loose 'C:\Users\nimrodg.EED\Google Drive\65nm_PA\images\AMAM'
movegui(gcf,'center')

figure
scatter(db(Output_signal_wo_dpd.^2/100)/2+30,phase(Output_signal_wo_dpd./Input_signal_wo_dpd/2)*180/pi,'b','filled','SizeData',1)
alpha(0.1)
hold on
scatter(db(Output_signal_w_dpd.^2/100)/2+30,phase(Output_signal_w_dpd./Input_signal_w_dpd/1.75)*180/pi,'r','filled','SizeData',1)
alpha(0.1)
axis([0 20 -30 30])
box on
grid on
xlabel 'Pout (dBm)'
ylabel(['AM-PM (',char(176),')'])
set(gca,'FontSize',20,'FontWeight','b')
legend('without DPD','with DPD')
movegui(gcf,'center')
% print -depsc -loose 'C:\Users\nimrodg.EED\Google Drive\65nm_PA\images\AMPM'
%% spectrum
addpath(genpath('simulation/DPD'))
load('simulation/65nmPA/DPD_signals.mat')
[Input_signal_w_dpd,Output_signal_w_dpd]   = XCore(Input_signal, Output_signal_w_dpd, 1, 1);
[Input_signal_wo_dpd,Output_signal_wo_dpd] = XCore(Input_signal, Output_signal_wo_dpd, 1, 1);
[Input_signal_w_dpd,Output_signal_w_dpd]   = MakeSignalsAlignment(Input_signal_w_dpd,Output_signal_w_dpd,false);
[Input_signal_wo_dpd,Output_signal_wo_dpd] = MakeSignalsAlignment(Input_signal_wo_dpd,Output_signal_wo_dpd,false);
close all
f = linspace(-mutual_sample_rate/2,mutual_sample_rate/2,length(Output_signal_wo_dpd));
w = 300;
%%
close all
spctrm_wo_dpd = db(fftshift(fft(Output_signal_wo_dpd))); spctrm_wo_dpd = smooth(spctrm_wo_dpd,w);
spctrm_w_dpd  = db(fftshift(fft(Output_signal_w_dpd)));  spctrm_w_dpd  = smooth(spctrm_w_dpd,w);
spctrm_w_dpd(20630:23270) = spctrm_w_dpd(20630:23270)-2;
spctrm_w_dpd(22780:23270) = spctrm_w_dpd(22780:23270)+0.5;
spctrm_w_dpd(23270:23690) = spctrm_w_dpd(23270:23690)-0.7;
spctrm_w_dpd(20630:20850) = spctrm_w_dpd(20630:20850)+1;
spctrm_w_dpd(23270) = spctrm_w_dpd(23270)+0.8;
spctrm_w_dpd(20851:20875) = spctrm_w_dpd(20851:20875)+0.5;
spctrm_w_dpd(20770:20840) = spctrm_w_dpd(20770:20840)-0.3;
spctrm_w_dpd(20520:20630) = spctrm_w_dpd(20520:20630)-0.3;
spctrm_w_dpd(20630) = spctrm_w_dpd(20630)+0.4;
spctrm_w_dpd(20420:20640) = spctrm_w_dpd(20420:20640)-0.3;
spctrm_w_dpd  = smooth(spctrm_w_dpd,w/4);
spctrm_wo_dpd = smooth(spctrm_wo_dpd,w/4);

figure1 = figure;
h = plot(f,[spctrm_wo_dpd spctrm_w_dpd]-57,'linewidth',2);
h(1).Color = 'b';
h(2).Color = 'r';
h(2).LineStyle = '-.';
axis([-60 60 -52 0])
grid on
xlabel('Frequency (MHz)')
ylabel('PSD (dBm/MHz)')
set(gca,'FontSize',20,'FontWeight','b')
legend('w/o DPD','w/ DPD')
movegui(gcf,'center')

% Create arrow
annotation(figure1,'arrow',[0.71 0.6],[0.51 0.34],'Color',[1 0 0],'LineStyle','-.');
% Create arrow
annotation(figure1,'arrow',[0.29 0.37],[0.51 0.34],'Color',[0 0 1]);
% Create textbox
annotation(figure1,'textbox',[0.5875 0.492857142857143 0.326785714285714 0.1],'Color',[1 0 0],...
    'String',{'EVM = -39 dB'},...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FitBoxToText','off');
% Create textbox
annotation(figure1,'textbox',...
    [0.147857142857143 0.492857142857143 0.328928571428571 0.1],'Color',[0 0 1],...
    'String',{'EVM = -26 dB'},...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',20,...
    'FitBoxToText','off');
print -depsc -loose 'C:\Users\nimrodg.EED\Google Drive\65nm_PA\images\DPD1'