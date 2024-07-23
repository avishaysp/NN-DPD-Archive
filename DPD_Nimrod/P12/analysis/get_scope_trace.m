function [DATA, time] = get_scope_trace(scope,npoints)
fprintf(scope, ['ACQ:POIN:ANALog ' num2str(npoints)]);
str='ACQ:POIN:ANALog?';
scope_par.np=str2num(query(scope,str));

acq_mode='ASC';
str=['WAV:FORM ',acq_mode];
fprintf(scope,str);
str='WAV:FORM?';
form_q=(query(scope,str));
str=['WAV:DATA? 1,',num2str(scope_par.np)];
DATA=str2num(query(scope,str));

xInc=str2num(query(scope, ':WAV:XINC?'));
xOrg=query(scope, ':WAV:XOR?');

time=xInc*[1:1:scope_par.np];


