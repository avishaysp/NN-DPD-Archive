% pipo analysis- pipo, gain, 1dbcp; efficiency

%% inputs 
% inputs must be for same pin values and same length
cable_in_and_out='in&out_cables_.mat';
cable_out='out_cables_.mat';
dut='hmc326m_amp_long_DC_cable_.mat';

%% read data
data_cable_in_and_out=load(cable_in_and_out);
data_cable_out=load(cable_out);
data_dut=load(dut);
data_Idc=data_dut.Idc;

%% calculation
cable_in_and_out_loss=(data_cable_in_and_out.pout)-transpose(data_cable_in_and_out.pin);
 

 cable_out_loss=data_cable_out.pout-transpose(data_cable_out.pin);
 cable_in_loss=(cable_in_and_out_loss)-cable_out_loss;

dut_pout_cal= data_dut.pout -  cable_out_loss;
dut_pin_cal = transpose(data_dut.pin) +  cable_in_loss;
dut_gain=dut_pout_cal - dut_pin_cal;
dut_efficiency=(10.^((dut_pout_cal/10)-3))./((10.^((dut_pin_cal/10)-3))+(transpose(data_Idc)*data_dut.Vdc));
[error, index]=min(abs(dut_pin_cal+dut_gain(1)-1-dut_pout_cal));
dbcp=dut_pout_cal(index);


%% plots

figure(2)
subplot(311)
plot(dut_pin_cal, dut_pout_cal)
grid on; hold on;
xlabel('pin[dBm]');
ylabel('pout[dBm]');
legend(['1dbcp= ', num2str(dbcp)])


subplot(312)
plot(dut_pin_cal, dut_gain)
xlabel('pin[dBm]');
ylabel('gain[dB]');
grid on; hold on;

subplot(313)
plot(dut_pin_cal,dut_efficiency)
xlabel(' pin [dBm]');
ylabel('\eta');
grid on;



