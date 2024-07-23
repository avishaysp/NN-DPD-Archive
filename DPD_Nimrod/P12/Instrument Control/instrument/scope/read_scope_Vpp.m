function Vpp=read_scope_Vpp(scope)

str='MEAS:VPP? CHAN1';
Vpp=str2num(query(scope,str));