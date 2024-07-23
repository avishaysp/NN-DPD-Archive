function GAIN = get_gain( scope,ESG,freq,pin,spliter_loss,cable_in_loss,att_loss,cable_out_loss)

% spliter_loss=-3.881241664;
% cable_in_loss=-0.552267934;
% att_loss=-10.33682925;
% cable_out_loss=-0.69860069;

fprintf(ESG, 'SOURce:FREQuency %d',freq);
fprintf(ESG, 'POWer %d',pin);
 fprintf(scope, ':AUToscale');
pause(4);
str='MEAS:VPP?';
Vpp=str2num(query(scope,str));
pout=10*log10((Vpp^2)/(8*50*(10^(-3)))) ;
GAIN=(pout-att_loss-cable_out_loss)-(pin+cable_in_loss);
end

% all -4.17dB
% cable out -2.1392
% gain 11.912