%%

PwrAdd      = 'USB0::0x2A8D::0x2C18::MY56440007::0::INSTR';
PM  = visa('agilent',PwrAdd);
fopen(PM);
idn = query(PM, '*IDN?');

% str2double(query(PM, 'FETCH?'))
for i=1:10
    p(i) = str2double(query(PM, 'MEAS?'));
    p(i);
end
mean(p)    
fclose(PM);
