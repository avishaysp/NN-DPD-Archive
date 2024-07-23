% close all
% clear all 
% clc

% inputs for gva-84
cable_in_and_out='2_cables.mat';
cable_out='1_cable.mat';
dut='amp_test_pipo.mat';


% read data
data_cable_in_and_out=load(cable_in_and_out);
%plot(data_cable_in_and_out.pin,data_cable_in_and_out.pout)
data_cable_out=load(cable_out);
%plot(data_cable_out.pin,data_cable_out.pout)
data_dut=load(dut);
%plot(data_cable_dut.pin,data_cable_dut.pout)

pin_for_cal=-20
index=find(data_cable_in_and_out.pin == pin_for_cal);
cable_in_and_out_loss=data_cable_in_and_out.pout(index)-data_cable_in_and_out.pin(index);
index=find(data_cable_out.pin == pin_for_cal);
cable_out_loss=data_cable_out.pout(index)-data_cable_out.pin(index);
cable_in_loss=cable_in_and_out_loss-cable_out_loss;


dut_pout_cal= data_dut.pout -  cable_out_loss;
dut_pin_cal = data_dut.pin +  cable_in_loss;
dut_gain=dut_pout_cal - dut_pin_cal;

figure
subplot(211)
plot(dut_pin_cal, dut_pout_cal)
grid on; hold on;
xlabel('pin')
subplot(212)
plot(dut_pin_cal, dut_gain)
grid on; hold on;

