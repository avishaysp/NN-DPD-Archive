Ns = 8192;

fprintf(SA_Rx, ['SWE:POIN ',num2str(Ns)])
query(SA_Rx, 'SENS:SWE:POIN?')
fprintf(SA_Rx, 'FORM:DATA REAL,32')
fprintf(SA_Rx, 'FORM:BORD SWAP')
fprintf(SA_Rx, 'INIT:IMM; *WAI')

fprintf(SA_Rx, 'CALC:MARK:MAX');
str2double(query(SA_Rx,'CALC:MARK:Y?'))
fprintf(SA_Rx, 'CALC:MARK:MODE:DELT');
fprintf(SA_Rx, 'CALC:MARK:X n2.015e9');
fprintf(SA_Rx, 'CALC:MARK:TRCK:STAT OFF')

% tra= str2double(query(SA_Rx,'TRAC:DATA? TRACE1'));

fprintf(SA_Rx,':TRAC? TRACE1');
data = binblockread(SA_Rx,'float32');
fscanf(SA_Rx); %removes the terminator character

span = 100e6;
fmin = f0-span/2;
fmax = f0+span/2;

figure
f = linspace(fmin,fmax,Ns);
h = plot(f*1e-9,data);
grid minor

% #221
fprintf(SA_Rx, 'UNIT:POW DBM')
fprintf(SA_Rx, 'INIT:CONT 1')

x1 = f(find(data==0,1));
x2 = f(data==0); x2 = x2(end);
y1 = data(find(f==x1)-1);
y2 = data(find(f==x2)+1);
m = (y2-y1)/(x2-x1);
n = y1-m*x1;
y = m*f(find(f==x1):find(f==x2))+n;
data1 = data;
data1(find(f==x1):find(f==x2)) = y;
plot(f,data1)
%%
% data_s = smooth(data1,500);
data_fit = 0;
N = 10;
P = polyfit(f1',data_s,N);
data_fit = data_fit+P(end);
plot(polyval(P,f1))