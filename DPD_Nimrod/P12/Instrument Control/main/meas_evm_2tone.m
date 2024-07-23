% here we meas. pipo& Idc
% outputs [pin,pout,Idc]
save_to='evm_data_nimer_adfadf.mat';%'out_cables_.mat';
%% input
freq= 5.5e9;
freq2= 5.55e9;
max_pin=0; %dBm
min_pin=-20;
pin_step=0.5;
Vdc=3.3; %5
pin=min_pin:pin_step:max_pin;
data=load('C:\Users\nimrodgs\Desktop\Nimrod\P12\signals\OFDM_20M_r54_clean_40Ms.mat');
fs=40;
%%
%ESG_addr= 'GPIB0::19::INSTR';
ESG_ip_addr  = {'132.68.61.159','5025'};
ESG_ip_addr2 = {'132.68.61.207','5025'};
%'TCPIP0::WINDOWS-6GC2E4C::5025::SOCKET'
hVSA_addr =  {'132.68.61.156','5026'};
dmm_addr = 'USB0::0x2A8D::0x1601::MY53102271::0::INSTR';

%%
% need to open ESG with ip or gpib
% ESG = initiate_ESG(ESG_addr); %with gpib
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
ESG2 = initiate_ESG_with_ipaddr(ESG_ip_addr2); %with ip address
Dmm=open_inst_dmm(dmm_addr, 2);
hVSA=open_vsa(hVSA_addr);
%%
idn = query(ESG, '*IDN?')
idn = query(ESG2, '*IDN?')
idn = query(hVSA, '*IDN?')
idn = query(Dmm, '*IDN?')
%%
commandCompleted=ESG_load_IQ(ESG, data.time_signal, fs);
commandCompleted=ESG_load_IQ(ESG2, data.time_signal, fs);



%set_sg_freq(ESG,freq); % works only with gpib connection


fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
fprintf(ESG2,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG2,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG2,':OUTPut:MODulation ON'); % Make sure modulation is on.

%%
%[EVM, Power, PAPR, Idc] = get_evm(ESG,hVSA,freq,pin,Dmm);

fprintf(ESG,[':freq ' num2str(freq)])
fprintf(ESG, ['POWer ',num2str(pin(1))]);
fprintf(ESG2,[':freq ' num2str(freq2)])
fprintf(ESG2, ['POWer ',num2str(pin(1))]);
pause(2)
set_sg_on(ESG)
set_sg_on(ESG2)

EVM=vsa_read_evm_simple(hVSA);
pause(2)

EVM=[];Idc=[];
for iii=1:length(pin)
    % fprintf(ESG, 'POWer %d',pin(iii));
    fprintf(ESG, ['POWer ',num2str(pin(iii))]);
    commandCompleted = query(ESG,'*OPC?');
    while commandCompleted==0
        commandCompleted = query(scope,'*OPC?');
        pause(1)
    end
    evm=vsa_read_evm_simple(hVSA)
    EVM=[EVM; evm];
    Idc =[Idc, abs(read_I_dmm(Dmm))];
    
end

plot(pin,EVM)

save(save_to,'EVM','freq','Idc','pin')
%%
set_sg_off(ESG)
fclose(Dmm)
fclose(hVSA)
fclose(ESG);