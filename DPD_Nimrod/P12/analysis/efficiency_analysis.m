function [ eta ] = efficiency_analysis( pin,pout,Idc )
eta=10^(pout/10)/((10^(pin/10))+(Idc*5)); 
figure(1);
plot(pin,eta)
xlabel(' pin [dBm]');
ylabel('\eta');
grid on
end



