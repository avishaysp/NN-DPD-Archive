function [DCIResult]=read_Idmm(myDmm)

%Configure for DCV 100V range, 100uV resolution
fprintf(myDmm,'CONF:VOLT:DC 10,0.001');
fprintf(myDmm,'READ?');
DCVResult = fscanf(myDmm,'%g');
CheckDMMError(myDmm); %Check if the DMM has any errors

%Configure for DCI 10A range, 100uA resolution
fprintf(myDmm,'CONF:CURR:DC');
fprintf(myDmm,'CURR:DC:NPLC 10');
fprintf(myDmm,'READ?');
DCIResult = fscanf(myDmm,'%g');
CheckDMMError(myDmm); %Check if the DMM has any errors

