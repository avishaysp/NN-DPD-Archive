function VRMS=read_scope_VRMS_new(scope)

fprintf(scope,':MEASure:SOURce CHANnel1');
% commandCompleted = query(scope,'*OPC?');
% while commandCompleted==0
%         commandCompleted = query(scope,'*OPC?');
% end
fprintf(scope,':SYSTem:HEADer OFF');
VRMS=':MEASure:VRMS? CYCLe,AC,CHANnel1';
N = 100; %no. of avg point
for i = 1:N
    a(i) = str2num(query(scope,VRMS));
end
VRMS = mean(a);
end




% :MEASure:VRMS [<interval>][,][<source>]
% <interval> ::= {CYCLe | DISPlay | AUTO}
% <source> ::= {CHANnel<n> | FUNCtion | MATH}

% DATA = download_scope_trace(scope);
% VRMS=rms(DATA);