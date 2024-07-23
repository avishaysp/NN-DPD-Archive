%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% YAKINTON - OFDM POWER CLIPPING Simulator
%%% DSP & ARCH TEAM
%%% WPDh, 2005 , INTEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  --->  SignalVrms  <---
%%
%%
%%  SYNOPSIS:
%%  SignalVrms function calculates signal Vrms.
%%
%%  INPUT:
%%      sig_in = input signal
%%  OUTPUT:
%%      vrms - average power
%%
%%  Date Created: 4/10/2005
%%  Date Modified: 4/10/2005
%%
%%  TODO:
%%  1)
%%  2)

function vrms = SignalVrms( sig_in )
    vrms = sqrt((sig_in(:)'*sig_in(:)) / length(sig_in(:)) );
return;