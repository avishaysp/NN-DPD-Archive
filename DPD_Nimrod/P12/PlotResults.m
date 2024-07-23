I = load('nimer_PCB1_2ndPAon_23_5_17.mat');
Pout  = I.pout'+5.5+2;
Pin   = I.pin-0.5;
G     = Pout-Pin;
PoutW = 10.^(Pout/10)*1e-3;
PinW  = 10.^(Pin/10)*1e-3;
PAE   = (PoutW-PinW)./((I.Idc-4e-3)*I.Vdc)*100;

plot(Pout,PAE)
% plot(Pout,G)