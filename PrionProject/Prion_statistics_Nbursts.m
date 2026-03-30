%% statistics/Number of bursts

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
    N_bursts_KO = zeros(length(recordings_KO),1);

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"bursts")

        if istable(bursts) == 1
            N_bursts_KO(r) = height(bursts);
        else
            N_bursts_KO(r) = 0;
        end

    end

    clearvars("bursts")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    N_bursts_WT = zeros(length(recordings_WT),1);

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"bursts")

        if istable(bursts) == 1
            N_bursts_WT(r) = height(bursts);
        else
            N_bursts_WT(r) = 0;
        end

    end

    clearvars("bursts")

    %-putting together
    lengths = [length(N_bursts_WT) length(N_bursts_KO)];
    max_length = max(lengths);

    N_bursts_WT(end+1:max_length+1) = nan;

    N_bursts_KO(end+1:max_length+1) = nan;

    N_bursts = [N_bursts_WT, N_bursts_KO];


    %-violinplot
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    violinplot_N_bursts = figure;
    violinplot_Nbursts = violinplott(N_bursts,Conditions,'ViolinColor',Colors);
    hold on

    Q1 = quantile(N_bursts,0.25);
    Q3 = quantile(N_bursts,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on
    
    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ylabel('Number of Bursts')
    ax.Title.String = DIV;
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    
 
    %-statistics
    try
        WT_normality = adtest(N_bursts_WT);
        KO_normality = adtest(N_bursts_KO);
    
        if WT_normality == 1 && KO_normality == 1
           [different, pValue, ci, stats] = ttest2(N_bursts_WT,N_bursts_KO);
           test = 'ttest';
           mediana = median(N_bursts,'omitnan');
           IQR = iqr(N_bursts);
           effectSize_r2 = stats.tstat^2/(stats.tstat^2+stats.df);
        else
           [pValue,different,stats] = ranksum(N_bursts_WT,N_bursts_KO,'method', 'approximate');
           test = 'Mann Whitney';
           mediana = median(N_bursts,'omitnan');
           IQR = iqr(N_bursts);
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

    %--put Nbursts into tables
    N_bursts = table(N_bursts_WT,N_bursts_KO);

    %-save figure
    savefig(violinplot_N_bursts,[pathToSave '/Nbursts_' DIV])
    saveas(violinplot_N_bursts,[pathToSave '/Nbursts_' DIV '.png'])

    %-save statistics
    save([pathToSave '/statistics_Nburst' DIV '.mat'],"N_bursts","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")
    writetable(N_bursts,[pathToSave '/statistics_Nburst' DIV '.xlsx'])

    close all

end

