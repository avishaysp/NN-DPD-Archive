load('K18m_PA_Data.mat');

SpectAnalyzer = spectrumAnalyzer;
SpectAnalyzer.SampleRate = fs;
SpectAnalyzer.ShowLegend = true;
SpectAnalyzer.SpectralAverages = 32;
SpectAnalyzer.ReferenceLoad = 50;
SpectAnalyzer.RBWSource= "Property";
SpectAnalyzer.RBW = 1e5;
SpectAnalyzer.OverlapPercent = 50;
SpectAnalyzer([iq_in, iq_out, iq_out_dpd]);
SpectAnalyzer.ChannelNames = {'PA_in','PA_out','PA_out_w/DPD'};