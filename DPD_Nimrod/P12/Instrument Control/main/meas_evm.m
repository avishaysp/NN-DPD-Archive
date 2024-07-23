save_to = 'evm_data_nimer_.mat';
%% input
f0  = 5.5e9;
Vdc = 3.3; %5
pin = -20:0.5:0;
load('C:\Users\nimrodg\Documents\MATLAB\AXI\BW20FS640_QPSK_A.mat','Input_signal2');
sig_ref = resample(Input_signal2,40,640);
fs = 40;
%%
ESG_ip_addr = {'132.68.55.36','5025'};
ESG = initiate_ESG_with_ipaddr(ESG_ip_addr);

hVSA_addr =  {'132.68.55.59','5026'};
hVSA=open_vsa(hVSA_addr);
%%
commandCompleted=ESG_load_IQ(ESG, sig_ref.', fs);
fprintf(ESG,':RADio:ARB:HCRest ON'); % Turn on high crest mode.
fprintf(ESG,':RADio:ARB ON'); % Turn on arbitraty generator.
fprintf(ESG,':OUTPut:MODulation ON'); % Make sure modulation is on.
%%
fprintf(ESG,[':freq ' num2str(f0)])
set_sg_on(ESG)

for i=1:length(pin)
    fprintf(ESG, ['POWer ',num2str(pin(i))]);
    commandCompleted = query(ESG,'*OPC?');
    while commandCompleted==0
        commandCompleted = query(scope,'*OPC?');        
    end
    EVM(i) = vsa_read_evm_simple(hVSA);
end

plot(pin,EVM)

save(save_to,'EVM','freq','Idc','pin')
%%
set_sg_off(ESG)
% fclose(Dmm)
fclose(hVSA)
fclose(ESG);