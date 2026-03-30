%% Reverberation analysis on each single burst

clearvars('-except',"mainfolder")

close all;

disp('performing Intra-Burst Oscillations analysis on each burst')

%-move to the main folder
cd(mainfolder)

pathToSaveFigs = [mainfolder '/statistics_figures'];

DIVs = dir('*DIV*');

for f = 1:length(DIVs)

    DIV = DIVs(f).name;
    disp(DIV)
    pathToData = [DIV '/RESULTS'];

    %-list recordings
    recordings = dir([pathToData '/*DIV*']);

    %-analysis for each recording
    for r = 1:length(recordings)

        recname = recordings(r).name;
        disp(recname)

        %-load spiketrain file
        pathToSpikes = [mainfolder '/' DIV '/spiketimes/' recname '.mat'];
        load(pathToSpikes,"allspks")
 
        %-load data of burst analysis
        load([pathToData '/' recname '/results.mat'])

        %- detrend each burst with movmean
        FastAndSlow_dir = [pathToData '/' recname '/Intraburst_oscillations'];

        binsize = 2;
        span = 50/binsize;
        [fastOscillations,slowOscillations] = getFastandSlow(bursts,allspks,binsize,span,0,FastAndSlow_dir);

        %- frequency analysis with CWT
        fs = 1000/binsize;
        CWTparameters = struct('wname',{'amor'},'VoicesPerOctave',24, ...
            'FrequencyLimits',[10 200],'Fs',fs);

        [scalograms,freqs_CWT,dominantFreqs_CWT,PSDs_CWT] = getFrequenciesCWT(fastOscillations,CWTparameters);

        %   - extract relevant parameters
        %       - how many bursts show DominantFreq?
        DominancePresence = false(height(bursts),1);

        for i = 1:length(DominancePresence)

            DominancePresence(i) = isDominantFreq(PSDs_CWT(i,:),freqs_CWT,fastOscillations(i,:),...
                [25 200],0);
            fprintf('DominantFreq %d is %s.\n', i, string(DominancePresence(i)));
            %pause
            close
        end

        DominantFreqBursts_CWT = bursts.burst_N(DominancePresence);
        NonDominantFreqBursts_CWT = bursts.burst_N(~DominancePresence);
        DominantFreqPSDs_CWT = PSDs_CWT(DominancePresence,:);

        %       - dominant frequency where there is frequency dominance
        dominantFreqs_CWT = dominantFreqs_CWT(DominancePresence);

        %       - power ratio for the different bands
        Fbands_CWT = struct('alpha',[8 12],'beta',[13 30],'gamma',[31 100],'highgamma',[101 200]);
        Fbands_names_CWT = fieldnames(Fbands_CWT);

        bandPowers_CWT = zeros(size(PSDs_CWT,1),numel(Fbands_names_CWT));
        
        for k = 1:size(PSDs_CWT,1)

            for h = 1:numel(Fbands_names_CWT)
                band = Fbands_names_CWT{h};
                bandPower_idx = freqs_CWT >= Fbands_CWT.(band)(1) & freqs_CWT <= Fbands_CWT.(band)(2);
                rel_bandPower = sum(PSDs_CWT(k,bandPower_idx))/sum(PSDs_CWT(k,:));
                bandPowers_CWT(k,h) = rel_bandPower;
            end

        end

        %   - save variables               
        CWT_Analysis_singleBursts.CWTtransform.Coefficients = scalograms;
        CWT_Analysis_singleBursts.CWTtransform.fs = fs;
        CWT_Analysis_singleBursts.CWTtransform.frequencies = freqs_CWT;
        CWT_Analysis_singleBursts.CWTtransform.parameters = CWTparameters;
        CWT_Analysis_singleBursts.BurstOscillations = fastOscillations;
        CWT_Analysis_singleBursts.PSDs = PSDs_CWT;
        CWT_Analysis_singleBursts.DominantFreq.DominantFreqBursts = DominantFreqBursts_CWT;
        CWT_Analysis_singleBursts.DominantFreq.NonDominantFreqBursts = NonDominantFreqBursts_CWT;
        CWT_Analysis_singleBursts.DominantFreq.DominantFreqPSDs = DominantFreqPSDs_CWT;
        CWT_Analysis_singleBursts.DominantFreq.DominantFrequencies = dominantFreqs_CWT;
        CWT_Analysis_singleBursts.FrequencyBands.Fbands = Fbands_CWT;
        CWT_Analysis_singleBursts.FrequencyBands.relativeBandsPower = bandPowers_CWT;

        save([pathToData '/' recname '/results.mat'],"CWT_Analysis_singleBursts","-append")

        %- frequency analysis with STFT
        windowLength = hamming(50);
        overlap = 30;
        nfft = 128;
        STFTparameters = struct('Fs',fs,'window',windowLength,'overlap',30,'nfft',128);

        [spectrograms,freqs_STFT,PSDs_STFT,dominantFreqs_STFT] = getFrequencies(fastOscillations,windowLength,...
            overlap,nfft,fs);

        %   - extract relevant parameters
        %       - how many bursts show frequency dominance?
        DominancePresence = false(height(bursts),1);

        for i = 1:length(DominancePresence)

            DominancePresence(i) = isDominantFreq(PSDs_STFT(i,:),freqs_STFT,fastOscillations(i,:),...
                [20 200],0);
            fprintf('DominantFreq %d is %s.\n', i, string(DominancePresence(i)));
            close
            
        end

        DominantFreqBursts_STFT = bursts.burst_N(DominancePresence);
        NonDominantFreqBursts_STFT = bursts.burst_N(~DominancePresence);

        %       - dominant frequency where there is DominantFreq
        dominantFreqs_STFT = dominantFreqs_STFT(DominancePresence);

        %       - power ratio for the different bands
        DominantFreqPSDs_STFT = PSDs_STFT(DominancePresence,:);
        Fbands_STFT = struct('alpha',[8 12],'beta',[13 30],'gamma',[31 100],'highgamma',[101 200]);
        Fbands_names_STFT = fieldnames(Fbands_STFT);

        bandPowers_STFT = zeros(size(DominantFreqPSDs_STFT,1),numel(Fbands_names_STFT));
        
        for k = 1:size(DominantFreqPSDs_STFT,1)

            for h = 1:numel(Fbands_names_STFT)
                band = Fbands_names_STFT{h};
                bandPower_idx = freqs_STFT >= Fbands_STFT.(band)(1) & freqs_STFT <= Fbands_STFT.(band)(2);
                rel_bandPower = sum(DominantFreqPSDs_STFT(k,bandPower_idx))/sum(DominantFreqPSDs_STFT(k,:));
                bandPowers_STFT(k,h) = rel_bandPower;
            end

        end

        %   - save variables               
        STFT_Analysis_singleBursts.STFTtransform.spectrograms = spectrograms;
        STFT_Analysis_singleBursts.STFTtransform.fs = fs;
        STFT_Analysis_singleBursts.STFTtransform.frequencies = freqs_STFT;
        STFT_Analysis_singleBursts.STFTtransform.parameters = STFTparameters;
        STFT_Analysis_singleBursts.BurstOscillations = fastOscillations;
        STFT_Analysis_singleBursts.PSDs = PSDs_STFT;
        STFT_Analysis_singleBursts.DominantFreq.DominantFreqBursts = DominantFreqBursts_STFT;
        STFT_Analysis_singleBursts.DominantFreq.NonDominantFreqBursts = NonDominantFreqBursts_STFT;
        STFT_Analysis_singleBursts.DominantFreq.DominantFreqPSDs = DominantFreqPSDs_STFT;
        STFT_Analysis_singleBursts.DominantFreq.DominantFrequencies = dominantFreqs_STFT;
        STFT_Analysis_singleBursts.FrequencyBands.Fbands = Fbands_STFT;
        STFT_Analysis_singleBursts.FrequencyBands.relativeBandsPower = bandPowers_STFT;

        save([pathToData '/' recname '/results.mat'],"STFT_Analysis_singleBursts","-append")

        %   - plot figures for comparisons
        %       - CWT Vs STFT DominantFreq bursts PSDs-single figure
        %       with allPSDs + meanPSD for the two methods
        pathToSaveSpectra = [pathToSaveFigs '/SpectralDensities/'];
        mkdir(pathToSaveSpectra)
        PowerSpectra = figure;
        tiledlayout(2,1,'TileSpacing','tight')
            
        nexttile(1)
        for b = 1:size(DominantFreqPSDs_CWT,1)
            plot(freqs_CWT,DominantFreqPSDs_CWT(b,:),'-', 'color',[0.6 0.6 0.6])
            hold on
        end
        plot(freqs_CWT,mean(DominantFreqPSDs_CWT),'r--','LineWidth',2)
        title('Wavelet Power Spectrum')
        xlabel('Frequency (Hz)')
        ylabel('Wavelet Scaled Power (spikes^2/Hz)')
        xlim([10 200])
            
        nexttile(2)
        for b = 1:size(DominantFreqPSDs_STFT,1)
            plot(freqs_STFT,DominantFreqPSDs_STFT(b,:),'-', 'color',[0.6 0.6 0.6])
            hold on
        end
        plot(freqs_STFT,mean(DominantFreqPSDs_STFT),'r--','LineWidth',2)
        title('Power Spectrum Densities')
        xlabel('Frequency (Hz)')
        ylabel('Power (spikes^2/Hz)')
        xlim([10 200])

        savefig(PowerSpectra,[pathToSaveSpectra recname '_AllDominantFreqPSDs'])
        close all


        %       - Spectrogrem Vs Scalogram-one figure for each burst
        time_ms = 0:binsize:(size(scalograms,2)*binsize)-1;
        pathToSaveGrams = [pathToData '/' recname '/spectrograms'];
        mkdir(pathToSaveGrams)

        SingleSpectra = figure;
        tiledlayout(3,1,'TileSpacing','tight')
        cleanupObj = onCleanup(@() close(SingleSpectra));

        for b = 1:height(bursts)

            clf(SingleSpectra,'reset')

            burstN = b;
            if ismember(b,DominantFreqBursts_CWT) == 1
                burstType_CWT = 'DominantFreq';
            else
                burstType_CWT = 'NonDominantFreq';
            end

            if ismember(b,DominantFreqBursts_STFT)
                burstType_STFT = 'DominantFreq';
            else
                burstType_STFT = 'NonDominantFreq';
            end
                    
            nexttile(1)
            pcolor(time_ms, freqs_CWT, scalograms(:,:,b));
            shading interp
            axis xy
            colormap jet
            c = colorbar;
            c.Label.String = 'Wavelet scaled Power (spikes^2/Hz)';
            xlabel('Time (ms)');
            ylabel('Frequency (Hz)');
            ylim([0 200])
            title(sprintf('CWT (scalogram) - burst %d (%s)', burstN, burstType_CWT));
            
            nexttile(2)
            imagesc(time_ms, freqs_STFT, spectrograms(:,:,b));
            axis xy;
            colormap jet
            c = colorbar;
            c.Label.String = 'Power (spikes^2/Hz)';
            xlabel('Time (ms)');
            ylabel('Frequency (Hz)');
            ylim([0 200])
            title(sprintf('STFT power spectrogram - burst %d (%s)', burstN, burstType_STFT));

            nexttile(3)
            plot(time_ms,fastOscillations(b,:))
            title('Detrended Burst')
            xlabel('Time (ms)')
            ylabel('# spikes')
    
            %      - save image
            savefig(SingleSpectra,sprintf('%s/ScaloVsSpectro_burst%d.fig', pathToSaveGrams, burstN))
            %pause
            close(SingleSpectra)
           
        end



    end

end

clearvars('-except',"mainfolder")
close all;


