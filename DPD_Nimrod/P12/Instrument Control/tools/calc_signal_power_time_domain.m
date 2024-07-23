function power_time_domain_W=calc_signal_power_time_domain(x,t,R)
%this function calc the power of signal in time domain
% x - signal in time domain (can be also IQ signal)
% t - time line
% R - system impedance (ohms)
% power_time_domain_W the result [Watt]
if nargin<3
    R=50;
end

test_flag=0;

if test_flag==1
    R=50;
    fc=10e3;
    dt=1/(105*fc);
    t=(1:1:1000).*dt;
    x=1.*cos(2*pi*fc.*t);
    figure
    plot(t,x)
    pRMS = rms(x)^2/(R);
end

%% calc
%power_time_domain_W = ((norm(x,2)^2)/length(x)) / R ;
if isreal(mean(x))
    power_time_domain_W =(mean(abs(x).^2))/(1*R);
else
    power_time_domain_W =(mean(abs(x).^2))/(2*R);
end

if test_flag==1
    disp( 'for checking:  1Vpeak is 10dBm on 50 Ohm or 10mW');
    %disp( 'for checking:  1.414Vpeak is 13dBm on 50 Ohm or 20mW');
    disp(['the power of the signal is : ' num2str(power_time_domain_W) ' [Watt]']);
end
% dt=t(2)-t(1);
% p=0;
% for iii=1:1:length(x)
%     p=p+(x(iii)).^2.*dt;
% end
% power_x=1./t(end).*p/50;