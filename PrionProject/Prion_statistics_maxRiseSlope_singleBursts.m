%% statistics/max rise slope from each burst

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
    singleMaxRiseSlopes_KO = [];

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"NormSingleMaxRiseSlopes","bursts")

        if istable(bursts) == 1
            singleMaxRiseSlopes_KO = vertcat(singleMaxRiseSlopes_KO,NormSingleMaxRiseSlopes);
        end

    end

    clearvars("NormSingleMaxRiseSlopes")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    singleMaxRiseSlopes_WT = [];

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"NormSingleMaxRiseSlopes")

        if istable(bursts) == 1
            singleMaxRiseSlopes_WT = vertcat(singleMaxRiseSlopes_WT,NormSingleMaxRiseSlopes);
        end

    end

    clearvars("NormSingleMaxRiseSlopes")

    %-putting together
    lengths = [length(singleMaxRiseSlopes_WT) length(singleMaxRiseSlopes_KO)];
    max_length = max(lengths);

    singleMaxRiseSlopes_WT(end+1:max_length+1) = nan;
    singleMaxRiseSlopes_KO(end+1:max_length+1) = nan;

    singleMaxRiseSlope = [singleMaxRiseSlopes_WT, singleMaxRiseSlopes_KO];

    %-boxplot
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    ViolinPlot_singleMaxRise_slope = figure;
    ViolinPlot_singleMaxRiseSlope = violinplott(singleMaxRiseSlope,Conditions,'ViolinColor',Colors);

    Q1 = quantile(singleMaxRiseSlope,0.25);
    Q3 = quantile(singleMaxRiseSlope,0.75);
    Q1_3 = Q3-Q1;
    upWhisker = max(Q3)+1.5*max(Q1_3);
    ylim([0 upWhisker])

    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['Normalized Max rise slope on single bursts' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Rise slope (ms^-1)')
 
    %-statistics
    WT_normality = adtest(singleMaxRiseSlopes_WT);
    KO_normality = adtest(singleMaxRiseSlopes_KO);

    if WT_normality == 1 && KO_normality == 1
       [different, pValue, ci, stats] = ttest2(singleMaxRiseSlopes_WT,singleMaxRiseSlopes_KO);
       test = 'ttest';
       mediana = median(singleMaxRiseSlope,'omitnan');
       IQR = iqr(singleMaxRiseSlope);
       effectSize_r2 = stats.tstat^2/(stats.tstat^2+stats.df);
    else
       [pValue,different,stats] = ranksum(singleMaxRiseSlopes_WT,singleMaxRiseSlopes_KO);
       test = 'Mann Whitney';
       mediana = median(singleMaxRiseSlope,'omitnan');
       IQR = iqr(singleMaxRiseSlope);
       effectSize_r2 = stats.zval^2/sum(lengths);
    end

    %--put single max rise slopes into table
    singleMaxRiseSlope = table(singleMaxRiseSlopes_WT,singleMaxRiseSlopes_KO);


    %-save figure
    savefig(ViolinPlot_singleMaxRise_slope,[pathToSave '/NormMaxRiseSlope_singleBursts_' DIV])
    saveas(ViolinPlot_singleMaxRise_slope,[pathToSave '/NormMaxRiseSlope_singleBursts_' DIV '.png'])

    %-save statistics
    save([pathToSave '/statistics_NormMaxRiseSlope_singleBursts_' DIV '.mat'],"singleMaxRiseSlope","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")
    writetable(singleMaxRiseSlope,[pathToSave '/statistics_NormMaxRiseSlope_singleBursts_' DIV '.xlsx'])

    close all

end

close all;
