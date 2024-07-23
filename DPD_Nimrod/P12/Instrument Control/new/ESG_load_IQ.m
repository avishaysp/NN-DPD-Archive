function commandCompleted=ESG_load_IQ(esg, IQData, fs_MHz)
%E4430B

%% Define the IQ Signal from components
%PAInput_Raw = csvread('C:\Users\P17spr12\Documents\Waveforms\MCS7SR200MHz.csv');
%IQData = (PAInput_Raw(:,2) + 1i.*PAInput_Raw(:,1)).';

NUMSAMPLES=length(IQData);
% Define a filename for the data in the ARB
ArbFileName = 'MATLAB_WFM.bin';

% Seperate out the real and imaginary data in the IQ Waveform
wave = [real(IQData);imag(IQData)];
wave = wave(:)';    % transpose the waveform

% Scale the waveform
tmp = max(abs([max(wave) min(wave)]));
if (tmp == 0)
    tmp = 1;
end
% ARB binary range is 2's Compliment -32768 to + 32767
% So scale the waveform to +/- 32767 not 32768
scale = 2^15-1;
scale = scale/tmp;
wave = round(wave * scale);
modval = 2^16;
% Get it from double to unsigned int and let the driver take care of Big
% Endian to Little Endian for you  Look at ESG in Workspace.  It is a
% property of the VISA driver.
wave = uint16(mod(modval + wave, modval));

fprintf(esg,':OUTPut:STATe OFF')
fprintf(esg,':SOURce:RADio:ARB:STATe OFF')
fprintf(esg,':OUTPut:MODulation:STATe OFF')
fprintf(esg,[':SOUR:RAD:ARB:SCLock:RATE ' num2str(fs_MHz) 'MHz'])

% % Set the instrument source freq
% fprintf(esg, 'SOURce:FREQuency 1000000000');
% % Set the source power
% fprintf(esg, 'POWer -20');

% Write the data to the instrument
n = size(wave);
sprintf('Starting Download of %d Points\n',n(2)/2)
binblockwrite(esg,wave,'uint16',[':MEM:DATA:UNProtected "WFM1:' ArbFileName '",']);
% Write out the ASCII LF character
fprintf(esg,'');

% Wait for instrument to complete download
% If you see a "Warning: A timeout occurred before the Terminator was reached." 
% warning you will need to adjust the esg.Timeout value until no
% warning results on execution
commandCompleted = query(esg,'*OPC?');

% Some more commands to start playing back the signal on the instrument
fprintf(esg,':SOURce:RADio:ARB:STATe ON')
fprintf(esg,':OUTPut:MODulation:STATe ON')
fprintf(esg,':OUTPut:STATe ON')
fprintf(esg,[':SOURce:RADio:ARB:WAV "ARBI:' ArbFileName '"']);
end