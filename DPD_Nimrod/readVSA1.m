function [XDelta, Y] = readVSA(fRF)

addpath('F:\DPD\P12\instrument\vsa')
addr = {'10.68.138.2','5026'};
hVSA = open_vsa(addr);
opts = query(hVSA, '*opt?')

% BW = 100;
% fprintf(hVSA, ':INPut:ANALOG:RANGe:AUTO')
fprintf(hVSA, [':FREQuency:CENTer ',num2str(fRF)]);
pause(2)
fprintf(hVSA, ':DDEM:FORM:RLEN 4000');
% fprintf(hVSA, [':FREQuency:SPAN ',num2str(BW),' MHz']); 

% fprintf(hVSA,  ':TRAC1:DATA:NAME "IQ Meas Time1"')
% TRAC5_NAME = query(hVSA,  ':TRAC1:DATA:NAME?');
% %query(hVSA,  ':TRAC1:FORM?')
% fprintf(hVSA,  ':TRAC1:FORM "IQ"');
% fprintf(hVSA,  ':TRAC1:Y:AUToscale');
% fprintf(hVSA,  ':TRAC1:X:AUToscale');
% fprintf(hVSA,  ':FORMat:DATA REAL64');
% fprintf(hVSA,  ':TRAC1:DATA?')           %  Returns comma separated X,Y data for constellation in Trace A.
% TRAC1_YData =  binblockread(hVSA, 'float64');
% fprintf(hVSA,  ':TRAC1:DATA:X?');
% TRAC1_XData =  binblockread(hVSA, 'float64');
% Data.iq.Y=TRAC1_YData;
% Data.iq.X=TRAC1_XData;
% Data.time.Y=TRAC1_XData + 1i.*TRAC1_YData;
% Y = Data.time.Y;
% XData =Data.time.X(2)-Data.time.X(1);
% 
% fprintf(hVSA, ':INIT:CONT 1')
% pause(2)
% fprintf(hVSA, ':INIT:CONT 0')
% 
% fprintf(hVSA, ':TRAC3:DATA:NAME "Raw Main Time1"')
% fprintf(hVSA, ':TRAC3:FORM "LinearMagnitude"');
% TRAC3_NAME = query(hVSA, ':TRAC3:DATA:NAME?')       
% fprintf(hVSA, ':TRAC3:DATA:X?');
% TRAC3_XData =  binblockread(hVSA,'float64');
% Data.time.X=TRAC3_XData;
% 
% fprintf(hVSA, ':INIT:CONT 1')
% pause(2)
% fprintf(hVSA, ':INIT:CONT 0')

fprintf(hVSA, ':TRAC3:FORM "IQ"');
pause(1)
fprintf(hVSA, ':TRACe3:Y:AUToscale');
pause(1)
fprintf(hVSA, ':TRAC3:DATA?');
TRAC3_YData =  binblockread(hVSA,'float64');
fprintf(hVSA, ':TRAC3:DATA:X?');
TRAC3_XData =  binblockread(hVSA,'float64');
Data.time.Y=TRAC3_XData + 1i.*TRAC3_YData;
Y = Data.time.Y;

pause(2)

fprintf(hVSA, ':TRAC3:DATA:NAME "Time1"');
fprintf(hVSA, ':TRAC3:FORM "LinearMagnitude"');
fprintf(hVSA, ':TRAC3:DATA:X?');
fprintf(hVSA, ':FORMat:DATA REAL64');
X =  binblockread(hVSA ,'float64');
XDelta = X(2) - X(1);

% 
% fprintf(hVSA, ':TRAC3:DATA:NAME "Time1"')
% fprintf(hVSA, ':TRAC3:FORM "LinearMagnitude"');
% TRAC3_NAME = query(hVSA, ':TRAC3:DATA:NAME?');           % "IQ Meas1"
% fprintf(hVSA, ':TRACe3:Y:AUToscale');
% % fprintf(hVSA, ':TRACe3:X:AUToscale');
% fprintf(hVSA, ':TRAC3:DATA?')
% Y =  binblockread(hVSA ,'float64');
% fprintf(hVSA, ':TRAC3:DATA:X?');
% X =  binblockread(hVSA ,'float64');
% XDelta = X(2) - X(1);

% plot(X*1e6,abs(Y))
% save('C:\Users\nimrodg\Documents\MATLAB\Nimrod\FD\sic_signal_27_12_18.mat','Y','X');

fprintf(hVSA, ':INIT:CONT 0');
pause(1)
fprintf(hVSA, ':INIT:CONT 1');

fclose(hVSA);


end

