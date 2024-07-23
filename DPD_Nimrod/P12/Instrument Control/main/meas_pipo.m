% here we meas. pipo& Idc
% outputs [pin,pout,Idc]
% save_to='out_cabel_1805.mat';%'out_cables_.mat';
save_to = 'nimer_1PAJacob_23_5_17.mat';%'out_cables_.mat';
%% input 
freq     = 5.5e9;
max_pin  = 15; %dBm
min_pin  = -20;
pin_step = 1;
Vdc      = 3.3;
text=' defult board setup, Vmain=3.3V Vsec=2.2V SW=0V';

%%
%ESG_addr= 'GPIB0::19::INSTR';
ESG_ip_addr = {'132.68.61.207','5025'};
scope_addr =  {'132.68.61.159','5025'};
dmm_addr = 'USB0::0x2A8D::0x1601::MY53102271::0::INSTR';

%'TCPIP0::WINDOWS-6GC2E4C::5025::SOCKET'

%%
% need to open ESG with ip or gpib
%ESG = initiate_ESG(ESG_addr); %with gpib
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr); %with ip address
Dmm = open_inst_dmm(dmm_addr, 2);
scope = initiate_scope(scope_addr);

%%
idn = query(ESG, '*IDN?')
idn = query(Dmm, '*IDN?')
idn = query(scope, '*IDN?')

%% 
set_sg_freq(ESG,freq);
set_sg_power(ESG,min_pin);
fprintf(ESG,':RADio:ARB OFF'); % Turn off arbitraty generator.
set_sg_on(ESG)

%%
[pin,pout,Idc] = get_pipo_Idc(scope,ESG,Dmm,freq,min_pin,max_pin,pin_step);

figure
subplot(211)
plot(pin,pout-pin)
subplot(223)
plot(pin,pout)
subplot(224)
plot(pin,Idc.*Vdc)
save(save_to,'pin','pout','Idc','Vdc','freq','text')

%%
set_sg_off(ESG)
fclose(Dmm)
fclose(scope)
set_sg_off(ESG);
fclose(ESG);