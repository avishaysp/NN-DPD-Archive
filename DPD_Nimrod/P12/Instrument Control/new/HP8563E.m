h  = 'GPIB0::20::INSTR';
hp = visa('agilent',h);
fopen(hp)

fprintf(hp, ['OUTPUT 710;','IP;','SNGLS;']);
fprintf(hp, ['OUTPUT 710;','CF 5.5GHz']);
fprintf(hp, ['OUTPUT 710;','SP 400MHz']);
fprintf(hp, ['OUTPUT 710;','RL 20']);
fprintf(hp, ['OUTPUT 710;','RB 100KHz']);
fprintf(hp, ['OUTPUT 710;','VB 10KHz']);

fprintf(hp, ['OUTPUT 710;','TS;']);
query(hp, ['OUTPUT 710;','TRA']);

fclose(hp)