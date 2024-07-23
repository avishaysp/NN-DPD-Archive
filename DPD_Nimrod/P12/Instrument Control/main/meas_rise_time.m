% here we meas. pipo& Idc
% outputs [pin,pout,Idc]
%save_to='time_amp2_antt3dB_3.mat';%'out_cables_.mat';
%save_to='time_amp2_noantt_1.mat';%'out_cables_.mat';
%save_to='time_amp1_antt3dB_3.mat';
%save_to='time_amp1_noantt_1.mat';
save_to='time_amp2_antt10dB_2.mat';

%% input 
freq= 5e9;
pin=0;
Vdc=3.3; %5
text=' the sw freq is 20MHz, defult board setup, Vmain=3.3V Vsec=2p2V,   without antt';

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
set_sg_freq(ESG,freq);
set_sg_power(ESG,pin);
set_sg_on(ESG)

%%
[DATA, time] = get_scope_trace(scope,20000);
figure
plot(time/1e-9,DATA)
save(save_to,'DATA','time','pin','Vdc','freq','text')

%%
fclose(Dmm)
fclose(scope)
set_sg_off(ESG);
fclose(ESG);

