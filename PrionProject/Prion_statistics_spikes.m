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

    artifactList = readtable("artifactList.xlsx");
        
    %-KO
    recordings_KO = dir([pathToData '*KO*']);
    spikes_inPerc_KO = zeros(length(recordings_KO),1);
    spikes_outPerc_KO = zeros(length(recordings_KO),1);
    spikes_tot_KO = zeros(length(recordings_KO),1);
    spikeRate_KO = zeros(length(recordings_KO),1);

    for r = 1:length(recordings_KO)

        recname = recordings_KO(r).name;
        load([pathToData recname '/results.mat'],"spikes","QSTinfo")
        spikes_inPerc_KO(r) = (spikes.NinBursts/spikes.Ntotal)*100;
        spikes_outPerc_KO(r) = (spikes.NoutBursts/spikes.Ntotal)*100;
        spikes_tot_KO(r) = spikes.Ntotal;

        artifacts_idx = strcmp(artifactList.recording_name,recname);

        if any(artifacts_idx)
            BadTime = sum(artifactList.end_ms) - sum(artifactList.start_ms);
            recduration_s = (QSTinfo.recDuration_ms - BadTime)/1000;
        else
            recduration_s = QSTinfo.recDuration_ms/1000;
        end

        spikeRate_KO(r) = spikes.Ntotal/(QSTinfo.NactiveElectrodes*recduration_s);


    end

    clearvars("spikes","spikes_inVSout_KO","QSTinfo")

    %-WT
    recordings_WT = dir([pathToData '*WT*']);
    spikes_inPerc_WT = zeros(length(recordings_WT),1);
    spikes_outPerc_WT = zeros(length(recordings_WT),1);
    spikes_tot_WT = zeros(length(recordings_WT),1);
    spikeRate_WT = zeros(length(recordings_WT),1);

    for r = 1:length(recordings_WT)

        recname = recordings_WT(r).name;
        load([pathToData recname '/results.mat'],"spikes","QSTinfo")
        spikes_inPerc_WT(r) = (spikes.NinBursts/spikes.Ntotal)*100;
        spikes_outPerc_WT(r) = (spikes.NoutBursts/spikes.Ntotal)*100;
        spikes_tot_WT(r) = spikes.Ntotal;
        
        artifacts_idx = strcmp(artifactList.recording_name,recname);

        if any(artifacts_idx)
            BadTime = sum(artifactList.end_ms) - sum(artifactList.start_ms);
            recduration_s = (QSTinfo.recDuration_ms - BadTime)/1000;
        else
            recduration_s = QSTinfo.recDuration_ms/1000;
        end

        spikeRate_WT(r) = spikes.Ntotal/(QSTinfo.NactiveElectrodes*recduration_s);

    end

    clearvars("spikes","spikes_inVSout_WT","QSTinfo")

    %% putting together

    %-inside bursts
    lengths = [length(spikes_inPerc_WT) length(spikes_inPerc_KO)];
    max_length = max(lengths);

    spikes_inPerc_WT(end+1:max_length+1) = nan;
    spikes_inPerc_KO(end+1:max_length+1) = nan;
    spikes_inPerc = [spikes_inPerc_WT, spikes_inPerc_KO];

    %--and outside
    spikes_outPerc_KO(end+1:max_length+1) = nan;
    spikes_outPerc_WT(end+1:max_length+1) = nan;
    spikes_outPerc = [spikes_outPerc_WT, spikes_outPerc_KO];

    %--and total number
    spikes_tot_WT(end+1:max_length+1) = nan;
    spikes_tot_KO(end+1:max_length+1) = nan;
    spikes_tot = [spikes_tot_WT, spikes_tot_KO];

    %--and spike rate
    spikeRate_WT(end+1:max_length+1) = nan;
    spikeRate_KO(end+1:max_length+1) = nan;
    spikeRate = [spikeRate_WT, spikeRate_KO];

    %% Plots
  
    % Violinplot percentage inside bursts
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    ViolinPlot_spikes_inPerc = figure;
    ViolinPlot_spikeinPERC = violinplott(spikes_inPerc,Conditions,'ViolinColor',Colors);

    Q1 = quantile(spikes_inPerc,0.25);
    Q3 = quantile(spikes_inPerc,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    bottomlim = min(Q1)-1.5*max(Q1_3);
    ylim([bottomlim uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['Percentage of spikes inside bursts ' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('% Spikes Inside Bursts')

    % Violin plot percentage outside bursts
    Conditions = {'WT', 'KO'};
    Colors = [0 0 1; 1 0 0];

    ViolinPlot_spikes_outPerc = figure;
    ViolinPlot_spikeoutPERC = violinplott(spikes_outPerc,Conditions,'ViolinColor',Colors);

    Q1 = quantile(spikes_outPerc,0.25);
    Q3 = quantile(spikes_outPerc,0.75);
    Q1_3 = Q3-Q1;
    uplim = max(Q3)+1.5*max(Q1_3);
    bottomlim = min(Q1)-1.5*max(Q1_3);
    ylim([bottomlim uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca,'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['Percentage of spikes outside bursts ' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('% Spikes Outside Bursts')

    %--Violin plot tot number of spikes
    ViolinPlot_spikes_tot = figure;
    violinplott(spikes_tot, Conditions, 'ViolinColor', Colors);
    
    Q1 = quantile(spikes_tot, 0.25);
    Q3 = quantile(spikes_tot, 0.75);
    Q1_3 = Q3 - Q1;
    uplim = max(Q3) + 1.5 * max(Q1_3);
    bottomlim = min(Q1) - 1.5 * max(Q1_3);
    ylim([bottomlim uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca, 'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['Total Number of Spikes ' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('# Spikes')

    %--Violin plot spike rate
    ViolinPlot_spikeRate = figure;
    violinplott(spikeRate, Conditions, 'ViolinColor', Colors);
    
    Q1 = quantile(spikeRate, 0.25);
    Q3 = quantile(spikeRate, 0.75);
    Q1_3 = Q3 - Q1;
    uplim = max(Q3) + 1.5 * max(Q1_3);
    bottomlim = min(Q1) - 1.5 * max(Q1_3);
    ylim([bottomlim uplim])
    hold on

    ax = gca;
    ax.Box = 'off';
    set(gca, 'TickLabelInterpreter', 'tex');
    ax.XTickLabel = Conditions;
    ax.Title.String = ['Spike Rate ' DIV];
    ax.TickDir = "out";
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ylabel('Spikes rate (Hz)')
    
    

    %% statistics

    % inside
    try
        WT_in_normality = adtest(spikes_inPerc_WT);
        KO_in_normality = adtest(spikes_inPerc_KO);
    
        if WT_in_normality == 1 && KO_in_normality == 1
           [different_in, pValue_in, ci_in, stats_in] = ttest2(spikes_inPerc_WT,spikes_inPerc_KO);
           test_in = 'ttest';
           mediana_in = median(spikes_inPerc,'omitnan');
           IQR_in = iqr(spikes_inPerc);
           effectSize_r2_in = stats_in.tstat^2/(stats_in.tstat^2+stats_in.df);
        else
           [pValue_in,different_in,stats_in] = ranksum(spikes_inPerc_WT,spikes_inPerc_KO,'method','approximate');
           test_in = 'Mann Whitney';
           mediana_in = median(spikes_inPerc,'omitnan');
           IQR_in = iqr(spikes_inPerc);
           effectSize_r2_in = stats_in.zval^2/sum(lengths);
        end
    catch
        WT_in_normality = nan;
        KO_in_normality = nan;
        different_in = nan;
        pValue_in = nan;
        ci_in = nan;
        stats_in = nan;
        test_in = 'none';
        mediana_in = nan;
        IQR_in = nan;
        effectSize_r2_in = nan;              
    end

    % and outside
    try
        WT_out_normality = adtest(spikes_outPerc_WT);
        KO_out_normality = adtest(spikes_outPerc_KO);
    
        if WT_out_normality == 1 && KO_out_normality == 1
           [different_out, pValue_out, ci_out, stats_out] = ttest2(spikes_outPerc_WT,spikes_outPerc_KO);
           test_out = 'ttest';
           mediana_out = median(spikes_outPerc,'omitnan');
           IQR_out = iqr(spikes_outPerc);
           effectSize_r2_out = stats_out.tstat^2/(stats_out.tstat^2+stats_out.df);
        else
           [pValue_out,different_out,stats_out] = ranksum(spikes_outPerc_WT,spikes_outPerc_KO,'method','approximate');
           test_out = 'Mann Whitney';
           mediana_out = median(spikes_outPerc,'omitnan');
           IQR_out = iqr(spikes_outPerc);
           effectSize_r2_out = stats_out.zval^2/sum(lengths);
        end
    catch
        WT_out_normality = nan;
        KO_out_normality = nan;
        different_out = nan;
        pValue_out = nan;
        ci_out = nan;
        stats_out = nan;
        test_out = 'none';
        mediana_out = nan;
        IQR_out = nan;
        effectSize_r2_out = nan;              
    end

    % and total number of spikes
    try
        WT_tot_normality = adtest(spikes_tot_WT);
        KO_tot_normality = adtest(spikes_tot_KO);
    
        if WT_tot_normality == 1 && KO_tot_normality == 1
           [different_tot, pValue_tot, ci_tot, stats_tot] = ttest2(spikes_tot_WT,spikes_tot_KO);
           test_tot = 'ttest';
           mediana_tot = median(spikes_tot,'omitnan');
           IQR_tot = iqr(spikes_tot);
           effectSize_r2_tot = stats_tot.tstat^2/(stats_tot.tstat^2+stats_tot.df);
        else
           [pValue_tot,different_tot,stats_tot] = ranksum(spikes_tot_WT,spikes_tot_KO,'method','approximate');
           test_tot = 'Mann Whitney';
           mediana_tot = median(spikes_tot,'omitnan');
           IQR_tot = iqr(spikes_tot);
           effectSize_r2_tot = stats_tot.zval^2/sum(lengths);
        end
    catch
        WT_tot_normality = nan;
        KO_tot_normality = nan;
        different_tot = nan;
        pValue_tot = nan;
        ci_tot = nan;
        stats_tot = nan;
        test_tot = 'none';
        mediana_tot = nan;
        IQR_tot = nan;
        effectSize_r2_tot = nan;              
    end

    %--and spike rate
    try
        WT_rate_normality = adtest(spikesRate_WT);
        KO_rate_normality = adtest(spikesRate_KO);
    
        if WT_rate_normality == 1 && KO_rate_normality == 1
           [different_rate, pValue_rate, ci_rate, stats_rate] = ttest2(spikeRate_WT,spikeRate_KO);
           test_rate = 'ttest';
           mediana_rate = median(spikesRate,'omitnan');
           IQR_rate = iqr(spikesRate);
           effectSize_r2_rate = stats_rate.tstat^2/(stats_rate.tstat^2+stats_rate.df);
        else
           [pValue_rate,different_rate,stats_rate] = ranksum(spikeRate_WT,spikeRate_KO,'method','approximate');
           test_rate = 'Mann Whitney';
           mediana_rate = median(spikeRate,'omitnan');
           IQR_rate = iqr(spikeRate);
           effectSize_r2_rate = stats_rate.zval^2/sum(lengths);
        end
    catch
        WT_rate_normality = nan;
        KO_rate_normality = nan;
        different_rate = nan;
        pValue_rate = nan;
        ci_rate = nan;
        stats_rate = nan;
        test_rate = 'none';
        mediana_rate = nan;
        IQR_rate = nan;
        effectSize_r2_rate = nan;              
    end


    %% saving stuff
    
    %--put spikes results into tables
    spikes_inPerc = table(spikes_inPerc_WT,spikes_inPerc_KO);
    spikes_outPerc = table(spikes_outPerc_WT,spikes_outPerc_KO);
    spikes_tot = table(spikes_tot_WT,spikes_tot_KO);
    spikeRate = table(spikeRate_WT,spikeRate_KO);

    %-save figure percentage in
    figure(ViolinPlot_spikes_inPerc)
    savefig(ViolinPlot_spikes_inPerc,[pathToSave '/SpikesInPerc_' DIV])
    print([pathToSave '/SpikesInPerc_' DIV],'-dpng','-r300')
    close

    %-save figure percentage out Bursts
    figure(ViolinPlot_spikes_outPerc)
    savefig(ViolinPlot_spikes_outPerc,[pathToSave '/SpikesOutPerc_' DIV])
    print([pathToSave '/SpikesOutPerc_' DIV],'-dpng','-r300')
    close

    %-save figure tot number of spikes
    figure(ViolinPlot_spikes_tot)
    savefig(ViolinPlot_spikes_tot,[pathToSave '/SpikeTot_' DIV])
    print([pathToSave '/SpikesTot_' DIV],'-dpng','-r300')
    close

    %-save figure spike rate
    figure(ViolinPlot_spikeRate)
    savefig(ViolinPlot_spikeRate,[pathToSave '/SpikeRate_' DIV])
    print([pathToSave '/SpikesRate_' DIV],'-dpng','-r300')
    close

    %-save (all) statistics
    test = test_in;
    pValue = pValue_in;
    stats = stats_in;
    effectSize_r2 = effectSize_r2_in;
    mediana = mediana_in;
    IQR = IQR_in;
    save([pathToSave '/statistics_SpikesIN' DIV '.mat'],"spikes_inPerc","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")

    test = test_out;
    pValue = pValue_out;
    stats = stats_out;
    effectSize_r2 = effectSize_r2_out;
    mediana = mediana_out;
    IQR = IQR_out;
    save([pathToSave '/statistics_SpikesOUT' DIV '.mat'],"spikes_outPerc","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")

    test = test_tot;
    pValue = pValue_tot;
    stats = stats_tot;
    effectSize_r2 = effectSize_r2_tot;
    mediana = mediana_tot;
    IQR = IQR_tot;
    save([pathToSave '/statistics_SpikesTot' DIV '.mat'],"spikes_tot","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")

    test = test_rate;
    pValue = pValue_rate;
    stats = stats_rate;
    effectSize_r2 = effectSize_r2_rate;
    mediana = mediana_rate;
    IQR = IQR_rate;
    save([pathToSave '/statistics_SpikeRate' DIV '.mat'],"spikeRate","pValue","test","stats",...
        "effectSize_r2","mediana","IQR")
    


    %-save statistics
    writetable(spikes_inPerc,[pathToSave '/statistics_SpikesIN' DIV '.xlsx'])
    writetable(spikes_outPerc,[pathToSave '/statistics_SpikesOUT' DIV '.xlsx'])
    writetable(spikes_tot,[pathToSave '/statistics_SpikesTot' DIV '.xlsx'])
    writetable(spikeRate,[pathToSave '/statistics_SpikeRate' DIV '.xlsx'])

end

