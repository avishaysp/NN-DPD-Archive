%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open a VISA connection or a raw TCPIP/GPIB connection to the instrument
% ESG = visa('agilent','TCPIP0::A-N5182A-80056.dhcp.mathworks.com::inst0::INSTR');
%ESG = gpib('agilent',8,19);
ESG = tcpip('132.68.61.207',5025);
%ESG = visa('agilent','GPIB0::19::INSTR');
% Set up the output buffer size to hold at least the number of bytes we are
% transferring
ESG.OutputBufferSize = 600000;
% Set output to Big Endian with TCPIP objects, because we do the interleaving 
% and the byte ordering in code. For VISA or GPIB objecs, use littleEndian.
ESG.ByteOrder = 'bigEndian';

% Adjust the timeout to ensure the entire waveform is downloaded before a
% timeout occurs
ESG.Timeout = 10.0;

% Open connection to the instrument
fopen(ESG);
% Some more commands to make sure we don't damage the instrument
query(ESG,'*IDN?')

fprintf(ESG,':OUTPut:STATe OFF')
fprintf(ESG,':SOURce:RADio:ARB:STATe OFF')
fprintf(ESG,':OUTPut:MODulation:STATe OFF')