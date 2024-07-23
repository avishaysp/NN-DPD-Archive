close all

smatot = load('nimer_SmaOutIn_23_5_17.mat');
smatot = smatot.pout'-smatot.pin;
smaOut = load('nimer_SmaOut_23_5_17.mat');
smaOut = smaOut.pout'-smaOut.pin;
smaIn  = smatot-smaOut;

A    = load('nimer_PCB1_2ndPAon_23_5_17.mat');
Idc  = A.Idc;
Vdc  = A.Vdc;
Pout = A.pout'-smaOut+2;
Pin  = A.pin+smaIn;

G   = Pout-Pin;
PAE = (10.^(Pout/10)-10.^(Pin/10))*1e-3./(Vdc.*(Idc-4e-3))*100;

figure
plot(Pout,smooth(G),'linewidth',2)
xlabel 'Pout [dBm]'
ylabel 'Gain [dB]'
grid minor
hold on
plot(poutPS,gainPS)
hold off
figure
plot(Pout,smooth(PAE),'linewidth',2)
xlabel 'Pout [dBm]'
ylabel 'PAE [%]'
grid minor
figure
plot(Pin,smooth(Pout),'linewidth',2)
xlabel 'Pin [dBm]'
ylabel 'Pout [dBm]'
grid minor
hold on
plot(pinPS,poutPS)
xlim([-15 5])
hold off
figure
EVM  = load('evm_data_nimer_.mat');
Pin  = EVM.pin+mean(smaIn);
plot(Pin+G(1:41),smooth(EVM.EVM),'linewidth',2)
xlabel 'Pout [dBm]'
ylabel 'EVM [dB]'
grid minor
