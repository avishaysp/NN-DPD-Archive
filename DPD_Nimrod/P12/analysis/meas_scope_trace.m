%here we download scope trace
% outputs [DATA, time]
save_to='trace.mat';
%% input 
%freq= 5e9;
npoints=1000;
%Vdc=5;
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


[DATA, time] = get_scope_trace(scope,npoints)
save(save_to,'DATA','time')
%%
close_dmm(dmm_input)
fclose(scope)
fclose(ESG);