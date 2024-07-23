function [freq, data] = SA_get_TRACE( SA )
% PURPOSE: This file get the trace from SA
% PARAMETERS: SA handel
%% For any questions and feedbacks please turn to me:
% Avi Sayag,   avi_sayag@hotmail.com
% 0505799880
%fprintf(SA, 'INIT:IMM');
fprintf(SA, 'UNIT:POW DBM') ;
% fprintf(SA, 'DISP:WIND:TRAC:Y:SCAL:PDIV 10 dB');
fprintf(SA, 'FORM:DATA REAL,32');
%fprintf(SA, 'FORM:BORD SWAP');

% Get the nr of trace points
% fprintf(SA,':SWE:POIN 8192')
fprintf(SA,':SWE:POIN 65536');
nr_points = str2double(query(SA,':SWE:POIN?'));

% Get the reference level
ref_lev = str2num(query(SA,':DISP:WIND:TRAC:Y:RLEV?'));

% Get the trace data
fprintf(SA, 'INIT:IMM;*WAI');
% wait until it completes

%tra= str2double(query(SA,'TRAC:DATA? TRACE1'));
fprintf(SA,'*IDN?');
gg=scanstr(SA,',');
if strncmp(gg{2},'N9040B',4)
    fprintf(SA,':FORM:DATA REAL,32');
    fprintf(SA,':TRAC? TRACE1');
    data = binblockread(SA,'float32'); % get the trace data
    fscanf(SA); %removes the terminator character
else
    fprintf(SA,':TRAC? TRACE1');
    data = binblockread(SA,'float32'); % get the trace data
    fscanf(SA); %removes the terminator character
end

SPAN = str2num(query(SA,'SENS:FREQ:SPAN?'));
CF = str2num(query(SA,'FREQ:CENTER?'));
freq = CF + SPAN/nr_points.*[1:1:nr_points] - SPAN/2;

% figure;
%plot(1:nr_points,   data);
% plot(freq,   data);
%xlim([1 nr_points]);
% ylim([ref_lev-100 ref_lev]);
% grid on;
% title('Swept SA trace')
% xlabel('Point index')
% ylabel('Amplitude (dBm)')

end
