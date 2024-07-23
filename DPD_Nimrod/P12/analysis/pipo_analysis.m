function [error, dbcp] = pipo_analysis( pin,pout,GAIN,spliter_loss,cable_in_loss,att_loss,cable_out_loss )
%input- max error allowed to find 1dbcp
%error=0.1; %dB
index=0;

% spliter_loss=-3.881241664;
% cable_in_loss=-0.552267934;
% att_loss=-10.33682925;
% cable_out_loss=-0.69860069;


%output 
dbcp=[];

%GAIN = meas_gain;
pout_theory=(pin+cable_in_loss)+GAIN;
pout=pout-att_loss-cable_out_loss;
figure(1);
plot(pin,pout,'black');
hold all
plot(pin,pout_theory,'b--'); %theoretical gain plot
xlabel(' pin [dBm]');
ylabel('pout[dBm]');
grid on
%find the output 1dbcp
[error, index]=min(abs(pout_theory-1-pout));
dbcp=pout(index);


end

