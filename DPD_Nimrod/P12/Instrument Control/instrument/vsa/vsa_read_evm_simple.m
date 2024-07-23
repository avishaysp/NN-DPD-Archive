function EVM=vsa_read_evm_simple(hVSA)

%%  read EVM
fprintf(hVSA, ':INIT:CONT 1')
fprintf(hVSA, ':INPut:ANALOG:RANGe:AUTO')
% query(hVSA, ':TRACe4:DATA:Name?')
fprintf(hVSA, ':TRACe4:DATA:Name "OFDM Error Summary1"');
% fprintf(hVSA, ':TRACe4:DATA:Name "Syms/Errs1"');
opts = query(hVSA, '*opt?');
fprintf(hVSA, ':FORMat:DATA REAL64');
units = query(hVSA, ':TRACe4:DATA:TABLe:UNIT? 1');
evm_v=0;

for iii=1:3
    
    evm = str2double(query(hVSA, ':TRACe4:DATA:TABLe:VALue? 1'));
    evm_v(iii)=double(str2double(evm));
    
    pause(1)
    
end

Data.evm = mean(evm_v);
EVM=Data.evm;

end

