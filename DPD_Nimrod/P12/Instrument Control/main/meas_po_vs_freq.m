% here we meas. pipo& Idc
% outputs [pin,pout,Idc]
%save_to='out_cabel_1805_freq_3.mat';%'out_cables_.mat';
save_to='avi_amp_cabel_1805_freq_2.mat';%'out_cables_.mat';
%% input 
freq_start= 4.0e9;
freq_stop=  5.5e9;
freq_step = 0.1e9;
freq_v=freq_start:freq_step:freq_stop;
pin=0; %dBm
Vdc=3.3; %5
text='';%' defult board setup, Vmain=3.3V Vsec=2V SW=0V';

%%
%ESG_addr= 'GPIB0::19::INSTR';
ESG_ip_addr = {'132.68.61.211','5025'};
scope_addr =  {'132.68.61.207','5025'};
dmm_addr = 'USB0::0x2A8D::0x1601::MY53102271::0::INSTR';

%'TCPIP0::WINDOWS-6GC2E4C::5025::SOCKET'

%%
% need to open ESG with ip or gpib
%ESG = initiate_ESG(ESG_addr); %with gpib
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
Dmm=open_inst_dmm(dmm_addr, 2);
scope = initiate_scope(scope_addr);

%%
idn = query(ESG, '*IDN?')
idn = query(Dmm, '*IDN?')
idn = query(scope, '*IDN?')

%% 
set_sg_freq(ESG,freq_v(1));
set_sg_power(ESG,pin);
set_sg_on(ESG)

%%
fprintf(scope, ':AUToscale');
commandCompleted=0;
while commandCompleted==0
    commandCompleted = query(scope,'*OPC?');
end
fprintf(scope, ':AUToscale:VERTical CHAN1');
while commandCompleted==0
    commandCompleted = query(scope,'*OPC?');
end
pause(4)


%[pin,pout,Idc] = get_pipo_Idc(scope,ESG,Dmm,freq,min_pin,max_pin,pin_step);


read_scope_VRMS_new(scope);
VRMS=[];Idc=[];VPP=[];
for iii=1:length(freq_v)
   % fprintf(ESG, 'POWer %d',pin(iii));
    set_sg_freq(ESG,freq_v(iii));
    commandCompleted = query(ESG,'*OPC?');
    fprintf(scope, ':AUToscale:VERTical CHAN1');  
    commandCompleted = query(scope,'*OPC?');
    while commandCompleted==0
        commandCompleted = query(scope,'*OPC?');
        pause(4)
    end
    pause(5)
    vrms_=read_scope_VRMS_new(scope);
    vpp_=read_scope_Vpp(scope);
    VPP=[VPP; vpp_];
    VRMS=[VRMS; vrms_];
    Idc =[Idc, abs(read_I_dmm(Dmm))];
end
pout=10*log10((VRMS.^2)/(50*(10^(-3))));
freq=freq_v;

%%
figure
subplot(211)
plot(freq,pout'-pin)
subplot(223)
plot(freq,pout')
subplot(224)
plot(freq,Idc.*Vdc)
save(save_to,'pin','pout','Idc','Vdc','freq','text','VPP')

%%
set_sg_off(ESG)
fclose(Dmm)
fclose(scope)
set_sg_off(ESG);
fclose(ESG);