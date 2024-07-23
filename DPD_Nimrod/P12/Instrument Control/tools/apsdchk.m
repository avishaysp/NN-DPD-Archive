function [msg,x,y,nfft,Fs,window,noverlap,p,dflag] = ...
                               psdchk(P)
%PSDCHK Helper function for PSD, CSD, COHERE, TFE and SPECGRAM.
%   PSDCHK(P) takes the cell array P and uses each cell as 
%   an input argument.  Assumes P has between 1 and 8 elements.
%
%   Author(s): T. Krauss, 10-28-93
%   Copyright (c) 1988-96 by The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 1996/07/25 16:38:13 $
%
%   Changed by Alecsander Eitan (Dec 16, 1999) to enable power measurements
%   measurements and better spectrum dsplay

msg = [];
if (length(P)>1),
    % 0ne signal or 2 present?
    if (all(size(P{1})==size(P{2}))&~isstr(P{2})) | ...
       (length(P{2})>1 & ~isstr(P{2}))
        x = P{1}; y = P{2};
        % shift input variables left by one:
        P(1) = [];
    else 
        onesig = 1;      % only one signal, x, present
        x = P{1}; y = []; 
    end
else  % length(P) == 1
    x = P{1}; y = []; 
end

% now x and y are defined; let's get the rest

if length(P) == 1 
    nfft = min(length(x),256);
    window = hanning(nfft);
    noverlap = 0;
    Fs = 2;
    p = [];
    dflag = 'none';
elseif length(P) == 2
    if isempty(P{2}),   dflag = 'none'; nfft = min(length(x),256); 
    elseif isstr(P{2}), dflag = P{2};       nfft = min(length(x),256); 
    else              dflag = 'none'; nfft = P{2};   end
    Fs = 2;
    window = hanning(nfft);
    noverlap = 0;
    p = [];
elseif length(P) == 3
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    if isempty(P{3}),   dflag = 'none'; Fs = 2;
    elseif isstr(P{3}), dflag = P{3};       Fs = 2;
    else              dflag = 'none'; Fs = P{3}; end
    window = hanning(nfft);
    noverlap = 0;
    p = [];
elseif length(P) == 4
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    if isempty(P{3}), Fs = 2;     else    Fs = P{3}; end
    if isstr(P{4})
        dflag = P{4};
        window = hanning(nfft);
    else
        dflag = 'none';
        window = P{4};
        if length(window) == 1, window = hanning(window); end
        if isempty(window), window = hanning(nfft); end
    end
    noverlap = 0;
    p = [];
elseif length(P) == 5
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    if isempty(P{3}), Fs = 2;     else    Fs = P{3}; end
    window = P{4};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isstr(P{5})
        dflag = P{5};
        noverlap = 0;
    else
        dflag = 'none';
        if isempty(P{5}), noverlap = 0; else noverlap = P{5}; end
    end
    p = [];
elseif length(P) == 6
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    if isempty(P{3}), Fs = 2;     else    Fs = P{3}; end
    window = P{4};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{5}), noverlap = 0; else noverlap = P{5}; end
    if isstr(P{6})
        dflag = P{6};
        p = [];
    else
        dflag = 'none';
        if isempty(P{6}), p = .95;    else    p = P{6}; end
    end
elseif length(P) == 7
    if isempty(P{2}), nfft = min(length(x),256); else nfft=P{2};     end
    if isempty(P{3}), Fs = 2;     else    Fs = P{3}; end
    window = P{4};
    if length(window) == 1, window = hanning(window); end
    if isempty(window), window = hanning(nfft); end
    if isempty(P{5}), noverlap = 0; else noverlap = P{5}; end
    if isempty(P{6}), p = .95;    else    p = P{6}; end
    if isstr(P{7})
        dflag = P{7};
    else
        msg = 'DFLAG parameter must be a string.'; return
    end
end

% NOW do error checking
if (nfft<length(window)), 
    msg = 'Requires window''s length to be no greater than the FFT length.';
end
if (noverlap >= length(window)),
    msg = 'Requires NOVERLAP to be strictly less than the window length.';
end
if (nfft ~= abs(round(nfft)))|(noverlap ~= abs(round(noverlap))),
    msg = 'Requires positive integer values for NFFT and NOVERLAP.';
end
if ~isempty(p),
    if (prod(size(p))>1)|(p(1,1)>1)|(p(1,1)<0),
        msg = 'Requires confidence parameter to be a scalar between 0 and 1.';
    end
end
if min(size(x))~=1,
    msg = 'Requires vector (either row or column) input.';
end
if (min(size(y))~=1)&(~isempty(y)),
    msg = 'Requires vector (either row or column) input.';
end
if (length(x)~=length(y))&(~isempty(y)),
    msg = 'Requires X and Y be the same length.';
end

dflag = lower(dflag);
if strcmp(dflag,'n')|strcmp(dflag,'no')|strcmp(dflag,'non')| ...
   strcmp(dflag,'none')
      dflag = 'none';
elseif strcmp(dflag,'l')|strcmp(dflag,'li')|strcmp(dflag,'lin')| ...
   strcmp(dflag,'line')|strcmp(dflag,'linea')|strcmp(dflag,'linear')
      dflag = 'linear';
elseif strcmp(dflag,'m')|strcmp(dflag,'me')|strcmp(dflag,'mea')| ...
   strcmp(dflag,'mean')
      dflag = 'mean';
else
    msg = 'DFLAG must be ''linear'', ''mean'', or ''none''.';
end
