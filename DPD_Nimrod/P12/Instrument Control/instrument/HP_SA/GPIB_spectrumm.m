% instrhwinfo('visa')
primaryaddress_ANT = 20;
primaryaddress_Rx  = 18;
%obj = gpib('vendor', boardindex, primaryaddress)
% SA = instrfind('ni', 0, 'PrimaryAddress', primaryaddress);

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
% if isempty(SA)
    %OBJ = gpib('VENDOR',BOARDINDEX,PRIMARYADDRESS,'P1',V1,'P2',V2,...)
SA_ANT = gpib('ni', 1, primaryaddress_ANT);%,'InputBufferSize',3000);
SA_Rx  = gpib('ni', 1, primaryaddress_Rx);%,'InputBufferSize',3000);

% else
%     fclose(SA);
%     SA = SA(1);
%  end

% Connect to instrument object, SA.
SA_ANT.InputBufferSize = 50000;
SA_ANT.Timeout = 10;
SA_Rx.InputBufferSize = 50000;
SA_Rx.Timeout = 3;

fopen(SA_ANT);
fopen(SA_Rx);
% get(SA,{'EOSMode','EOIMode'})

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% txt=['Ref. level = ' num2str(Ref_level) ' (dBm), Video BW ='  num2str(VideoBW/1e6) ...
%         ' (MHz), Resulotion BW ='  num2str(ResulotionBW/1e6) ' (MHz)' ];
% freq=CenterFreq+linspace(-SPAN/2,SPAN/2,601);
% %% Communicating with instrument object, SA.
% %fprintf(SA, 'IP;SNGLS;'); %Initialize analyzer.
% 
% fprintf(SA, ['CF ' num2str(CenterFreq)]);
% CF = query(SA, 'CF?');
% fprintf(SA, ['SP ' num2str(SPAN)]);
% SPen = query(SA, 'SP?');
% fprintf(SA, ['RL ' num2str(Ref_level) 'DBM']);  %range.
% 
% fprintf(SA, ['VB ' num2str(VideoBW)]);
% %VideoBW = query(SA, 'VB?')
% fprintf(SA, ['RB ' num2str(ResulotionBW)]);
% %ResulotionBW = query(SA, 'RB?')
% 
% fprintf(SA, 'MKPK HI;');       %Place marker on highest signal
% unists=query(SA, 'AUNITS?;');
% 
% %DATA=query(SA, 'TDF M;TRA?;'); %TDF M (M-format): Return Decimal Numbers in Measurement Units (output only)
% %print(DATA)
% fprintf(SA, 'TS;'); %Measure with trace A
% pause(10)
% DATA=query(SA, 'TDF P;TRA?;'); 
% spectrum_plot = mystr2num(DATA);
% 
% figure
% plot(freq/1e9,spectrum_plot)
% xlabel('freq (GHz)')
% ylabel('(dBm)')
% xlim([freq(1) freq(end)]/1e9)
% ylim([min(spectrum_plot) Ref_level])
% grid on
% title(txt)
% Disconnect from instrument object, SA.
%fclose(SA);

% Clean up all objects.
%delete(SA);

%% %% Writing to Device -  Agilent - Rx
span = 100e6;
f0 = 2.8E9;
RefLev = 20;
scale = 10;
 VidBW = 1E4;
 ResBW = 1E5;
% VidBW = 0.1E3;
% ResBW = 0.1E2;

fprintf(SA_Rx, ['freq:center ', num2str(f0)])
fprintf(SA_Rx, ['SENS:BAND:RES ', num2str(ResBW)])
fprintf(SA_Rx, ['SENS:BAND:VID ', num2str(VidBW)])
fprintf(SA_Rx, ['SENS:FREQ:SPAN ', num2str(span)])
fprintf(SA_Rx, ['DISP:WIND:TRAC:Y:RLEV ', num2str(RefLev)])
fprintf(SA_Rx, ['DISP:WIND:TRAC:Y:SCAL:PDIV ',num2str(scale)])
fprintf(SA_Rx, 'INIT:IMM')
fprintf(SA_Rx, 'CALC:MARK:MAX');
fprintf(SA_Rx, 'CALC:MARK:MAX');
fprintf(SA_Rx, 'CALC:MARK:MAX');

% span = 10E3;
% f0 = 2E9;
% RefLev = 20;
% scale = 10;
% VidBW = 0.3E3;
% ResBW = 0.3E3;
% 
% fprintf(SA_ANT, ['CF', num2str(f0)])
% fprintf(SA_ANT, ['RB', num2str(ResBW)])
% fprintf(SA_ANT, ['VB', num2str(VidBW)])
% fprintf(SA_ANT, ['SP', num2str(span)])
% fprintf(SA_ANT, ['RL', num2str(RefLev)])
% fprintf(SA_ANT, ['LG',num2str(scale)])
% fprintf(SA_ANT, 'INIT:IMM')
% fprintf(SA_ANT, ['MKF ' , num2str(f0+1.1e3)]);

%% Writing to Device - HP - Ant

span = 100e6;
f0 = 2.4343E9;
RefLev = 10;
scale = 10;
VidBW = 1E4;
ResBW = 1E5;

fprintf(SA_ANT, ['CF', num2str(f0)])
fprintf(SA_ANT, ['RB', num2str(ResBW)])
fprintf(SA_ANT, ['VB', num2str(VidBW)])
fprintf(SA_ANT, ['SP', num2str(span)])
fprintf(SA_ANT, ['RL', num2str(RefLev)])
fprintf(SA_ANT, ['LG',num2str(scale)])
fprintf(SA_ANT, 'INIT:IMM')
fprintf(SA_ANT, ['MKF ' , num2str(f0+1.1e3)]);

%% Reading from Device - HP - Ant
fprintf(SA_ANT, ['MKF ' , num2str(2e9)]);
fprintf(SA_ANT, ['MKF ' , num2str(2e9)]);
%%
fprintf(SA_ANT, ['MKF ' , num2str(2e9)]);
fprintf(SA_ANT, 'MKA ' );

temp_Y = str2double(query(SA_ANT, 'MKREAD '));
fprintf(SA_ANT, ['MKF ' , num2str(2e9)]);
temp_Y = str2double(query(SA_ANT, 'MKREAD '));



%% Reading from Device - Agilnt - Rx
Ns = 8192;
fprintf(SA_Rx, ['SWE:POIN ',num2str(Ns)])

%fprintf(SA_Rx, 'CALC:MARK:MAX');
fprintf(SA_Rx, ['CALC:MARK:X ' , num2str(2e9)]);
temp_Y = str2double(query(SA_Rx,'CALC:MARK:Y?'));
fprintf(SA_Rx, ['CALC:MARK:X ' , num2str(2.4e9)]);
temp_Y1 = str2double(query(SA_Rx,'CALC:MARK:Y?'));



%% ---- HERE 
% Ns = 8192;
% 
% fprintf(SA_ANT, ['SWE:POIN ',num2str(Ns)])
% query(SA_ANT, 'SENS:SWE:POIN?')
% fprintf(SA_ANT, 'FORM:DATA REAL,32')
% fprintf(SA_ANT, 'FORM:BORD SWAP')
% fprintf(SA_ANT, 'INIT:IMM; *WAI')
% 
% fprintf(SA_Rx, 'CALC:MARK:MAX');
% str2double(query(SA_Rx,'CALC:MARK:Y?'))
% fprintf(SA_Rx, 'CALC:MARK:MODE:DELT');
% fprintf(SA_Rx, 'CALC:MARK:X n2.015e9');
% fprintf(SA, 'CALC:MARK:TRCK:STAT OFF')
% 
% tra= str2double(query(SA,'TRAC:DATA? TRACE1'));
% 
% fprintf(SA,':TRAC? TRACE1');
% data = binblockread(SA,'float32');
% fscanf(SA); %removes the terminator character
% 
% fmin = f0-span/2;
% fmax = f0+span/2;
% 
% figure
% f = linspace(fmin,fmax,Ns);
% h = plot(f*1e-9,data);
% grid minor
% 
% % #221
% fprintf(SA, 'UNIT:POW DBM')
% fprintf(SA, 'INIT:CONT 1')

%%
save('C:\Users\nimrodg\Documents\MATLAB\Nimrod\TwoPacketCn\18_9_17\20MHzBW_400MHzSpan_C2n.mat','data','f','cal');
%%
f0 = 5.5e9;
pin = -20:9;
ESG_ip_addr = {'132.68.55.36','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr);
set_sg_on(ESG)
fprintf(ESG,[':freq ' num2str(f0)]);

for i=1:length(pin)
    fprintf(ESG,['POWer ',num2str(pin(i))]);
    pause(0.5)
    fprintf(SA, 'CALC:MARK:MAX');
    pout(i) = str2double(query(SA,'CALC:MARK:Y?'))
end
fclose(ESG);

SmaIn = 0.5;
SmaOut = 7.5;
BoardIn = 0.0;
BoradOut = 0.0;

figure(1)
plot(pin-SmaIn-BoardIn,pout+SmaOut+BoradOut,'linewidth',1.5)
xlabel 'Pin [dBm]'; ylabel 'Pout[dBm]'; grid minor
figure(2)
plot(pout+SmaOut+BoradOut,pout+SmaOut+BoradOut-(pin-SmaIn-BoardIn),'linewidth',1.5)
xlabel 'Pout [dBm]'; ylabel 'Gain[dBm]'; grid minor
%%

% /* - Set the analyzer to active delta marker */
% /* CALC:MARK:MODE DELT */
% /* - Set the delta marker to 2 MHZ */
% /* CALC:MARK:X 2E+6 */
% /* - Activate the noise marker function */
% /* CALC:MARK:FUNC NOIS */
% /* - Trigger a sweep and wait for sweep completion */
% /* INIT:IMM;*WAI */
% /* - Query the marker delta amplitude from the analyzer */
% /* CALC:MARK:Y? 

