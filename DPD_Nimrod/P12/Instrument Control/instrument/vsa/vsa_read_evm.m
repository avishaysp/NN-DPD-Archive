function [EVM, Power, PAPR]=vsa_read_evm(hVSA)


%opts = query(hVSA, '*opt?')

fprintf(hVSA, ':INPut:ANALOG:RANGe:AUTO')
pause(2)
%fprintf(hVSA, ':INIT:CONT 1')
%fprintf(hVSA, ':INIT:CONT 0')
%% Time1
fprintf(hVSA, ':TRAC3:DATA:NAME "Time1"')
fprintf(hVSA, ':TRAC3:FORM "LinearMagnitude"');
%TRAC3_NAME = query(hVSA, ':TRAC3:DATA:NAME?') ; 
fprintf(hVSA, ':TRACe3:Y:AUToscale');
pause(1)
fprintf(hVSA, ':FORMat:DATA REAL64');
fprintf(hVSA, ':TRAC3:DATA?')
TRAC3_YData =  binblockread(hVSA,'float64');
fprintf(hVSA, ':TRAC3:DATA:X?');
TRAC3_XData =  binblockread(hVSA,'float64');
Data.time.Y=TRAC3_YData;
Data.time.X=TRAC3_XData;
Power=calc_signal_power_time_domain(TRAC3_YData);
Power=10*log10(Power/1e-3)-3;
PAPR=calc_PAPR(TRAC3_YData);
%%  read EVM

%fprintf(hVSA, ':INIT:CONT 1')
fprintf(hVSA, ':INPut:ANALOG:RANGe:AUTO')
pause(2)
fprintf(hVSA, ':TRACe4:DATA:Name "Syms/Errs1"');
%meas_name = query(hVSA, ':TRACe4:DATA:Name?'); %"OFDM Error Summary1"
fprintf(hVSA, ':FORMat:DATA REAL64');
units = query(hVSA, ':TRACe4:DATA:TABLe:UNIT? 1');
evm_v=0;
for iii=1:3
    evm = query(hVSA, ':TRACe4:DATA:TABLe:VALue? 1');
    evm_v(iii)=double(str2double(evm));
    pause(0.5)
end
Data.evm=mean(evm_v);
EVM=Data.evm;
%fprintf(hVSA, ':INIT:CONT 0')


