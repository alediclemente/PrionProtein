%% Statistics/IBIs

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
    IBIs_KO = [];

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"bursts")
        disp(height(bursts))

        if istable(bursts) == 1
            burst_starts = bursts.burst_start_ms(2:end);
            burst_ends = bursts.burst_end_ms(1:end-1);
            IBIs = burst_starts - burst_ends;

            IBIs_KO = [IBIs_KO; IBIs];
        else
            IBIs_KO = [IBIs_KO; nan];
        end

    end

    clearvars("bursts", "IBIs")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    IBIs_WT = [];

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"bursts")

        if istable(bursts) == 1
            burst_starts = bursts.burst_start_ms(2:end);
            burst_ends = bursts.burst_end_ms(1:end-1);
            IBIs = burst_starts - burst_ends;

            IBIs_WT = [IBIs_WT; IBIs];
        else
            IBIs_WT = [IBIs_WT; nan];
        end

    end

    clearvars("bursts", "IBIs")

    %-putting together
    lengths = [length(IBIs_WT) length(IBIs_KO)];
    max_length = max(lengths);

    IBIs_WT(end+1:max_length+1) = nan;

    IBIs_KO(end+1:max_length+1) = nan;

    allIBIs = [IBIs_WT, IBIs_KO];

    %-Violinplot
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    ViolinPlot_burst_durations = figure;
    ViolinPlot_burstDurations = violinplott(allIBIs,Conditions,"ShowData",true,...
        'ViolinColor',Colors);

    Q1 = quantile(allIBIs,0.25);
    Q3 = quantile(allIBIs,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([-0.5 uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['Inter Burst Intervals ' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Time (ms)')

    %-statistics
    WT_normality = adtest(IBIs_WT);
    KO_normality = adtest(IBIs_KO);

    if WT_normality == 1 && KO_normality == 1
       [different, pValue, ci, stats] = ttest2(IBIs_WT,IBIs_KO);
       test = 'ttest';
       mediana = median(allIBIs,'omitnan');
       IQR = iqr(allIBIs);
       effectSize_r2 = stats.tstat^2/(stats.tstat^2+stats.df);
    else
       [pValue,different,stats] = ranksum(IBIs_WT,IBIs_KO);
       test = 'Mann Whitney';
       mediana = median(allIBIs,'omitnan');
       IQR = iqr(allIBIs);
       effectSize_r2 = stats.zval^2/sum(lengths);
    end


    %-save figure
    savefig(ViolinPlot_burst_durations,[pathToSave '/IBIs_' DIV])
    saveas(ViolinPlot_burst_durations,[pathToSave '/IBIs_' DIV '.png'])

    %--put burst durations into table
    allIBIs = table(IBIs_WT,IBIs_KO);

    %-save statistics
    save([pathToSave '/statistics_IBIs_' DIV '.mat'],"allIBIs","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")
    writetable(allIBIs,[pathToSave '/statistics_IBIs_' DIV '.xlsx'])

    close all

end


