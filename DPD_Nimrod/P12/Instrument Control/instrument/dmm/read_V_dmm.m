function [DCVResult]=read_V_dmm(myDmm)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Configure for DCV 100V range, 100uV resolution
fprintf(myDmm,'CONF:VOLT:DC 10,0.001');
fprintf(myDmm,'READ?');
DCVResult = fscanf(myDmm,'%g');
CheckDMMError(myDmm); %Check if the DMM has any errors
end

