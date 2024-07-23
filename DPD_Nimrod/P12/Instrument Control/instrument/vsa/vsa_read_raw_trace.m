function [Y,XData,Data]=vsa_read_raw_trace(hVSA)

%fprintf(hVSA, ':DDEMod:COMP:EQU 0')
fprintf(hVSA, ':INPut:ANALOG:RANGe:AUTO')
pause(4)
RANGe=query(hVSA,':INPut:ANALog:RANGe:DBM?');
newRANGE = floor(10*(str2num(RANGe)+2))/10;
newRANGE = sqrt(2*50*10^( (newRANGE)/10 -3));
fprintf(hVSA,[':INPut:ANALog:RANGe ' num2str(newRANGE)]);
% fprintf(hVSA, ':DDEM:FORM:RLEN 4000')
% fprintf(hVSA, ':FREQuency:SPAN 320 MHz'); 
%fprintf(hVSA, ':INIT:CONT 1')

%%
%% Spectrum1
fprintf(hVSA, ':TRAC2:DATA:NAME "Spectrum1"')
TRAC2_NAME = query(hVSA, ':TRAC2:DATA:NAME?')           % "IQ Meas1"
fprintf(hVSA, ':TRACe2:Y:AUToscale');
pause(1)
fprintf(hVSA, ':FORMat:DATA REAL64');
fprintf(hVSA, ':TRAC2:DATA?')           %  Returns comma separated X,Y data for constellation in Trace A.
TRAC2_YData =  binblockread(hVSA,'float64');
fprintf(hVSA, ':TRAC2:DATA:X?');
TRAC2_XData =  binblockread(hVSA,'float64');
Data.spect.Y=TRAC2_YData;
Data.spect.X=TRAC2_XData;

%% Search Time1
fprintf(hVSA, ':TRAC3:DATA:NAME "Raw Main Time1"')
fprintf(hVSA, ':TRAC3:FORM "LinearMagnitude"');
TRAC3_NAME = query(hVSA, ':TRAC3:DATA:NAME?')       

fprintf(hVSA, ':TRAC3:DATA:X?');
TRAC3_XData =  binblockread(hVSA,'float64');
Data.time.X=TRAC3_XData;

fprintf(hVSA, ':TRAC3:FORM "IQ"');
fprintf(hVSA, ':TRAC3:DATA?')
TRAC3_YData =  binblockread(hVSA,'float64');
fprintf(hVSA, ':TRAC3:DATA:X?');
TRAC3_XData =  binblockread(hVSA,'float64');

Data.time.Y=TRAC3_XData + 1i.*TRAC3_YData;

Y=Data.time.Y;
length(Data.time.X)
XData=Data.time.X(2)-Data.time.X(1);
%plot_vsa_trace_data(Data);



