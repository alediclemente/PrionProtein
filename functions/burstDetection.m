% Burst detection starting from spike time histogram
% Arguments: 
% 1) spikeHistogram - a vector containing the spike time histogram of the
% recording
% 2) binsize - size of the bin to use (in ms)
% 3) N_activeElec - Number of active electrode in the recording
% 4) detectThr - minimum number of spikes in a bin to consider that bin as
% a candidate member of a burst expressed as fraction of active channels
% 5) wait_time - minimum distance, in ms, to consider two events as separate bursts
% 6) minDuration - minimum length, in ms, for the event to be considered a network
% burst
% 7) HardThr - Threshold to clean the burst from the one that are to small,
% expressed as fraction of active electrodes



function bursts = burstDetection(spikeHistogram, binsize, N_activeElec, detecThr, wait_time, minDuration, HardThr)

    min_burst_dist = wait_time/binsize;       %--minimum distance to consider two events as separate bursts (ms/binsize=measure in bins)
    min_burst_dur = minDuration/binsize;         %--minumu duration to consider the event as a burst
    min_burst_peak = N_activeElec*HardThr;            %--minimum peak amplitude in terms of spike rate to consider
    detectionThreshold = N_activeElec*detecThr;

    % -prima grossolana identificazione di inizio e fine dei bursts
    bursts_bins = find(spikeHistogram>detectionThreshold)';     %--create a variable with all the bins crossing the treshold (expressed as idx relative to bincounts)

    if isempty(bursts_bins) == 1
        disp('no burst detected')
        bursts = 'no burst detected';
        return
    end

    bursts_gap = find(diff(bursts_bins)>min_burst_dist);    %--creates a variable with the burst_bins indexes of all the gaps between a burst and the next one (that is the ends of the bursts)
    idxbursts_start = [1;bursts_gap+1];     %--indexes of the start of the burst from burst_gap
    idxbursts_end = [bursts_gap;length(bursts_bins)];   %--as above but with the ends (add length(burst_bins) or the last one is missing)
    
    %-leviamo oscillazioni in cui più del 30% dei bins sono sotto
    %soglia
    isABurst = false(length(idxbursts_start),1);
    
    for j = 1:length(idxbursts_start)
    
        burstCandidate = bursts_bins(idxbursts_start(j):idxbursts_end(j));
        binsAbove = length(burstCandidate);
        totBins = (burstCandidate(end)-burstCandidate(1))+1;
        isABurst(j) = binsAbove/totBins >= 0.30;
    
    end
    
    idxbursts_start = idxbursts_start(isABurst);

    if isempty(idxbursts_start) == 1
        disp('no burst detected')
        bursts = 'no burst detected';
        return
    end
    
    idxbursts_end = idxbursts_end(isABurst);
    burst_start_idx = bursts_bins(idxbursts_start);
    burst_end_idx = bursts_bins(idxbursts_end);     %--as above but with the ends
    
    % -rifiniamo aggiungendo la condizione "minimum burst duration"
    bursts_duration = (burst_end_idx-burst_start_idx);      %--duration of all the bursts in indexes
    burst_idx = find(bursts_duration>min_burst_dur);       %--find indexes of bursts longer than minimum

    if isempty(burst_idx) == 1
        disp('no burst detected')
        bursts = 'no burst detected';
        return
    end

    burst_start_idx = burst_start_idx(burst_idx);              %--new burst start: indexed from the old one thanks to the indexed obtained on the previuos line
    burst_end_idx = burst_end_idx(burst_idx);              %same of above but with the ends
    
    
    % -rifiniamo aggiungendo la condizione "minimum burst peak"
    burst_peaks = zeros(length(burst_start_idx),1);     %--this and the loop below create the vector with all the peaks

    for p = 1:length(burst_start_idx)
        burst_peaks(p,1) = max(spikeHistogram(burst_start_idx(p):burst_end_idx(p)));
    end

    burst_idx = find(burst_peaks>min_burst_peak);

    if isempty(burst_idx) == 1
        disp('no burst detected')
        bursts = 'no burst detected';
        return
    end

    burst_start_idx = burst_start_idx(burst_idx);
    burst_end_idx = burst_end_idx(burst_idx);

    %- sum up and put data into table
    burst_start_ms = (burst_start_idx-1)*binsize; % -1 because bin 1 goes from 0 to binsize ms
    burst_end_ms = (burst_end_idx-1)*binsize;
    burst_durations_ms = burst_end_ms - burst_start_ms;
    burst_N = 1:1:length(burst_start_idx);
    burst_N = burst_N';

    amplitude_Nspikes = zeros(length(burst_N),1);
    meanSpikeRate_Hz = zeros(length(burst_N),1);
    TimeToPeak_ms = zeros(length(burst_N),1);

    for n = 1:length(burst_N)

        meanSpikeRate = mean(spikeHistogram(burst_start_idx(n):burst_end_idx(n)));
        meanSpikeRate_Hz(n) = (meanSpikeRate/binsize)*1000;

        [maxSpikes, maxSpikes_idx] = max(spikeHistogram(burst_start_idx(n):burst_end_idx(n)));
        amplitude_Nspikes(n) = maxSpikes;
        TimeToPeak_ms(n) = maxSpikes_idx*binsize;

        %maxSpikeRate_Hz(n) = max(spikeHistogram(burst_start_idx(n):burst_end_idx(n)));
        %meanSpikeRate_Hz(n) = mean(spikeHistogram(burst_start_idx(n):burst_end_idx(n)));

    end

    bursts = table(burst_N, burst_start_idx, burst_end_idx, burst_start_ms, ...
        burst_end_ms, burst_durations_ms, TimeToPeak_ms, amplitude_Nspikes, meanSpikeRate_Hz);


end
