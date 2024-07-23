function hVSA=open_vsa(addr)
%% start interface with the scope

hVSA = tcpip(addr{1}, str2double(addr{2}));
hVSA.InputBufferSize = 2000000;
% Connect the tcpip object to the VSA application
fopen(hVSA);

% Determine whether the VSA process is running
isCreated = false;
A = query(hVSA, ':SYSTem:VSA:STARt?');
if (strncmpi(A,'0',1))
    % VSA process is not running... start it
    fprintf('Waiting for VSA software to start...');
    hVSA.timeout = 120; %Give VSA up to 120 seconds to start (typical startup times are much shorter than 2 minutes)
    query(hVSA, ':SYSTem:VSA:STARt;*OPC?');
    hVSA.timeout = 5; %Reset the timeout to 10 seconds
    isCreated = true;
end
isCreated;
% Print the Identification string of the VSA program instance
idn = query(hVSA, '*IDN?');
fprintf (idn);
end
