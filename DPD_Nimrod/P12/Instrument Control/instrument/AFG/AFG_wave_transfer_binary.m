function AFG_wave_transfer_binary(WRD,awg_ip,nch)
global awg_type
switch(awg_type)
    
    case('tek_afg')
        np=length(WRD);
        np_bytes=2*np;
        
        fprintf(awg_ip,['DATA:POIN EMEM,',int2str(np)]);   % np is limited to 131072 points, see AFG manual p.2-107
        fprintf(awg_ip,['DATA:DEF EMEM,',int2str(np)]);   % reset edit memory data
        np_emem=str2num(query(awg_ip,'DATA:POIN? EMEM'));
        if(np_emem < np)
            disp('Input data array too big,no data transferred to TEK AWG!!!')
            beep
            error(' ')
        end    
        
        WV=word2byte_converter(WRD);
        hdr_str=['DATA:DATA EMEM,  '];
        binblockwrite(awg_ip,WV,'int8',hdr_str)
        str_copy=['TRAC:COPY USER',int2str(nch),',EMEM'];
        fprintf(awg_ip,str_copy);
        str_fnc=['SOURCE',int2str(nch),':FUNCTION USER',int2str(nch)];
        fprintf(awg_ip,str_fnc)
        fprintf(awg_ip,['OUTP',int2str(nch),':STAT ON'])
        disp(['CH',int2str(nch),' waveform transferred to TEK AFG in binary mode'])
    case('tabor')
        % minimal sequence length 640; max=16000000
        fprintf(awg_ip, [':inst ' int2str(nch)]);
        SZ=size(WRD);
        if(SZ(1) > SZ(2))
            WRD=WRD';
        end
        np_seg=32; n_seg_min=20;
        np_wrd=length(WRD);
        n_seg=floor(np_wrd/np_seg);
        if(n_seg < n_seg_min)
            n_rep=ceil(n_seg_min* np_seg/np_wrd);
            WRD=repmat(WRD,1,n_rep);
        end
        np_wrd=length(WRD);
        n_seg=floor(np_wrd/np_seg);
        np=n_seg*np_seg; NN=1:np;
        WRD=WRD(NN);
        % write_bin_block
        binblockwrite(awg_ip,WRD,'int16', ':trace:data')
        fprintf(awg_ip, ':outp on');              % turn output 'ON'
        fprintf(awg_ip, ':outp:sync on');         % turn sync 'ON'
        np=str2num(query(awg_ip,'trac:poin?'));
        if(np_wrd-np > 0)
            beep
            disp(['Original signal truncated to ',int2str(np),' points .Beware discontinuities at AWG output waveform!!!'])
        end
        if(np < 2)
            disp('No data transferred to Tabot AWG!!!')
            beep
            error(' ' )
        end
        disp(['CH',int2str(nch),' waveform transferred to Tabor AFG in binary mode'])
end

return