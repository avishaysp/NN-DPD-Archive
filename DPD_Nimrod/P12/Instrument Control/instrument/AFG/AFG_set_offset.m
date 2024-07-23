 function AFG_set_offset(awg_ip,nch,Ampl_offset)
  global awg_type
  
  switch(awg_type)
      case('tek_afg')
          str=['SOURCE',int2str(nch),':VOLTAGE:OFFSET ',num2str(Ampl_offset)];
          fprintf(awg_ip,str)
      case('tabor')
  end
