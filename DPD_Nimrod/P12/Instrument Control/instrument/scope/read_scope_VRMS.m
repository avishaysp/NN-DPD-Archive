function VRMS=read_scope_VRMS(scope)

fprintf(scope,':MEASure:SOURce CHANnel1');
% commandCompleted = query(scope,'*OPC?');
% while commandCompleted==0
%         commandCompleted = query(scope,'*OPC?');
% end
fprintf(scope,':SYSTem:HEADer OFF');
% commandCompleted = query(scope,'*OPC?');
% while commandCompleted==0
%         commandCompleted = query(scope,'*OPC?');
% end

str=':MEASure:VRMS? CYCLe,AC,CHANnel1';
VRMS=str2num(query(scope,str))




% :MEASure:VRMS [<interval>][,][<source>]
% <interval> ::= {CYCLe | DISPlay | AUTO}
% <source> ::= {CHANnel<n> | FUNCtion | MATH}

% DATA = download_scope_trace(scope);
% VRMS=rms(DATA);