function set_sg_freq(sg_num,freq)
% set_sg_freq.m
%
% PURPOSE: To set frequency for the signal generator.
% PARAMETERS: sg - GPIB instrument object already initialized and open.
%             freq - Center frequency.

% if (nargin~=2)
%     help set_sg_freq
%     error('Wrong input arguments');
% end

%sg=instrfind('Tag',['sg' num2str(sg_num)]);
fprintf(sg_num,[':freq ' num2str(freq)])

% Setup frequency.



