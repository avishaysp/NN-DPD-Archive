function [ Input_signal_aligned,Output_signal_aligned ] = MakeSignalsAlignment_FD(Input_signal,Output_signal,Display_Aligned_Signals,signal,add_meas_noise)
    %% Remove DC from signals
    Input_signal = Input_signal - mean( Input_signal );
    Output_signal   = Output_signal   - mean( Output_signal );
    InputRMS = rms(Input_signal);
    OutputRMS = rms(Output_signal);

    %% Make output signal start form a space between frams
    if add_meas_noise
        Zeros_RISE_THRESHOLD=1.5; %need higher TH to detect silence
    else
        Zeros_RISE_THRESHOLD=0.1;
    end
    if signal.Input_signal_BW==20
        SIFS_Samples = 100;%20M % 200
        search_Block_Size = floor((SIFS_Samples/5));
    end
%     SIFS_Samples = 5000;%40M
%     search_Block_Size = floor((SIFS_Samples/3));
    if signal.Input_signal_BW==80
        SIFS_Samples = 1.2e5;%80M
        search_Block_Size = floor((SIFS_Samples/20));
    end
    if signal.Input_signal_BW==160
        SIFS_Samples = 1.92e4;%160M
        search_Block_Size = floor((SIFS_Samples/20));
    end
    space_Between_frams_index=0;
    %create index vector with true values were we are small than threshold
    index = abs(Output_signal)<OutputRMS*Zeros_RISE_THRESHOLD;
    for i=1:1:length(Output_signal)
        % check if we have a whole search block in "index" vector with true values
        if (true(search_Block_Size,1)&index(i:i+search_Block_Size-1))==ones(search_Block_Size,1)
           space_Between_frams_index=i;
           break;
        end
    end
    Output_signal   = Output_signal( space_Between_frams_index : end );
    % Remark - Output_signal is w/o the first cut frame
    
    %% Cut zeros from the start
    iterations_to_seek = 1.2e5;
    starting_input_zero_samples = 400;
    % cut input signal
    for k=1:10:iterations_to_seek,
        refTrailRms = rms( Input_signal(k:k+starting_input_zero_samples-1) );
        if (refTrailRms  > InputRMS * Zeros_RISE_THRESHOLD)
            break;
        end;
    end;
    if( k == iterations_to_seek )
        %display('gaurd interval too long for input');
    else
        Input_signal = Input_signal(k+starting_input_zero_samples:end); 
    end;

    % cut output signal
    for k=1:15:iterations_to_seek,
        refTrailRms = rms( Output_signal(k:k+starting_input_zero_samples-1) );
        if (refTrailRms  > OutputRMS * Zeros_RISE_THRESHOLD)
            break;
        end;
    end;
    if( k == iterations_to_seek )
        %display('gaurd interval too long for output');
    else
        Output_signal = Output_signal(k+starting_input_zero_samples:end); 
    end;

    % Remark - Removed zeros before 
    
    %% search for end of packet at the input signal
    %create index vector with true values were we are small than threshold
    if signal.Input_signal_BW==160
        silence_at_frame_end_samples = 10; %24300 %1.25e5
    end
    if signal.Input_signal_BW==80
        silence_at_frame_end_samples = 1.25e5; %24300 %1.25e5
    end
    if signal.Input_signal_BW==40
        silence_at_frame_end_samples = 21.5e3; %24300 %1.25e5
    end
    if signal.Input_signal_BW==20
        silence_at_frame_end_samples = 1.2e4; %24300 %1.25e5
    end
    space_Between_frams_index=0;
    block_size = floor(silence_at_frame_end_samples/4);
    index = abs(Input_signal)<InputRMS*Zeros_RISE_THRESHOLD;
    space_Between_frams_index = length(Input_signal);
    for i=1:1000:length(Input_signal)
        % check if we have a whole search block in "index" vector with true values
        if (true(block_size,1)&index(i:i+block_size-1)) == ones(block_size,1)
           space_Between_frams_index=i;
           break;
        end
    end
    Input_signal   = Input_signal( 1 : space_Between_frams_index );

    %% cut signals to needed length
    Input_signal = Input_signal( 1 :  min(length(Input_signal),length(Output_signal))  );
    Output_signal   = Output_signal( 1 :  min(length(Input_signal),length(Output_signal))  );

    % Rectangular to Polar conversion
    [ InputSignalPhase , InputSignalAmp ] = ...
        cart2pol( real( Input_signal ) , imag( Input_signal ) );

    [ OutputSignalPhase , OutputSignalAmp ] = ...
        cart2pol( real( Output_signal ) , imag( Output_signal ) );

    %% Frequency error and phase correction
    PSP_WRAP_THRESHOLD      = 1.1*3.1416;
    PSP_WRAP_SMOOTH_LENGTH  = 10;

    SignalsPhaseDelta=zeros(1,length( OutputSignalPhase ) );

    % get a vector with the difference in phase between input and output from 0-2*pi. Takes 0.5 Sec
    for k=1:length( OutputSignalPhase )
        SignalsPhaseDelta(k) =  phase_wrap( OutputSignalPhase( k ) , InputSignalPhase( k ) );
    end

    %initialize first values to psp_avg
    SignalsPhaseDelta(1:PSP_WRAP_SMOOTH_LENGTH)=SignalsPhaseDelta(PSP_WRAP_SMOOTH_LENGTH+1);
    psp_avg = SignalsPhaseDelta(PSP_WRAP_SMOOTH_LENGTH)*PSP_WRAP_SMOOTH_LENGTH;

    % reduce 2*pi from high positive values of delta phase, add 2*pi to
    % low negative values of delta phase
    for k=PSP_WRAP_SMOOTH_LENGTH+1:length(SignalsPhaseDelta),
        if (SignalsPhaseDelta(k) - psp_avg/PSP_WRAP_SMOOTH_LENGTH > PSP_WRAP_THRESHOLD)
            SignalsPhaseDelta(k)=SignalsPhaseDelta(k)-2*pi;
        elseif (SignalsPhaseDelta(k) - psp_avg/PSP_WRAP_SMOOTH_LENGTH < -PSP_WRAP_THRESHOLD)
            SignalsPhaseDelta(k)=SignalsPhaseDelta(k)+2*pi;
        end
        % this is a running block on the average values
        psp_avg = psp_avg + SignalsPhaseDelta(k) - SignalsPhaseDelta(k-PSP_WRAP_SMOOTH_LENGTH);
    end
    %plot(SignalsPhaseDelta); 
    %---------[ Frequnecy error removal ]-----------
    [a_lin, b_lin] = dlinreg1(1:length(SignalsPhaseDelta), SignalsPhaseDelta);
    OutputSignalPhase = OutputSignalPhase - ([1:length(OutputSignalPhase)]' .* a_lin + b_lin);
     display(['frequency error correction: ' num2str(640e6*a_lin/(2*pi)) ' Hz']);

    %% Polar to Rectangular conversion
    [input_real,input_imag]= pol2cart(InputSignalPhase,InputSignalAmp);
    [output_real,output_imag]= pol2cart(OutputSignalPhase,OutputSignalAmp);
    Input_signal = input_real + 1i*input_imag;
    Output_signal = output_real + 1i*output_imag;
    
    %% LO filtering - multiply by sinc in frequency domain
    LOFILT_SAMPLES_LEFT = 256;
    LOFILT_SAMPLES_RIGHT = 256;

    L = LOFILT_SAMPLES_LEFT+LOFILT_SAMPLES_RIGHT+1;
    N = length(Input_signal);
    rollingSum = zeros(N,1);
    rollingSum(1:(LOFILT_SAMPLES_LEFT+1)) = sum(Input_signal(1:(LOFILT_SAMPLES_LEFT+LOFILT_SAMPLES_RIGHT+1)));
    for k = (LOFILT_SAMPLES_LEFT+2):(N-LOFILT_SAMPLES_RIGHT)
        rollingSum(k) = rollingSum(k-1)-Input_signal(k-LOFILT_SAMPLES_LEFT-1)+Input_signal(k+LOFILT_SAMPLES_RIGHT);
    end
    if (LOFILT_SAMPLES_RIGHT>0)
        rollingSum((N-LOFILT_SAMPLES_RIGHT+1):end) = rollingSum(N-LOFILT_SAMPLES_RIGHT);
    end
%     Input_signal = Input_signal - rollingSum/L; %create HPF by reducing a LPF from the signal in time domain

    N = length(Output_signal);
    rollingSum = zeros(N,1);
    rollingSum(1:(LOFILT_SAMPLES_LEFT+1)) = sum(Output_signal(1:(LOFILT_SAMPLES_LEFT+LOFILT_SAMPLES_RIGHT+1)));
    for k = (LOFILT_SAMPLES_LEFT+2):(N-LOFILT_SAMPLES_RIGHT)
        rollingSum(k) = rollingSum(k-1)-Output_signal(k-LOFILT_SAMPLES_LEFT-1)+Output_signal(k+LOFILT_SAMPLES_RIGHT);
    end
    if (LOFILT_SAMPLES_RIGHT>0)
        rollingSum((N-LOFILT_SAMPLES_RIGHT+1):end) = rollingSum(N-LOFILT_SAMPLES_RIGHT);
    end
%     Output_signal = Output_signal - rollingSum/L;
    
    %% Coarse Synchronization
    CSYNC_CORR_OFFSET       = round(length(Input_signal)/2);    %4*2048; %4096
    CSYNC_CORR_FORK_LENGTH  = 1024;
    CSYNC_CORR_FORK_SPACE   = 1;
    CSYNC_CORR_RANGE        = 1024;

    fork     = (0:CSYNC_CORR_FORK_SPACE:(CSYNC_CORR_FORK_LENGTH-1)*CSYNC_CORR_FORK_SPACE);
    serA     = Input_signal( CSYNC_CORR_OFFSET + fork );
    xCorrVec = zeros( 2*CSYNC_CORR_RANGE+1 ,1);

    for k = ( -CSYNC_CORR_RANGE:CSYNC_CORR_RANGE ),
        serB = Output_signal(CSYNC_CORR_OFFSET + fork + k);
        xCorrVec( CSYNC_CORR_RANGE + k + 1 ) = serA'*(serB.*bartlett(length(serB)));
    end;

    [ ~, maxCorrIndex ] = max( abs( xCorrVec ) );

    delay = (maxCorrIndex - CSYNC_CORR_RANGE - 1);

    if ( delay > 0 ),
        Input_signal = Input_signal( 1 : end - delay );
        Output_signal = Output_signal( 1 + delay : end );
    end;

    if ( delay < 0 )
        Input_signal = Input_signal( 1 - delay : end  );
        Output_signal = Output_signal( 1  : end + delay );
    end;

    %% Fine synchronization - interpolation and cross - correlation
    FSYNC_INTERP_FACTOR     = 16;
    FSYNC_CORR_OFFSET       = round(length(Input_signal)/2);   %4*2048; %4096
    FSYNC_CORR_RANGE_SAMPLES= 1;
    FSYNC_CORR_FORK_LENGTH  = 512;
    FSYNC_CORR_FORK_SPACE   = 1;
    FSYNC_MAX_ALLOWED_DELAY = 2*FSYNC_INTERP_FACTOR-1;

    IDX1 = FSYNC_CORR_OFFSET - FSYNC_CORR_RANGE_SAMPLES;
    IDX2 = FSYNC_CORR_OFFSET + FSYNC_CORR_FORK_LENGTH-1 + FSYNC_CORR_RANGE_SAMPLES;
    InputSignal_Interpolated = papd_interp_nyq2(Input_signal, FSYNC_INTERP_FACTOR, IDX1, IDX2);


    % [filnrg=1, not required]
    %referenceSignalInt = referenceSignalInt / std(referenceSignalInt) * RMS_TARGET;

    fork     = (0:FSYNC_CORR_FORK_SPACE:(FSYNC_CORR_FORK_LENGTH-1)*FSYNC_CORR_FORK_SPACE);
    serA     = Output_signal( FSYNC_CORR_OFFSET + fork );
    SEEK_SAMPLES = FSYNC_CORR_RANGE_SAMPLES*FSYNC_INTERP_FACTOR;
    xCorrVec = zeros( 2*SEEK_SAMPLES+1 ,1);

    for k = ( -SEEK_SAMPLES:SEEK_SAMPLES ),
        %serB = referenceSignalInt((FSYNC_CORR_OFFSET + fork -1)*FSYNC_INTERP_FACTOR + k+1);
        serB = InputSignal_Interpolated(fork*FSYNC_INTERP_FACTOR + SEEK_SAMPLES + k+1);
        xCorrVec( SEEK_SAMPLES + k + 1 ) = serB*conj(serA);
    end;
    [ ~ , maxCorrIndex ] = max( abs( xCorrVec ) );

    delay = (maxCorrIndex - SEEK_SAMPLES - 1);

    if( delay >= 0 )
        IntDelay        = floor( delay / FSYNC_INTERP_FACTOR );
        FracDelay       = delay-IntDelay*FSYNC_INTERP_FACTOR;
        InputSignal_Interpolated = papd_delay_filter(Input_signal, FSYNC_INTERP_FACTOR, FracDelay);
        Input_signal = InputSignal_Interpolated((1+IntDelay):end);
        Output_signal   = Output_signal(1:end-IntDelay);
    else
        Knom            = 1+ceil( -delay/FSYNC_INTERP_FACTOR );
        Kref            = 1 + delay + (Knom-1)*FSYNC_INTERP_FACTOR;
        Input_signal = papd_delay_filter(Input_signal, FSYNC_INTERP_FACTOR, Kref - 1);
        Output_signal   = Output_signal( Knom : end );
    end;
    Input_signal = Input_signal(:);

    % --- Signal length equalization
    SigLen          = min( length(Input_signal), length(Output_signal) );
    Input_signal = Input_signal(1:SigLen);
    Output_signal   = Output_signal(1:SigLen);


    %% Rectangular to Polar conversion
    [ InputSignalPhase , InputSignalAmp ] = ...
        cart2pol( real( Input_signal ) , imag( Input_signal ) );

    [ OutputSignalPhase , OutputSignalAmp ] = ...
        cart2pol( real( Output_signal ) , imag( Output_signal ) );

    %% Frequency error and phase correction
    PSP_WRAP_THRESHOLD      = 1.1*3.1416;
    PSP_WRAP_SMOOTH_LENGTH  = 10;

    SignalsPhaseDelta=zeros(1,length( OutputSignalPhase ) );

    % get a vector with the difference in phase between input and output from 0-2*pi. Takes 0.5 Sec
    for k=1:length( OutputSignalPhase )
        SignalsPhaseDelta(k) =  phase_wrap( OutputSignalPhase( k ) , InputSignalPhase( k ) );
    end;

    %initialize first values to psp_avg
    SignalsPhaseDelta(1:PSP_WRAP_SMOOTH_LENGTH)=SignalsPhaseDelta(PSP_WRAP_SMOOTH_LENGTH+1);
    psp_avg = SignalsPhaseDelta(PSP_WRAP_SMOOTH_LENGTH)*PSP_WRAP_SMOOTH_LENGTH;

    % reduce 2*pi from high positive values of delta phase, add 2*pi to
    % low negative values of delta phase
    for k=PSP_WRAP_SMOOTH_LENGTH+1:length(SignalsPhaseDelta),
        if (SignalsPhaseDelta(k) - psp_avg/PSP_WRAP_SMOOTH_LENGTH > PSP_WRAP_THRESHOLD)
            SignalsPhaseDelta(k)=SignalsPhaseDelta(k)-2*pi;
        elseif (SignalsPhaseDelta(k) - psp_avg/PSP_WRAP_SMOOTH_LENGTH < -PSP_WRAP_THRESHOLD)
            SignalsPhaseDelta(k)=SignalsPhaseDelta(k)+2*pi;
        end;
        % this is a running block on the average values
        psp_avg = psp_avg + SignalsPhaseDelta(k) - SignalsPhaseDelta(k-PSP_WRAP_SMOOTH_LENGTH);
    end;
%plot(SignalsPhaseDelta);
    %---------[ Frequnecy error removal ]-----------
    [a_lin, b_lin] = dlinreg1(1:length(SignalsPhaseDelta), SignalsPhaseDelta);
    OutputSignalPhase = OutputSignalPhase - ([1:length(OutputSignalPhase)]' .* a_lin + b_lin);
    display(['frequency error correction: ' num2str(120e6*a_lin/(2*pi)) ' Hz']);

    %% PAPD frequency removal with MAC - not relevant now
    %         % start loop from smooth length till the MAC starts
    %         for k=PSP_WRAP_SMOOTH_LENGTH+1:MACSEG_START_IDX-1,
    %             if (SignalsPhaseDelta(k) - psp_avg/PSP_WRAP_SMOOTH_LENGTH > PSP_WRAP_THRESHOLD)
    %                 SignalsPhaseDelta(k)=SignalsPhaseDelta(k)-2*pi;
    %             elseif (SignalsPhaseDelta(k) - psp_avg/PSP_WRAP_SMOOTH_LENGTH < -PSP_WRAP_THRESHOLD)
    %                 SignalsPhaseDelta(k)=SignalsPhaseDelta(k)+2*pi;
    %             end;
    %             % this is a running block on the 
    %             psp_avg = psp_avg + SignalsPhaseDelta(k) - SignalsPhaseDelta(k-PSP_WRAP_SMOOTH_LENGTH);
    %         end;
    % figure;plot(SignalsPhaseDelta)
    %         % loop for the MAC itself
    %         for k=MACSEG_START_IDX:MACSEG_END_IDX,
    %             SignalsPhaseDelta(k) = psp_avg/PSP_WRAP_SMOOTH_LENGTH;
    %         end;
    % figure;plot(SignalsPhaseDelta)
    %         % proceed loop from end of MAC to the end
    %         for k=MACSEG_END_IDX+1:length(SignalsPhaseDelta),
    %             if (SignalsPhaseDelta(k) - psp_avg/PSP_WRAP_SMOOTH_LENGTH > PSP_WRAP_THRESHOLD)
    %                 SignalsPhaseDelta(k)=SignalsPhaseDelta(k)-2*pi;
    %             elseif (SignalsPhaseDelta(k) - psp_avg/PSP_WRAP_SMOOTH_LENGTH < -PSP_WRAP_THRESHOLD)
    %                 SignalsPhaseDelta(k)=SignalsPhaseDelta(k)+2*pi;
    %             end;
    %             psp_avg = psp_avg + SignalsPhaseDelta(k) - SignalsPhaseDelta(k-PSP_WRAP_SMOOTH_LENGTH);
    %         end;
    % figure;plot(SignalsPhaseDelta)
    %         %---------[ Frequnecy error removal ]-----------
    %         SignalsPhaseDelta2 = SignalsPhaseDelta(MACSEG_END_IDX:end);
    %         [a_lin, b_lin] = dlinreg1(1:length(SignalsPhaseDelta2), SignalsPhaseDelta2);
    %         SignalsPhaseDelta = SignalsPhaseDelta - ([1:length(SignalsPhaseDelta)] .* a_lin + b_lin);
    % figure;plot(SignalsPhaseDelta)
    % -------[ Zeroing MAC seed noise segmnet ]------ this part zeroes the mac parts that are different depending to who we send the message
    %         
    %         % Quantization of reference signal
    %         InputSignalAmp = quan( InputSignalAmp, AMPM_LUT_BITS, ...
    %             'unsigned' , 'round' , 'fixed' , 1 , 'q' , 0 );
    %         
    %         InputSignalAmp(MACSEG_START_IDX:MACSEG_END_IDX) = 0;
    %         InputSignalAmp(1:PSP_WRAP_SMOOTH_LENGTH) = 0;

    %% Polar to Rectangular conversion
    [input_real,input_imag]= pol2cart(InputSignalPhase,InputSignalAmp);
    [output_real,output_imag]= pol2cart(OutputSignalPhase,OutputSignalAmp);
    Input_signal = input_real + 1i*input_imag;
    Output_signal = output_real + 1i*output_imag;

    %% Return Signals
     Input_signal_aligned = Input_signal;
     Output_signal_aligned = Output_signal;
     
    if Display_Aligned_Signals
        figure;plot(real(Input_signal)/std(real(Input_signal)),'b');hold on;plot(real(Output_signal)/std(real(Output_signal)),'r');
        title('real Input Vs real Output divided in std');legend('Input- real','Output- real');
        figure;plot(imag(Input_signal)/std(imag(Input_signal)),'b');hold on;plot(imag(Output_signal)/std(imag(Output_signal)),'r');
        title('imag Input Vs imag Output divided in std');legend('Input- image','Output- image');
    end
    
end
