 function AFG_set_phase(awg_ip, nch, ph_deg)
  global awg_type
  
  switch(awg_type)
      case('tek_afg')
           ph_rad=pi*ph_deg/180;
         fprintf(awg_ip,['SOUR' num2str(nch) ':PHAS:ADJ ',num2str(ph_rad)]);
         fprintf(awg_ip,'SOUR:PHAS:INIT');   
      case('tabor')
  end