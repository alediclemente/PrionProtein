%% Statistics on IntraBurst Oscillations for prion protein project

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
    dominantFrequencies_KO = [];
    meanPSD_KO = cell(numel(recordings_KO),1);
    FreqVect_KO = cell(numel(recordings_KO),1);
    alphaPowers_KO = [];
    betaPowers_KO = [];
    gammaPowers_KO = [];
    highgammaPowers_KO = [];

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"SpectralAnalysis")
        
        [~,dominantFrequency_idx] = max(SpectralAnalysis.PSDs,[],2);
        dominantFrequencies_KO = [dominantFrequencies_KO; ...
            SpectralAnalysis.Frequencies(dominantFrequency_idx)];

        alphaPowers_KO = [alphaPowers_KO; SpectralAnalysis.BandsPower.alpha];
        betaPowers_KO = [betaPowers_KO; SpectralAnalysis.BandsPower.beta];
        gammaPowers_KO = [gammaPowers_KO; SpectralAnalysis.BandsPower.gamma];
        highgammaPowers_KO = [highgammaPowers_KO; SpectralAnalysis.BandsPower.highgamma];

        meanPSD_KO{r} = SpectralAnalysis.meanPSD;
        FreqVect_KO{r} = SpectralAnalysis.Frequencies;
                
    end

    clearvars("SpectralAnalysis", "dominantFrequency_idx")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    dominantFrequencies_WT = [];
    BandsPower_WT = [];
    meanPSD_WT = cell(numel(recordings_WT),1);
    FreqVect_WT = cell(numel(recordings_WT),1);
    alphaPowers_WT = [];
    betaPowers_WT = [];
    gammaPowers_WT = [];
    highgammaPowers_WT = [];

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"SpectralAnalysis")
        
        [~,dominantFrequency_idx] = max(SpectralAnalysis.PSDs,[],2);
        dominantFrequencies_WT = [dominantFrequencies_WT; ...
            SpectralAnalysis.Frequencies(dominantFrequency_idx)];

        alphaPowers_WT = [alphaPowers_WT; SpectralAnalysis.BandsPower.alpha];
        betaPowers_WT = [betaPowers_WT; SpectralAnalysis.BandsPower.beta];
        gammaPowers_WT = [gammaPowers_WT; SpectralAnalysis.BandsPower.gamma];
        highgammaPowers_WT = [highgammaPowers_WT; SpectralAnalysis.BandsPower.highgamma];

        meanPSD_WT{r} = SpectralAnalysis.meanPSD;
        FreqVect_WT{r} = SpectralAnalysis.Frequencies;

    end

    Fbands = SpectralAnalysis.Fbands;
    clearvars("SpectralAnalysis", "dominantFrequency_idx")


    %-putting together dominant frequencies
    lengths = [length(dominantFrequencies_WT) length(dominantFrequencies_KO)];
    max_length = max(lengths);

    dominantFrequencies_WT(end+1:max_length+1) = nan;
    dominantFrequencies_KO(end+1:max_length+1) = nan;

    dominantFrequencies = [dominantFrequencies_WT dominantFrequencies_KO];

    %-putting together frequency bands power

    %-alpha
    alphaPowers_WT(end+1:max_length+1) = nan;
    alphaPowers_KO(end+1:max_length+1) = nan;
    alphaPowers = [alphaPowers_WT alphaPowers_KO];

    %-beta
    betaPowers_WT(end+1:max_length+1) = nan;
    betaPowers_KO(end+1:max_length+1) = nan;
    betaPowers = [betaPowers_WT betaPowers_KO];    

    %-gamma
    gammaPowers_WT(end+1:max_length+1) = nan;
    gammaPowers_KO(end+1:max_length+1) = nan;
    gammaPowers = [gammaPowers_WT gammaPowers_KO];

    %-highgamma
    highgammaPowers_WT(end+1:max_length+1) = nan;
    highgammaPowers_KO(end+1:max_length+1) = nan;
    highgammaPowers = [highgammaPowers_WT highgammaPowers_KO];


    %-Violinplots
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    %-Dominant Frequency
    ViolinPlot_dominantFr = figure;
    ViolinPlot_Frequencies = violinplott(dominantFrequencies,Conditions,"ShowData",true,...
        'ViolinColor',Colors);

    Q1 = quantile(dominantFrequencies,0.25);
    Q3 = quantile(dominantFrequencies,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([-0.5 uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['IntraBurst Oscillations Dominant Frequencies' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Frequency (Hz)')

    %-alpha band
    ViolinPlot_alphaP = figure;
    ViolinPlot_alpha = violinplott(alphaPowers,Conditions,"ShowData",true,...
        'ViolinColor',Colors);

    Q1 = quantile(alphaPowers,0.25);
    Q3 = quantile(alphaPowers,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['alpha band (8-12 Hz) Power' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Power (spikes^2)')

    %-beta band
    ViolinPlot_betaP = figure;
    ViolinPlot_beta = violinplott(betaPowers,Conditions,"ShowData",true,...
        'ViolinColor',Colors);

    Q1 = quantile(betaPowers,0.25);
    Q3 = quantile(betaPowers,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['beta band (13-30 Hz) Power' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Power (spikes^2)')

    %-gamma
    ViolinPlot_gammaP = figure;
    ViolinPlot_gamma = violinplott(gammaPowers,Conditions,"ShowData",true,...
        'ViolinColor',Colors);

    Q1 = quantile(gammaPowers,0.25);
    Q3 = quantile(gammaPowers,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['gamma band (31-100 Hz) Power' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Power (spikes^2)')

    %-highGamma
    ViolinPlot_highgammaP = figure;
    ViolinPlot_highgamma = violinplott(highgammaPowers,Conditions,"ShowData",true,...
        'ViolinColor',Colors);

    Q1 = quantile(highgammaPowers,0.25);
    Q3 = quantile(highgammaPowers,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['highgamma band (101-200 Hz) Power' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Power (spikes^2)')

    %-plot average power spectrum
    avg_meanPSD_WT = mean(cell2mat(meanPSD_WT));
    avg_meanPSD_KO = mean(cell2mat(meanPSD_KO));

    avg_PSD = figure;
    tiledlayout(2,1,'TileSpacing','tight')

    nexttile
    for p = 1:numel(recordings_WT)
        plot(FreqVect_WT{p},meanPSD_WT{p},'-', 'color',[0.6 0.6 0.6])
        hold on
    end
    plot(FreqVect_WT{1},avg_meanPSD_WT,'r--','LineWidth',1.5)

    nexttile
    for p = 1:numel(recordings_KO)
        plot(FreqVect_KO{p},meanPSD_KO{p},'-', 'color',[0.6 0.6 0.6])
        hold on
    end
    plot(FreqVect_KO{1},avg_meanPSD_KO,'r--','LineWidth',1.5)
    

    %-statistics dominant freq
    WT_normality_Fr = adtest(dominantFrequencies_WT);
    KO_normality_Fr = adtest(dominantFrequencies_KO);

    if WT_normality_Fr == 1 && KO_normality_Fr == 1
       [different_Fr, pValue_Fr, ci_Fr, stats_Fr] = ttest2(dominantFrequencies_WT,dominantFrequencies_KO);
       test_Fr = 'ttest';
       mediana_Fr = median(dominantFrequencies,'omitnan');
       IQR_Fr = iqr(dominantFrequencies);
       effectSize_r2_Fr = stats_Fr.tstat^2/(stats_Fr.tstat^2+stats_Fr.df);
    else
       [pValue_Fr,different_Fr,stats_Fr] = ranksum(dominantFrequencies_WT,dominantFrequencies_KO);
       test_Fr = 'Mann Whitney';
       mediana_Fr = median(dominantFrequencies,'omitnan');
       IQR_Fr = iqr(dominantFrequencies);
       effectSize_r2_Fr = stats_Fr.zval^2/sum(lengths);
    end


    %-statistics frequency bands power
    %-alpha
    WT_normality_alpha = adtest(alphaPowers_WT);
    KO_normality_alpha = adtest(alphaPowers_KO);

    if WT_normality_alpha == 1 && KO_normality_alpha == 1
       [different_alpha, pValue_alpha, ci_alpha, stats_alpha] = ttest2(alphaPowers_WT,alphaPowers_KO);
       test_alpha = 'ttest';
       mediana_alpha = median(alphaPowers,'omitnan');
       IQR_alpha = iqr(alphaPowers);
       effectSize_r2_alpha = stats_alpha.tstat^2/(stats_alpha.tstat^2+stats_alpha.df);
    else
       [pValue_alpha,different_alpha,stats_alpha] = ranksum(alphaPowers_WT,alphaPowers_KO);
       test_alpha = 'Mann Whitney';
       mediana_alpha = median(alphaPowers,'omitnan');
       IQR_alpha = iqr(alphaPowers);
       effectSize_r2_alpha = stats_alpha.zval^2/sum(lengths);
    end

    %-beta
    WT_normality_beta = adtest(betaPowers_WT);
    KO_normality_beta = adtest(betaPowers_KO);

    if WT_normality_beta == 1 && KO_normality_beta == 1
       [different_beta, pValue_beta, ci_beta, stats_beta] = ttest2(betaPowers_WT,betaPowers_KO);
       test_beta = 'ttest';
       mediana_beta = median(betaPowers,'omitnan');
       IQR_beta = iqr(betaPowers);
       effectSize_r2_beta = stats_beta.tstat^2/(stats_beta.tstat^2+stats_beta.df);
    else
       [pValue_beta,different_beta,stats_beta] = ranksum(betaPowers_WT,betaPowers_KO);
       test_beta = 'Mann Whitney';
       mediana_beta = median(betaPowers,'omitnan');
       IQR_beta = iqr(betaPowers);
       effectSize_r2_beta = stats_beta.zval^2/sum(lengths);
    end

    %-gamma
    WT_normality_gamma = adtest(gammaPowers_WT);
    KO_normality_gamma = adtest(gammaPowers_KO);

    if WT_normality_gamma == 1 && KO_normality_gamma == 1
       [different_gamma, pValue_gamma, ci_gamma, stats_gamma] = ttest2(gammaPowers_WT,gammaPowers_KO);
       test_gamma = 'ttest';
       mediana_gamma = median(gammaPowers,'omitnan');
       IQR_gamma = iqr(gammaPowers);
       effectSize_r2_gamma = stats_gamma.tstat^2/(stats_gamma.tstat^2+stats_gamma.df);
    else
       [pValue_gamma,different_gamma,stats_gamma] = ranksum(gammaPowers_WT,gammaPowers_KO);
       test_gamma = 'Mann Whitney';
       mediana_gamma = median(gammaPowers,'omitnan');
       IQR_gamma = iqr(gammaPowers);
       effectSize_r2_gamma = stats_gamma.zval^2/sum(lengths);
    end

    %-highGamma
    WT_normality_highgamma = adtest(highgammaPowers_WT);
    KO_normality_highgamma = adtest(highgammaPowers_KO);

    if WT_normality_highgamma == 1 && KO_normality_highgamma == 1
       [different_highgamma, pValue_highgamma, ci_highgamma, stats_highgamma] = ttest2(highgammaPowers_WT,highgammaPowers_KO);
       test_highgamma = 'ttest';
       mediana_highgamma = median(highgammaPowers,'omitnan');
       IQR_highgamma = iqr(highgammaPowers);
       effectSize_r2_highgamma = stats_highgamma.tstat^2/(stats_highgamma.tstat^2+stats_highgamma.df);
    else
       [pValue_highgamma,different_highgamma,stats_highgamma] = ranksum(highgammaPowers_WT,highgammaPowers_KO);
       test_highgamma = 'Mann Whitney';
       mediana_highgamma = median(highgammaPowers,'omitnan');
       IQR_highgamma = iqr(highgammaPowers);
       effectSize_r2_highgamma = stats_highgamma.zval^2/sum(lengths);
    end

    %-save figures
    savefig(ViolinPlot_dominantFr,[pathToSave '/dominantFrequency_' DIV])
    savefig(ViolinPlot_alphaP,[pathToSave '/alphaBandPower_' DIV])
    savefig(ViolinPlot_betaP,[pathToSave '/betaBandPower_' DIV])
    savefig(ViolinPlot_gammaP,[pathToSave '/gammaBandPower_' DIV])
    savefig(ViolinPlot_highgammaP,[pathToSave '/highgammaBandPower_' DIV])
    savefig(avg_PSD,[pathToSave '/avgPSD_' DIV])

    figure(ViolinPlot_dominantFr)
    print([pathToSave '/dominantFrequency_' DIV],'-dpng','-r300')
    figure(ViolinPlot_alphaP)
    print([pathToSave '/alphaBandPower_' DIV],'-dpng','-r300')
    figure(ViolinPlot_betaP)
    print([pathToSave '/betaBandPower_' DIV],'-dpng','-r300')
    figure(ViolinPlot_gammaP)
    print([pathToSave '/gammaBandPower_' DIV],'-dpng','-r300')
    figure(ViolinPlot_highgammaP)
    print([pathToSave '/highgammaBandPower_' DIV],'-dpng','-r300')
    figure(avg_PSD)
    print([pathToSave '/avgPSD_' DIV],'-dpng','-r300')


    %--put data into tables
    bandsPowers = table(alphaPowers,betaPowers,gammaPowers,highgammaPowers);
    writetable(bandsPowers,[pathToSave '/BandsPower_' DIV '.xlsx'])
    DominantFrequencies = array2table(dominantFrequencies,'VariableNames',Conditions);
    writetable(DominantFrequencies,[pathToSave '/DominantFrequencies_' DIV '.xlsx']);


    %-save statistics
    pValue = pValue_Fr;
    test = test_Fr;
    stats = stats_Fr;
    effectSize_r2 = effectSize_r2_Fr;
    mediana = mediana_Fr;
    IQR = IQR_Fr;
    save([pathToSave '/statistics_dominanFreq_' DIV '.mat'],"dominantFrequencies","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")

    pValue = pValue_alpha;
    test = test_alpha;
    stats = stats_alpha;
    effectSize_r2 = effectSize_r2_alpha;
    mediana = mediana_alpha;
    IQR = IQR_alpha;
    save([pathToSave '/statistics_alpha_' DIV '.mat'],"alphaPowers","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")

    pValue = pValue_beta;
    test = test_beta;
    stats = stats_beta;
    effectSize_r2 = effectSize_r2_beta;
    mediana = mediana_beta;
    IQR = IQR_beta;
    save([pathToSave '/statistics_beta_' DIV '.mat'],"betaPowers","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")

    pValue = pValue_gamma;
    test = test_gamma;
    stats = stats_gamma;    
    effectSize_r2 = effectSize_r2_gamma;
    mediana = mediana_gamma;
    IQR = IQR_gamma;
    save([pathToSave '/statistics_gamma_' DIV '.mat'],"gammaPowers","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")

    pValue = pValue_highgamma;
    test = test_highgamma;
    stats = stats_highgamma;    
    effectSize_r2 = effectSize_r2_highgamma;
    mediana = mediana_highgamma;
    IQR = IQR_highgamma;
    save([pathToSave '/statistics_highgamma_' DIV '.mat'],"highgammaPowers","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")


    close all

end
