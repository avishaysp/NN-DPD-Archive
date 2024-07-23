function scope = initiate_scope(addr)
%% start interface with the scope
%def = {'132.68.61.150','5025'};
%def = {'TCPIP0:','5025'};
scope = tcpip(addr{1}, str2double(addr{2}));
scope.Timeout = 30.0;
scope.InputBufferSize = 2000000;
% Connect the tcpip object to the VSA application
fopen(scope);
idn = query(scope, '*IDN?');
fprintf (idn);

end

