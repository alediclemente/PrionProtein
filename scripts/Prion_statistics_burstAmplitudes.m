%% Statistics/Max spiking rate

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
    BurstAmpl_KO = [];

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"bursts")

        if istable(bursts) == 1
            BurstAmpl_KO = [BurstAmpl_KO; bursts.amplitude_Nspikes];
        else
            BurstAmpl_KO = [BurstAmpl_KO; nan];
        end

    end

    clearvars("bursts")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    BurstAmpl_WT = [];

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"bursts")

        if istable(bursts) == 1
            BurstAmpl_WT = [BurstAmpl_WT; bursts.amplitude_Nspikes];
        else
            BurstAmpl_WT = [BurstAmpl_WT; nan];
        end

    end

    clearvars("bursts")

    %-putting together
    lengths = [length(BurstAmpl_WT) length(BurstAmpl_KO)];
    max_length = max(lengths);

    BurstAmpl_WT(end+1:max_length+1) = nan;

    BurstAmpl_KO(end+1:max_length+1) = nan;

    BurstAmplitudes = [BurstAmpl_WT, BurstAmpl_KO];

    %-Violinplot
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    ViolinPlot_Ampl = figure;
    ViolinPlot_maxSpikes = violinplott(BurstAmplitudes,Conditions,'ViolinColor',Colors);

    Q1 = quantile(BurstAmplitudes,0.25);
    Q3 = quantile(BurstAmplitudes,0.75);
    Q1_3 = Q3-Q1;
    upWhisker = max(Q3)+1.5*max(Q1_3);
    ylim([0 upWhisker])

    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['Burst Amplitude ' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('# Spikes')


    %-statistics
    try
        WT_normality = adtest(BurstAmpl_WT);
        KO_normality = adtest(BurstAmpl_KO);
    
        if WT_normality == 1 && KO_normality == 1
           [different, pValue, ci, stats] = ttest2(BurstAmpl_WT,BurstAmpl_KO);
           test = 'ttest';
           mediana = median(BurstAmplitudes,'omitnan');
           IQR = iqr(BurstAmplitudes);
           effectSize_r2 = stats.tstat^2/(stats.tstat^2+stats.df);
        else
           [pValue,different,stats] = ranksum(BurstAmpl_WT,BurstAmpl_KO);
           test = 'Mann Whitney';
           mediana = median(BurstAmplitudes,'omitnan');
           IQR = iqr(BurstAmplitudes);
           effectSize_r2 = stats.zval^2/sum(lengths);
        end
    catch
        WT_normality = nan;
        KO_normality = nan;
        different = nan;
        pValue = nan;
        ci = nan;
        stats = nan;
        test = 'none';
        mediana = nan;
        IQR = nan;
        effectSize_r2 = nan;              
    end


    %-save figure
    savefig(ViolinPlot_Ampl,[pathToSave '/BurstAmplitude_' DIV])
    saveas(ViolinPlot_Ampl,[pathToSave '/BurstAmplitude_' DIV '.png'])

    %--put max spiking rate into table
    BurstAmplitudes = table(BurstAmpl_WT,BurstAmpl_KO);

    %-save statistics
    save([pathToSave '/statistics_BurstAmplitudes' DIV '.mat'],"BurstAmplitudes","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")
    writetable(BurstAmplitudes,[pathToSave '/statistics_BurstAmplitudes' DIV '.xlsx'])

    close all

end


