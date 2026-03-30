%% Plot and statistics

clearvars('-except',"mainfolder")
close all;

CrossCorrfolder = [mainfolder '/CrossCorrelation'];

%-move to the main folder
cd(CrossCorrfolder)

%-create path to save
pathToSave = '../statistics_figures';
mkdir(pathToSave)

DIVs = dir([CrossCorrfolder '/results/*DIV*']);

for f = 1:numel(DIVs)

    DIV = DIVs(f).name;

    pathToData = [CrossCorrfolder '/results/' DIV];
        
    %-KO
    pathToKO = [pathToData '/KO/'];
    recordings_KO = dir([pathToKO '*.mat*']);
    Peaks_KO = [];
    N_peaks_KO = zeros(numel(recordings_KO),1);
    shifts_KO = [];

    for r = 1:numel(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToKO recname])

        N_peaks_KO(r) = height(peaks);
        Peaks_KO = [Peaks_KO; peaks.CrossCorrPeak];
        shifts_KO = [shifts_KO; abs(peaks.PeakShift_ms)];

    end

    clearvars("peaks")

    %-WT
    pathToWT = [pathToData '/WT/'];
    recordings_WT = dir([pathToWT '*.mat*']);
    Peaks_WT = [];
    N_peaks_WT = zeros(numel(recordings_WT),1);
    shifts_WT = [];

    for r = 1:numel(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToWT recname])

        N_peaks_WT(r) = height(peaks);
        Peaks_WT = [Peaks_WT; peaks.CrossCorrPeak];
        shifts_WT = [shifts_WT; abs(peaks.PeakShift_ms)];

    end

    clearvars("peaks")

    %-putting together peaks values
    lengths = [length(Peaks_KO) length(Peaks_WT)];
    max_length = max(lengths);
    Peaks_KO(end+1:max_length+1) = nan;
    Peaks_WT(end+1:max_length+1) = nan;
    Peaks_val = [Peaks_WT, Peaks_KO];

    %-putting together number of peaks
    lengths_Npeaks = [length(N_peaks_KO) length(N_peaks_WT)];
    max_length = max(lengths_Npeaks);
    N_peaks_KO(end+1:max_length+1) = nan;
    N_peaks_WT(end+1:max_length+1) = nan;
    N_peaks = [N_peaks_WT, N_peaks_KO];

    %-putting together peaks shifts
    lengths = [length(shifts_KO) length(shifts_WT)];
    max_length = max(lengths);
    shifts_KO(end+1:max_length+1) = nan;
    shifts_WT(end+1:max_length+1) = nan;
    shifts = [shifts_WT, shifts_KO];
    

    %-ViolinPlot of Peaks values
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    violinplot_Peaks = figure;
    violinplot_PeaksVal = violinplott(Peaks_val,Conditions,'ViolinColor',Colors);

    Q1 = quantile(Peaks_val,0.25);
    Q3 = quantile(Peaks_val,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on
    
    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ylabel('CrossCorrelation index')
    ax.Title.String = DIV;
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';

    %-Violinplot of number of peaks
    violinplot_NPeaks = figure;
    violinplot_NumberOfPeak = violinplott(N_peaks,Conditions,'ViolinColor',Colors);

    Q1 = quantile(N_peaks,0.25);
    Q3 = quantile(N_peaks,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on
    
    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ylabel('# Functional connections')
    ax.Title.String = DIV;
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';

    %- Violin plot of shifts values
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    violinplot_shifts = figure;
    violinplot_shiftsVal = violinplott(shifts,Conditions,'ViolinColor',Colors);

    Q1 = quantile(shifts,0.25);
    Q3 = quantile(shifts,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    ylim([0 uplim])
    hold on
    
    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ylabel('CrossCorrelation Peak shifts (ms)')
    ax.Title.String = DIV;
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';

    %-frequency histograms of shift values
    binranges = 0:3:max(shifts_WT);
    shiftHist_WT = histcounts(shifts_WT,binranges);
    shiftHist_WT = shiftHist_WT/sum(shiftHist_WT);
    shiftHist_KO = histcounts(shifts_KO,binranges);
    shiftHist_KO = shiftHist_KO/sum(shiftHist_KO);

    x_axis = binranges(1:end-1);
    x_axis(2:end) = log10(x_axis(2:end));

    shiftHist_plot = figure;
    plot(x_axis,shiftHist_WT,'b-','LineWidth',2)
    hold on
    plot(x_axis,shiftHist_KO,'r-','LineWidth',2)
    
    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTick = [0 log10(3) log10(10) log10(100) log10(300)];
    ax.XTickLabel = {'0','3','10','100','300'};
    ylabel('Relative Frequency')
    xlabel('Peak Shifts Absolute Values (Log Scale, ms)')
    ax.Title.String = DIV;
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
 
    %-statistics for peak values
    WT_Peaks_normality = adtest(Peaks_WT);
    KO_Peaks_normality = adtest(Peaks_KO);

    if WT_Peaks_normality == 1 && KO_Peaks_normality == 1
       [different_peaks, pValue_peaks, ci_peaks, stats_peaks] = ttest2(Peaks_WT,Peaks_KO);
       test_peaks = 'ttest';
       mediana_peaks = median(Peaks_val,'omitnan');
       IQR_peaks = iqr(Peaks_val);
       effectSize_r2_peaks = stats_peaks.tstat^2/(stats_peaks.tstat^2+stats_peaks.df);
    else
       [pValue_peaks,different_peaks,stats_peaks] = ranksum(Peaks_WT,Peaks_KO,'method','approximate');
       test_peaks = 'Mann Whitney';
       mediana_peaks = median(Peaks_val,'omitnan');
       IQR_peaks = iqr(Peaks_val);
       effectSize_r2_peaks = stats_peaks.zval^2/sum(lengths);
    end

    %-statistics for number of peaks
    % WT_NPeaks_normality = adtest(N_peaks_WT);
    % KO_NPeaks_normality = adtest(N_peaks_KO);
    % 
    % if WT_NPeaks_normality == 1 && KO_Peaks_normality == 1
    %    [different_Npeaks, pValue_Npeaks, ci_Npeaks, stats_Npeaks] = ttest2(N_peaks_WT,N_peaks_KO);
    %    test_Npeaks = 'ttest';
    %    mediana_Npeaks = median(N_peaks,'omitnan');
    %    IQR_Npeaks = iqr(N_peaks);
    %    effectSize_r2_Npeaks = stats_Npeaks.tstat^2/(stats_Npeaks.tstat^2+stats_Npeaks.df);
    % else
    %    [pValue_Npeaks,different_Npeaks,stats_Npeaks] = ranksum(N_peaks_WT,N_peaks_KO,'method','approximate');
    %    test_Npeaks = 'Mann Whitney';
    %    mediana_Npeaks = median(N_peaks,'omitnan');
    %    IQR_Npeaks = iqr(N_peaks);
    %    effectSize_r2_Npeaks = stats_Npeaks.zval^2/sum(lengths);
    % end

    %-statistics for peak shift values
    WT_shifts_normality = adtest(shifts_WT);
    KO_shifts_normality = adtest(shifts_KO);

    if WT_shifts_normality == 1 && KO_shifts_normality == 1
       [different_shifts, pValue_shifts, ci_shifts, stats_shifts] = ttest2(shifts_WT,shifts_KO);
       test_shifts = 'ttest';
       mediana_shifts = median(shifts,'omitnan');
       IQR_shifts = iqr(shifts);
       effectSize_r2_shifts = stats_shifts.tstat^2/(stats_shifts.tstat^2+stats_shifts.df);
    else
       [pValue_shifts,different_shifts,stats_shifts] = ranksum(shifts_WT,shifts_KO,'method','approximate');
       test_shifts = 'Mann Whitney';
       mediana_shifts = median(shifts_val,'omitnan');
       IQR_shifts = iqr(shifts_val);
       effectSize_r2_shifts = stats_shifts.zval^2/sum(lengths);
    end


    %--put things into tables
    Peaks_val = table(Peaks_WT,Peaks_KO);
    N_peaks = table(N_peaks_WT,N_peaks_KO);
    shifts_values = table(shifts_WT,shifts_KO);

    %-save figure peaks values
    figure(violinplot_Peaks)
    savefig(violinplot_Peaks,[pathToSave '/CrossCorValues_' DIV])
    print([pathToSave '/CrossCorValues_' DIV],'-dpng','-r300')
    close

    %-save figure number of peaks
    figure(violinplot_NPeaks)
    savefig(violinplot_NPeaks,[pathToSave '/N_CrossCorPeaks_' DIV])
    print([pathToSave '/N_CrossCorPeaks_' DIV],'-dpng','-r300')
    close

    %-save figure of shifts values
    figure(violinplot_shifts)
    savefig(violinplot_shifts,[pathToSave '/CrossCorShifts_' DIV])
    print([pathToSave '/CrossCorShifts_' DIV],'-dpng','-r300')
    close

    %-save figure of shift values histogram
    figure(shiftHist_plot)
    savefig(shiftHist_plot,[pathToSave '/ShiftsHistogram_' DIV])
    print([pathToSave '/ShiftsHistogram_' DIV],'-dpng','-r300')
    close

    %-save (all) statistics
    test = test_peaks;
    stats = stats_peaks;
    pValue = pValue_peaks;
    ci = ci_peaks;
    effectSize_r2 = effectSize_r2_peaks;
    mediana = mediana_peaks;
    IQR = IQR_peaks;
    save([pathToSave '/statistics_CrossCorrPeaksValues' DIV '.mat'],"Peaks_val","test",...
        "stats","pValue","ci","pathToData","CrossCorrfolder",...
        "effectSize_r2","mediana","IQR")
    
    % test = test_Npeaks;
    % stats = stats_Npeaks;
    % pValue = pValue_Npeaks;
    % effectSize_r2 = effectSize_r2_Npeaks;
    % mediana = mediana_Npeaks;
    % IQR = IQR_Npeaks;
    % save([pathToSave '/statistics_CrossCorrPeaksNumber' DIV '.mat'],"N_peaks","test",...
    %     "stats","pValue","pathToData","CrossCorrfolder",...
    %     "effectSize_r2","mediana","IQR")

    test = test_shifts;
    stats = stats_shifts;
    pValue = pValue_shifts;
    ci = ci_shifts;
    effectSize_r2 = effectSize_r2_shifts;
    mediana = mediana_shifts;
    IQR = IQR_shifts;
    save([pathToSave '/statistics_CrossCorrShifts' DIV '.mat'],"Peaks_val","test",...
        "stats","pValue","ci","pathToData","CrossCorrfolder",...
        "effectSize_r2","mediana","IQR")
    
    writetable(Peaks_val,[pathToSave '/CrossCorreValues_' DIV '.xlsx'])
    writetable(N_peaks,[pathToSave '/N_CrossCorrPeaks_' DIV '.xlsx'])
    writetable(shifts_values,[pathToSave '/CrossCorreShifts_' DIV '.xlsx'])

    close all

end

clearvars('-except',"mainfolder")
cd(mainfolder)

