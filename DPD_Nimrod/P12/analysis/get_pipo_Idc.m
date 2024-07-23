function [pin,pout, Idc] = get_pipo_Idc(scope,ESG,DMM,freq,min_pin,max_pin,pin_step)
pin=min_pin:pin_step:max_pin;

%fprintf(ESG, 'SOURce:FREQuency %d',freq);
fprintf(ESG,[':freq ' num2str(freq)])
%fprintf(ESG, 'POWer %d',pin(1));
fprintf(ESG, ['POWer ',num2str(pin(1))]);

% fprintf(scope, ':AUToscale:VERTical CHAN1');
% commandCompleted=0;
% while commandCompleted==0
%     commandCompleted = query(scope,'*OPC?');
% end

% fprintf(scope, ':AUToscale');
% commandCompleted=0;
% while commandCompleted==0
%     commandCompleted = query(scope,'*OPC?');
% end

% pause(4)
% fprintf(scope, ':AUToscale:VERTical CHAN1');
% commandCompleted = query(scope,'*OPC?');
% while commandCompleted==0
%     commandCompleted = query(scope,'*OPC?');
%     pause(4)
% end
% read_scope_VRMS_new(scope);
VRMS=[];Idc=[];
for iii=1:length(pin)
    pin(iii)
   % fprintf(ESG, 'POWer %d',pin(iii));
    fprintf(ESG, ['POWer ',num2str(pin(iii))]); %upload pin to ESG
    commandCompleted = query(ESG,'*OPC?');
    fprintf(scope, ':AUToscale:VERTical CHAN1'); %auto scale scope  
    commandCompleted = query(scope,'*OPC?');
    while commandCompleted==0
        commandCompleted = query(scope,'*OPC?');
%         pause(4)
    end
    pause(6)
    VRMS(iii) = read_scope_VRMS_new(scope)
%     =[VRMS; vrms_];
%     Idc(iii) =[Idc, abs(read_I_dmm(DMM))];
    Idc(iii) = abs(read_I_dmm(DMM));
end
pout = 10*log10((VRMS.^2)./(50*(10^(-3))));
end








