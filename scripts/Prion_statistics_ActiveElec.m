%% statistics/Number of active electrodes

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
    threshActiveElec = 70;
        
    %-KO
    recordings_KO = dir([pathToData '*KO*']);
    N_activeElec_KO = zeros(length(recordings_KO),1);
    perc_activeElec_KO = zeros(length(recordings_KO),1);
    IsGood_KO = cell(length(recordings_KO),1);
    recnames_KO = cell(length(recordings_KO),1);

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"QSTinfo")
        recnames_KO{r} = recname;

        N_activeElec_KO(r) = QSTinfo.NactiveElectrodes;
        perc_activeElec_KO(r) = (QSTinfo.NactiveElectrodes/120)*100;

        if perc_activeElec_KO(r) >= threshActiveElec
            IsGood_KO{r} = 'Y';
        else
            IsGood_KO{r} = 'N';
        end
        
    end

    ActiveElecCheck_KO = table(recnames_KO,perc_activeElec_KO,IsGood_KO);

    clearvars("QSTinfo")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    N_activeElec_WT = zeros(length(recordings_WT),1);
    perc_activeElec_WT = zeros(length(recordings_WT),1);
    IsGood_WT = cell(length(recordings_WT),1);
    recnames_WT = cell(length(recordings_WT),1);

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"QSTinfo")
        recnames_WT{r} = recname;

        N_activeElec_WT(r) = QSTinfo.NactiveElectrodes; 
        perc_activeElec_WT(r) = (QSTinfo.NactiveElectrodes/120)*100;

        if perc_activeElec_WT(r) >= threshActiveElec
            IsGood_WT{r} = 'Y';
        else
            IsGood_WT{r} = 'N';
        end
   
    end

    ActiveElecCheck_WT = table(recnames_WT,perc_activeElec_WT,IsGood_WT);

    clearvars("QSTinfo") % was: clearvars("bursts")

    %-putting together
    lengths = [length(N_activeElec_WT) length(N_activeElec_KO)];
    max_length = max(lengths);

    N_activeElec_WT(end+1:max_length+1) = nan;

    N_activeElec_KO(end+1:max_length+1) = nan;

    N_activeElec = [N_activeElec_WT, N_activeElec_KO];


    %-violinplot
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    violinplot_N_activeElec = figure;
    violinplot_NactiveElec = violinplott(N_activeElec,Conditions,'ViolinColor',Colors);
    hold on

    Q1 = quantile(N_activeElec,0.25); % was: Q1 = quantile(N_bursts,0.25);
    Q3 = quantile(N_activeElec,0.75); % was: Q3 = quantile(N_bursts,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on
    
    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ylabel('Number of active electrodes') % was: ylabel('Number of Bursts')
    ax.Title.String = DIV;
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    
 
    %-statistics
    try
        WT_normality = adtest(N_activeElec_WT);
        KO_normality = adtest(N_activeElec_KO);
    
        if WT_normality == 1 && KO_normality == 1
           [different, pValue, ci, stats] = ttest2(N_activeElec_WT,N_activeElec_KO); 
           test = 'ttest';
           mediana = median(N_activeElec,'omitnan'); 
           IQR = iqr(N_activeElec); 
           effectSize_r2 = stats.tstat^2/(stats.tstat^2+stats.df);
        else
           [pValue,different,stats] = ranksum(N_activeElec_WT,N_activeElec_KO,'method', 'approximate'); 
           test = 'Mann Whitney';
           mediana = median(N_activeElec,'omitnan'); 
           IQR = iqr(N_activeElec); 
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

    %--put NactiveElec into tables % was: %--put Nbursts into tables
    N_activeElec = table(N_activeElec_WT,N_activeElec_KO); % was: N_bursts = table(N_bursts_WT,N_bursts_KO);

    %-save figure
    savefig(violinplot_N_activeElec,[pathToSave '/NactiveElec_' DIV]) % was: savefig(violinplot_N_bursts,[pathToSave '/Nbursts_' DIV])
    saveas(violinplot_N_activeElec,[pathToSave '/NactiveElec_' DIV '.png']) % was: saveas(violinplot_N_bursts,[pathToSave '/Nbursts_' DIV '.png'])

    %-save statistics
    save([pathToSave '/statistics_NactiveElec' DIV '.mat'],"N_activeElec","pValue","test","stats",... % was: save([pathToSave '/statistics_Nburst' DIV '.mat'],"N_bursts","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")
    writetable(N_activeElec,[pathToSave '/statistics_NactiveElec' DIV '.xlsx'])
    writetable(ActiveElecCheck_WT,[pathToSave '/ActiveElecCheck_WT' DIV '.xlsx'])
    writetable(ActiveElecCheck_KO,[pathToSave '/ActiveEclecCheck_KO' DIV '.xlsx'])

    close all

end