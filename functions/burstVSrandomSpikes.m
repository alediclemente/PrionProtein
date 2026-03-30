%% count spikes inside the bursts VS spikes outside the burst (random)

function [spikesINbursts, spikesOUTbursts, ratio] = burstVSrandomSpikes(spikeHistogram, burst_start, burst_end)

    if isempty(burst_start) == 1
        spikesINbursts = 0;
        spikesOUTbursts = sum(spikeHistogram);
        ratio = nan;
        
    else

        burst_spikes = zeros(length(burst_start),1);
    
        for k = 1:length(burst_spikes)

            burst_spikes(k) = sum(spikeHistogram(burst_start(k):burst_end(k)));

        end

        random_spikes = zeros(length(burst_start),1);
        random_spikes(1) = sum(spikeHistogram(1:burst_start(1)-1));

        for i = 2:length(random_spikes)-1

            random_spikes(i) = sum(spikeHistogram(burst_end(i)+1:burst_start(i+1)-1));

        end

        random_spikes(end) = sum(spikeHistogram(burst_end(end):end));

        spikesINbursts = sum(burst_spikes);
        spikesOUTbursts = sum(random_spikes);
        ratio = (spikesINbursts/spikesOUTbursts);

    end


end