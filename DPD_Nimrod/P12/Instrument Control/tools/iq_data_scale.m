function iqdata=iq_data_scale(iq_data_wrk, normalize)

scale = max(max(abs(real(iq_data_wrk))), max(abs(imag(iq_data_wrk))));
if (scale > 1)
        errordlg('Data must be in the range -1...+1', 'Error');
end
iqdata = iq_data_wrk / scale;

% if (scale > 1)
%     if (normalize)
%         iqdata(:,1) = iq_data_wrk(:,1) / scale;
%     else
%         errordlg('Data must be in the range -1...+1', 'Error');
%     end
% end