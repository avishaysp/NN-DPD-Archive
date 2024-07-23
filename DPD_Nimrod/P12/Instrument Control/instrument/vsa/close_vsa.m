function close_vsa(hVSA)

fclose(hVSA);
delete(hVSA);
clear hVSA;
