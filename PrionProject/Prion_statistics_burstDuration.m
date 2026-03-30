%% Statistics/Burst duration

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
    burst_durations_KO = [];

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"bursts")

        if istable(bursts) == 1
            burst_durations_KO = [burst_durations_KO; bursts.burst_durations_ms];
        else
            burst_durations_KO = [burst_durations_KO; nan];
        end

    end

    clearvars("bursts")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    burst_durations_WT = [];

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"bursts")

        if istable(bursts) == 1
            burst_durations_WT = [burst_durations_WT; bursts.burst_durations_ms];
        else
            burst_durations_WT = [burst_durations_WT; nan];
        end

    end

    clearvars("bursts")

    %-putting together
    lengths = [length(burst_durations_WT) length(burst_durations_KO)];
    max_length = max(lengths);

    burst_durations_WT(end+1:max_length+1) = nan;

    burst_durations_KO(end+1:max_length+1) = nan;

    burst_durations = [burst_durations_WT, burst_durations_KO];

    %-Violinplot
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    ViolinPlot_burst_durations = figure;
    ViolinPlot_burstDurations = violinplott(burst_durations,Conditions,"ShowData",true,...
        'ViolinColor',Colors);

    Q1 = quantile(burst_durations,0.25);
    Q3 = quantile(burst_durations,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([-0.5 uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['burst duration ' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Time (ms)')

    %-statistics
    WT_normality = adtest(burst_durations_WT);
    KO_normality = adtest(burst_durations_KO);

    if WT_normality == 1 && KO_normality == 1
       [different, pValue, ci, stats] = ttest2(burst_durations_WT,burst_durations_KO);
       test = 'ttest';
       mediana = median(burst_durations,'omitnan');
       IQR = iqr(burst_durations);
       effectSize_r2 = stats.tstat^2/(stats.tstat^2+stats.df);
    else
       [pValue,different,stats] = ranksum(burst_durations_WT,burst_durations_KO);
       test = 'Mann Whitney';
       mediana = median(burst_durations,'omitnan');
       IQR = iqr(burst_durations);
       effectSize_r2 = stats.zval^2/sum(lengths);
    end


    %-save figure
    savefig(ViolinPlot_burst_durations,[pathToSave '/burstDuration_' DIV])
    saveas(ViolinPlot_burst_durations,[pathToSave '/burstDuration_' DIV '.png'])

    %--put burst durations into table
    burst_durations = table(burst_durations_WT,burst_durations_KO);

    %-save statistics
    save([pathToSave '/statistics_burstDuration' DIV '.mat'],"burst_durations","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")
    writetable(burst_durations,[pathToSave '/statistics_burstDuration' DIV '.xlsx'])

    close all

end


