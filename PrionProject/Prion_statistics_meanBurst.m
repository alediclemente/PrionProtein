%% statistics/Spikes inside bursts VS spikes outside bursts

clearvars('-except',"mainfolder")
close all;

%-move to the main folder
cd(mainfolder)

%-create path to save
pathToSave = [mainfolder '/statistics_figures'];
mkdir(pathToSave)

DIVs = dir('*DIV*');

for f = 1:length(DIVs)

    DIV = DIVs(f).name;

    pathToData = [mainfolder '/' DIV '/RESULTS/'];
        
    %-KO
    recordings_KO = dir([pathToData '*KO*']);
    avg_bursts_KO = cell(length(recordings_KO),1);

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"mean_burst","binsize")
        avg_bursts_KO{r} = mean_burst;

    end

    avg_bursts_lengths_KO = cellfun("length",avg_bursts_KO);
    maxBurst_length_KO = max(avg_bursts_lengths_KO);

    avg_bursts_array_KO = zeros(length(avg_bursts_KO),maxBurst_length_KO);

    for r = 1:length(recordings_KO)

        avg_burst_KO = cell2mat(avg_bursts_KO(r));
        avg_burst_KO(end+1:maxBurst_length_KO) = 0;
        avg_bursts_array_KO(r,:) = avg_burst_KO;

    end

    mean_burstProfile_KO = mean(avg_bursts_array_KO);
    std_burstProfile_KO = std(avg_bursts_array_KO);
    %x_axis_KO = (0:1:(length(MeanBursts_KO)-1))*binsize;
    Peak_KO = max(mean_burstProfile_KO);

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    avg_bursts_WT = cell(length(recordings_WT),1);

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"mean_burst","binsize")
        avg_bursts_WT{r} = mean_burst;

    end

    avg_bursts_lengths_WT = cellfun("length",avg_bursts_WT);
    maxBurst_length_WT = max(avg_bursts_lengths_WT);

    avg_bursts_array_WT = zeros(length(avg_bursts_WT),maxBurst_length_WT);

    for r = 1:length(recordings_WT)

        avg_burst_WT = cell2mat(avg_bursts_WT(r));
        avg_burst_WT(end+1:maxBurst_length_WT) = 0;
        avg_bursts_array_WT(r,:) = avg_burst_WT;

    end

    mean_burstProfile_WT = mean(avg_bursts_array_WT);
    std_burstProfile_WT = std(avg_bursts_array_WT);
    %x_axis_WT = (0:1:(length(MeanBursts_WT)-1))*binsize;
    Peak_WT = max(mean_burstProfile_WT);

    %Align the mean bursts
    burstsLength = [length(mean_burstProfile_WT) length(mean_burstProfile_KO)];
    maxLength = max(burstsLength);
    mean_burstProfile_WT(end+1:maxLength) = 0;
    mean_burstProfile_KO(end+1:maxLength) = 0;
    %[meanBursts_aligned,~] = alignToPeak([mean_burstProfile_WT; mean_burstProfile_KO]);
    %mean_burstProfile_WT = meanBursts_aligned(1,:);
    %mean_burstProfile_KO = meanBursts_aligned(2,:);

    %Plot bursts together
    x_axis = (0:1:(length(mean_burstProfile_WT)-1))*binsize;
    %maxPeak = max([Peak_KO Peak_WT]);
    %[~,Peak_idx] = max(mean_burstProfile_WT);
    %Peak_ms = Peak_idx*binsize;
    %xBorders = [Peak_ms-500 Peak_ms+2500];

    burstProfile = figure;
    plot(x_axis,mean_burstProfile_WT,'b-','LineWidth',2)
    hold on
    plot(x_axis,mean_burstProfile_KO,'r-','LineWidth',2)
    %xlim(xBorders);
    legend('WT','KO','Location','northeast')
    xlabel('Time (ms)')
    ylabel('# Spikes')
    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.Title.String = DIV;
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';

    %and with normalized burst
    NormMean_burstProfile_WT = mean_burstProfile_WT/max(mean_burstProfile_WT);
    NormMean_burstProfile_KO = mean_burstProfile_KO/max(mean_burstProfile_KO);

    Normbursts_profile = figure;
    plot(x_axis,NormMean_burstProfile_WT,'b-','LineWidth',2)
    hold on
    plot(x_axis,NormMean_burstProfile_KO,'r-','LineWidth',2)
    %xlim(xBorders)
    legend('WT','KO','Location','northeast')
    xlabel('Time (ms)')
    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.Title.String = DIV;
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';


    %--save figures and tables
    savefig(burstProfile,[pathToSave '/BurstProfile_' DIV])
    saveas(burstProfile,[pathToSave '/BurstProfile_' DIV '.png'])

    AvgBurst_WT = table(x_axis',mean_burstProfile_WT','VariableNames',{'Time (ms)', 'Spike Count'});
    writetable(AvgBurst_WT,[pathToSave '/BurstProfile_WT_' DIV '.xlsx'])

    AvgBurst_KO = table(x_axis',mean_burstProfile_KO','VariableNames',{'Time (ms)', 'Spike Count'});
    writetable(AvgBurst_KO,[pathToSave '/BurstProfile_KO_' DIV '.xlsx'])


    savefig(Normbursts_profile,[pathToSave '/NormBurstProfile_' DIV])
    saveas(Normbursts_profile,[pathToSave '/NormBurstProfile_' DIV '.png'])

    NormAvgBurst_WT = table(x_axis',NormMean_burstProfile_WT','VariableNames',{'Time (ms)', 'Normalized Spike Count'});
    writetable(NormAvgBurst_WT,[pathToSave '/NormBurstProfile_WT_' DIV '.xlsx'])

    NormAvgBurst_KO = table(x_axis',NormMean_burstProfile_KO','VariableNames',{'Time (ms)', 'Normalized Spike Count'});
    writetable(NormAvgBurst_KO,[pathToSave '/NormBurstProfile_KO_' DIV '.xlsx'])


    close all

end

