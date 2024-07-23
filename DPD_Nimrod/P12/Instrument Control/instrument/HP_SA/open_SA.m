function SA = open_SA(addr)
%% start interface with SG
SA = visa('agilent',addr);
SA.OutputBufferSize = 100000;
SA.ByteOrder = 'bigEndian';
SA.Timeout = 5.0;
SA.InputBufferSize= 100000;
fopen(SA);
idn = query(SA, '*IDN?');
fprintf(idn);
end

