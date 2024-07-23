%WV1  % row of I data
%WV2  % row of Q data
%np= length(WV1); % np is limited to 131072 points, see AFG manual p.2-107
%ts    % ts in nsec
%ph   % in deg

fc=2e6;
afg_gpib_adress=5;

buf_size=5000000;
awg_ip = gpib('ni', 0, afg_gpib_adress);
set(awg_ip,'InputBufferSize',buf_size);
set(awg_ip,'OutputBufferSize',buf_size);
set(awg_ip,'Timeout',25);
fopen(awg_ip);
idn = query(awg_ip,'*IDN?');
disp(['Instrument IDN=',idn])
FF=findstr(idn,'Tabor');
awg_type='tek_afg';
if(~isempty(FF))awg_type='tabor';end
switch(awg_type)
    case('tek_afg')
        fprintf(awg_ip, '*rst');
        % fprintf(awg_ip,'*RST');
        fprintf(awg_ip,['SOURCE1:FREQUENCY ',num2str(fc),'M'])
        fprintf(awg_ip,['DATA:POIN EMEM,',int2str(np)]);   % np is limited to 131072 points, see AFG manual p.2-107
        fprintf(awg_ip,['DATA:DEF EMEM,',int2str(np)]);   % reset edit memory data
        np_emem=str2num(query(awg_ip,'DATA:POIN? EMEM'));
        if(np_emem < np)
            disp('Input data array too big,no data transferred to TEK AWG!!!')
            beep
            error(' ')
        end
        ph_rad=pi*ph/180;
        fprintf(awg_ip,['SOUR1:PHAS:ADJ ',num2str(ph_rad)]);
        fprintf(awg_ip,'SOUR:PHAS:INIT');
        pause(0.5)
    case('tabor')
        fprintf(awg_ip, '*rst');
        fprintf(awg_ip, ':func:mode user');
        fprintf(awg_ip,':freq:rast:sour INT')
        fprintf(awg_ip,':inst:coup:stat ON')     % CH1 & CH2 coupled to share same clock
        %fprintf(awg_ip, ':freq:rast 40e6');
        fprintf(awg_ip, [':freq:rast ',num2str(1.e9*1/ts)]);   %%%%%%%%%%%% the sampling rate can be changed here
end


fclose(awg_ip)
