function myDmm=open_inst_dmm(DutAddr, port)
try
    % enter user's instrument connection string
    % DutAddr = 'GPIB0::22''; %String for GPIB
     %DutAddr = 'TCPIP0::169.254.4.61';  %Example string for LAN
    %string DutAddr = 'USB0::0x0957::0x1A07::MY53000101'; %Example string for USB
    %DutAddrr = 'USB0::0x0957::0x1C07::US00000069::0::INSTR';
    %connects with instrument and configures
    
    myDmm = visa('agilent',DutAddr);
    set(myDmm,'EOSMode','read&write');
    set(myDmm,'EOSCharCode','LF') ;
    fopen(myDmm);
    
    % Example to query the instrument.
    fprintf(myDmm, '*IDN?');
    idn = fscanf(myDmm)
catch MExc
    MExc
    delete_all_objs();
end


