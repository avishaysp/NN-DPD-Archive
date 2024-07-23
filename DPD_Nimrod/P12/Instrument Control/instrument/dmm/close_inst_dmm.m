function close_inst_dmm(deviceObject)

fclose(deviceObject);
delete(deviceObject); 
clear deviceObject