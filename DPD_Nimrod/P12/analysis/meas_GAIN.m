%here we meas gain
% outputs [gain]
save_to='out_.mat';
%% input 
freq= 5e9;
pin=-20; %dBm
Vdc=5;
%% components losses 
spliter_loss=-3.881241664;
cable_in_loss=-0.552267934;
att_loss=-10.33682925;
cable_out_loss=-0.69860069;
%%
dmm_addr = 'USB0::0x2A8D::0x1601::MY53102271::0::INSTR';
ESG_addr= 'GPIB0::19::INSTR';
scope_addr = {'132.68.61.150','5025'};
%%
Dmm=open_inst_dmm(dmm_addr, 2);
ESG = initiate_ESG(ESG_addr);
scope = initiate_scope(scope_addr);

%%
idn = query(ESG, '*IDN?')
idn = query(Dmm, '*IDN?')
idn = query(scope, '*IDN?')


gain= get_gain( scope,ESG,freq,pin,spliter_loss,cable_in_loss,att_loss,cable_out_loss);
save(save_to,'gain')
%%
close_dmm(dmm_input)
fclose(scope)
fclose(ESG);