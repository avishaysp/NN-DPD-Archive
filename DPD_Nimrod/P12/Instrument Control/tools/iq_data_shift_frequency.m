function iqdata=iq_data_shift_frequency(iqdata, fs,fc)
%shift frequency

n = length(iqdata);
iqdata = iqdata .* exp(j*2*pi*round(n*fc/fs)/n*(1:n));

% set min/max values
minVal = min(min(real(iqdata)), min(imag(iqdata)));
maxVal = max(max(real(iqdata)), max(imag(iqdata)));

% calculateScaleValues(handles, 'file');
% try
%     minScale = -1;
%     maxScale = 1;
% catch
%     errordlg('Invalid scaling values');
%     minScale = minVal;
%     maxScale = maxVal;
% end
% scale = (maxScale - minScale) / (maxVal - minVal);
% shift = minScale - (minVal * scale);
% if (isreal(iqdata))
%     iqdata = iqdata * scale + shift;
% else
%     iqdata = complex(real(iqdata) * scale + shift, imag(iqdata) * scale + shift);
% end
