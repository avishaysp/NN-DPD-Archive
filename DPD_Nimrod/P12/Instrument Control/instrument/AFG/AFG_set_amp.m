 function AFG_set_amp(awg_ip, nch, Ampl)
  global awg_type
  
  switch(awg_type)
      case('tek_afg')
          str=['SOURCE',int2str(nch),':VOLTAGE:AMPLITUDE ',num2str(Ampl)];
          fprintf(awg_ip,str)
      case('tabor')
  end