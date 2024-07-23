function [Y,XDelta,Data]=vsa_trace_time()

def = {'132.68.138.194','5026'};
hVSA = open_vsa(def);
% f = tcpip(def{1}, str2double(def{2}));
% 
% f.InputBufferSize = 2000000;
% % Connect the tcpip object to the VSA application
% fopen(f);
% 
% % Determine whether the VSA process is running
% isCreated = false;
% A = query(f, ':SYSTem:VSA:STARt?');
% if (strncmpi(A,'0',1))
%     % VSA process is not running... start it
%     fprintf('Waiting for VSA software to start...');
%     f.timeout = 120; %Give VSA up to 120 seconds to start (typical startup times are much shorter than 2 minutes)
%     query(f, ':SYSTem:VSA:STARt;*OPC?');
%     f.timeout = 10; %Reset the timeout to 10 seconds
%     isCreated = true;
% end
%  isCreated
% % Print the Identification string of the VSA program instance
% idn = query(f, '*IDN?');
% %fprintf (idn);
%%
%opts = query(f, '*opt?')

%fprintf(f, ':DDEMod:COMP:EQU 0')

% fprintf(f, ':INPut:ANALOG:RANGe:AUTO')
 fprintf(hVSA, ':DDEM:FORM:RLEN 4000')
% fprintf(f, ':FREQuency:SPAN 320 MHz'); 
fprintf(hVSA, ':INIT:CONT 1')
pause(5)
fprintf(hVSA, ':INIT:CONT 0')
%%
% %%
% fprintf(f, ':TRAC1:DATA:NAME "IQ Meas Time1"')
% TRAC5_NAME = query(f, ':TRAC1:DATA:NAME?');
% %query(f, ':TRAC1:FORM?')
% fprintf(f, ':TRAC1:FORM "IQ"');
% fprintf(f, ':TRAC1:Y:AUToscale');
% fprintf(f, ':TRAC1:X:AUToscale');
% fprintf(f, ':FORMat:DATA REAL64');
% fprintf(f, ':TRAC1:DATA?')           %  Returns comma separated X,Y data for constellation in Trace A.
% TRAC1_YData =  binblockread(f,'float64');
% fprintf(f, ':TRAC1:DATA:X?');
% TRAC1_XData =  binblockread(f,'float64');
% Data.iq.Y=TRAC1_YData;
% Data.iq.X=TRAC1_XData;
%% Spectrum1
% fprintf(f, ':TRAC2:DATA:NAME "Spectrum1"')
% TRAC2_NAME = query(f, ':TRAC2:DATA:NAME?')           % "IQ Meas1"
% fprintf(f, ':TRACe2:Y:AUToscale');
% fprintf(f, ':FORMat:DATA REAL64');
% fprintf(f, ':TRAC2:DATA?')           %  Returns comma separated X,Y data for constellation in Trace A.
% TRAC2_YData =  binblockread(f,'float64');
% fprintf(f, ':TRAC2:DATA:X?');
% TRAC2_XData =  binblockread(f,'float64');
% Data.spect.Y=TRAC2_YData;
% Data.spect.X=TRAC2_XData;
%% Time1
fprintf(hVSA, ':TRAC3:DATA:NAME "Time1"')
fprintf(hVSA, ':TRAC3:FORM "LinearMagnitude"');
fprintf(hVSA, ':TRAC3:DATA:X?');
TRAC3_XData =  binblockread(hVSA,'float64');
Data.time.X = TRAC3_XData;
fprintf(hVSA, ':TRAC3:FORM "IQ"');
fprintf(hVSA, ':TRAC3:DATA?')
TRAC3_YData =  binblockread(hVSA,'float64');
fprintf(hVSA, ':TRAC3:DATA:X?');
TRAC3_XData =  binblockread(hVSA,'float64');
Data.time.Y=TRAC3_XData + 1i.*TRAC3_YData;
Y=Data.time.Y;
length(Data.time.X)
XDelta=double(Data.time.X(2)-Data.time.X(1));
power_time_domain_W=10*log10(rms(Y)^2/0.1);
XData=Data.time.X(2);

%%  read EVM
% 
% fprintf(f, ':INIT:CONT 1')
% fprintf(f, ':INPut:ANALOG:RANGe:AUTO')
% pause(3)
% fprintf(f, ':TRACe4:DATA:Name "Syms/Errs1"');
% meas_name = query(f, ':TRACe4:DATA:Name?') %"OFDM Error Summary1"
% units = query(f, ':TRACe4:DATA:TABLe:UNIT? 1')
% evm_v=0;
% for iii=1:3
%     evm = query(f, ':TRACe4:DATA:TABLe:VALue? 1');
%     pause(0.5)
%     evm_v(iii)=double(str2num(evm));
% end
% Data.evm=mean(evm_v);
%%

%plot_vsa_trace_data(Data);
% figure
% subplot(3,1,1)
% plot(Data.spect.X,Data.spect.Y)
% xlabel('freq (Hz)')
% ylabel('logMag (dBm)')
% grid on
% 
% subplot(3,1,2)
% plot(Data.time.X, Data.time.Y)
% iqdata=Data.time.Y;%Data.iq.X+1i.*Data.iq.Y;
% PAPR=calc_PAPR(iqdata);
% POWER=calc_signal_power_time_domain(iqdata);
% txt=['the PAPR is ' num2str(PAPR) ' (dB),    The Power is ' num2str( 10*log10(POWER/1e-3) ) ' (dBm)'];
% title(txt)
% xlabel('time (sec)')
% ylabel('Mag (Vpk)')
% grid on
% 
% subplot(3,1,3)
% plot(Data.iq.X,Data.iq.Y)
% txt=['the EVM is ' num2str(Data.evm) ' (%)'];
% title(txt)
% xlabel('I')
% ylabel('Q')
% grid on

%%  END END END END END END END END END END END END END END END 
% if (isCreated)
%     fprintf(hVSA, ':SYSTem:VSA:EXIT');
% end
fprintf(hVSA, ':INIT:CONT 1')
fclose(hVSA);
delete(hVSA);
clear hVSA;
