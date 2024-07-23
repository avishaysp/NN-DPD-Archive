%%
addpath('C:\Users\nimrodg\Documents\MATLAB_Nimrod\Nimrod\P12\instrument\ESG')
try
    fclose(PM)
    % fclose(Dmm)
    fclose(ESG1);  
catch
end

% clear all

Pin  = 15;
f0 = (5:0.05:6)*1e9;
f1 = 0;
N = 5;

PwrAdd = 'USB0::0x2A8D::0x2C18::MY56440007::0::INSTR';
PM     = visa('agilent',PwrAdd);
fopen(PM);

ESG_ip_addr1 = {'132.68.138.203','5025'};
ESG1 = initiate_ESG_with_ipaddr(ESG_ip_addr1);
set_sg_freq(ESG1,f0-f1);
set_sg_power(ESG1,Pin(1));
fprintf(ESG1,':RADio:ARB OFF');
set_sg_on(ESG1)
fprintf(ESG1,[':freq ' num2str(f0-f1)])

% ESG_ip_addr2 = {'132.68.55.41','5025'};
% ESG2 = initiate_ESG_with_ipaddr(ESG_ip_addr2);
% set_sg_freq(ESG2,f0+f1);
% set_sg_power(ESG2,Pin(1));
% fprintf(ESG2,':RADio:ARB OFF'); % Turn off arbitraty generator.
% set_sg_on(ESG2)
% fprintf(ESG2,[':freq ' num2str(f0+f1)])

% dmm_addr    = 'USB0::0x2A8D::0x1601::MY53102271::0::INSTR';
% Dmm = open_inst_dmm(dmm_addr, 2);


clear Pout

for i=1:length(f0)
    
    flag = 0;  
%     pause(0.2)
    fprintf(ESG1, ['Freq ',num2str(f0(i))]);
%     fprintf(ESG2, ['POWer ',num2str(Pin(i))]);
    flag = query(ESG1,'*OPC?');
    while flag==0
        flag = query(ESG1,'*OPC?');
        disp('Nimer')
    end
    
    pause(2)
    figure(4)
    for k = 1:N
        p(k) = str2double(query(PM, 'MEAS?'));
%         pause(0.1)
    end
    Pout(i) = mean(p)
    p = zeros(1,N);
    plot(f0(1:i),Pout)
    grid on
    
%     pause(1)
%     Idc(i)   = abs(read_I_dmm(Dmm));
    
end
fprintf(ESG1, ['POWer ',num2str(-15)]);
% plot(Pin+sma_in,Pout-sma_out)

fclose(PM)
set_sg_off(ESG1)
% set_sg_off(ESG2)
% fclose(Dmm)
fclose(ESG1)
% fclose(ESG2)

% Gain = Pout-Pin;
PAE  = (10.^(Pout/10-3)-0*10.^(Pin_PA(end)/10-3))/((73.5-3)*3.3)*100;

% figure
% plot(Pin,Pout)
% grid minor; xlabel 'Pin [dBm]', ylabel 'Pout [dBm]'
% % figure
% % plot(Pout,PAE)
% % grid minor; xlabel 'Pout[dBm]', ylabel 'PAE [%]'
% figure
% plot(Pout,Gain)
% grid minor; xlabel 'Pout [dBm]', ylabel 'Gain [dB]'
% 
% time = datestr(datetime);
% time(time==':') = '_';
% % csvwrite([time,'_freq_',num2str(freq*1e-9),'cable_out.csv'],[Pin',Pout',Gain',PAE'])
% csvwrite([time,'_freq_',num2str(f0*1e-9),'cable_in.csv'],[Pin',Pout',Gain'])