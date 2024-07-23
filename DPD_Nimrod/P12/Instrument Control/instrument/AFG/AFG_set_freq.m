 function AFG_set_freq(awg_ip,nch,fc)
  global awg_type
  
  switch(awg_type)
      case('tek_afg')
          str=['SOURCE',int2str(nch),':FREQUENCY ',num2str(fc),'M'];
          fprintf(awg_ip,str)
      case('tabor')
  end
  