function [DCIResult]=read_I_dmm(myDmm)

%Configure for DCI 10A range, 100uA resolution
fprintf(myDmm,'CONF:CURR:DC');
fprintf(myDmm,'CURR:DC:NPLC 10');
fprintf(myDmm,'READ?');
DCIResult = fscanf(myDmm,'%g');
CheckDMMError(myDmm); %Check if the DMM has any errors

end