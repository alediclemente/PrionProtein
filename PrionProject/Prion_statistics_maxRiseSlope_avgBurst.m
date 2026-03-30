%% statistics/max rise slope

clear; clc; close all;

%-move to the main folder
disp('select main folder')
cd('/Users/alessio/ToAnalyze/PrionProject/KnockOut')

mainfolder = pwd();

%-create path to save
pathToSave = [mainfolder '/statistics_figures'];
mkdir(pathToSave)

DIVs = dir('*DIV*');

for f = 1:length(DIVs)

    DIV = DIVs(f).name;

    pathToData = [mainfolder '/' DIV '/RESULTS/'];
        
    %-KO
    recordings_KO = dir([pathToData '*KO*']);
    maxRiseSlope_KO = zeros(length(recordings_KO),1);

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"maxRiseSlope")
        maxRiseSlope_KO(r) = maxRiseSlope;

    end

    clearvars("maxRiseSlope")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    maxRiseSlope_WT = zeros(length(recordings_WT),1);

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"maxRiseSlope")
        maxRiseSlope_WT(r) = maxRiseSlope;

    end

    clearvars("maxRiseSlope")

    %-putting together
    lengths = [length(maxRiseSlope_WT) length(maxRiseSlope_KO)];
    max_length = max(lengths);

    maxRiseSlope_WT(end+1:max_length+1) = nan;

    maxRiseSlope_KO(end+1:max_length+1) = nan;

    maxRiseSlope = [maxRiseSlope_WT, maxRiseSlope_KO];

    %-Violnplot
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    ViolinPlot_maxRise_slope = figure;
    ViolinPlot_maxRiseSlope = violinplott(maxRiseSlope,Conditions,'ViolinColor',Colors);

    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['Max rise slope ' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Rise slope (Hz*ms^-1)')

    %-statistics
    WT_normality = adtest(maxRiseSlope_WT);
    KO_normality = adtest(maxRiseSlope_KO);

    if WT_normality == 1 && KO_normality == 1
       [different, pValue, ci, stats] = ttest(maxRiseSlope_WT,maxRiseSlope_KO);
       test = 'ttest';
    else
       [pValue,different,stats] = ranksum(maxRiseSlope_WT,maxRiseSlope_KO);
       test = 'Mann Whitney';
    end

    if different == 1
       maxMaxSlope = max(max(maxRiseSlope));
       plot([1 2],[maxMaxSlope+5 maxMaxSlope+5],'k-','LineWidth',2)
    end

    %-save figure
    savefig(ViolinPlot_maxRise_slope,[pathToSave '/maxRiseSlope_avgBurst_' DIV])
    saveas(ViolinPlot_maxRise_slope,[pathToSave '/maxRiseSlope_avgBurst_' DIV '.png'])

    %-save statistics
    save([pathToSave '/statistics_maxRiseSlope_avgBurst_' DIV '.mat'],"maxRiseSlope","maxRiseSlope_KO","maxRiseSlope_WT","pValue","test","stats")

    close all

end

clear; clc; close all;
