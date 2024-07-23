function [EVM, Power, PAPR, Idc] = get_evm(ESG,hVSA,freq,pin,DMM)


%fprintf(ESG, 'SOURce:FREQuency %d',freq);
fprintf(ESG,[':freq ' num2str(freq)])
%fprintf(ESG, 'POWer %d',pin(1));
fprintf(ESG, ['POWer ',num2str(pin(1))]);

pause(2)

[EVM, Power, PAPR]=vsa_read_evm(hVSA);
pause(2)

EVM=[];Power=[];PAPR=[];Idc=[];
for iii=1:length(pin)
   % fprintf(ESG, 'POWer %d',pin(iii));
    fprintf(ESG, ['POWer ',num2str(pin(iii))]);
    commandCompleted = query(ESG,'*OPC?');  
    while commandCompleted==0
        commandCompleted = query(scope,'*OPC?');
        pause(4)
    end
    
    pause(5)
    [evm, power, papr]=vsa_read_evm(hVSA);
    EVM=[EVM; evm];
    Power=[Power; power];
    PAPR=[PAPR, papr];
    Idc =[Idc, abs(read_I_dmm(DMM))];
    
end

