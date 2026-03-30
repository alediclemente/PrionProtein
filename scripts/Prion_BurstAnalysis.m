%% Burst analysis

clearvars('-except',"mainfolder")

close all;

disp('performing burst analysis')

%-move to the main folder
cd(mainfolder)

pathToSaveFigs = [mainfolder '/statistics_figures'];

DIVs = dir('*DIV*');

for f = 1:length(DIVs)

    DIV = DIVs(f).name;
    disp(DIV)
    pathToData = [DIV '/RESULTS'];

    %-list recordings
    recordings = dir([pathToData '/*DIV*']);

    %- analysis for each recording
    for r = 1:length(recordings)

        recname = recordings(r).name;
        disp(recname)

        load([pathToData '/' recname '/results.mat'])

        if istable(bursts) == 1
  
            [burstProfiles, ~, mean_burst] = burstProfiling(allspks,bursts,5,'start',0);
            burstplot = gcf;
            title(recname,'Interpreter','none','FontSize',16)
            savefig([pathToData '/' recname '/burstsplot'])

            mkdir([pathToSaveFigs '/BurstPlots'])
            burstFigname = [recname '_bursts5.fig'];
            savefig([pathToSaveFigs '/BurstPlots/' burstFigname])
            close(burstplot)

            %-burst smoothing
            smoothedBursts_dir = [pathToData '/' recname '/smoothedBursts'];
            mkdir(smoothedBursts_dir)

            smoothed_bursts = sgolaysmoothing(burstProfiles,binsize,51,smoothedBursts_dir,0);

            %-maxriseslope of each burst
            NormSingleMaxRiseSlopes = NormMaxRiseSlopes(smoothed_bursts,binsize,smoothedBursts_dir,0);

            %-burst rising slope on the mean burst aligned at burst start
            burst_dt = diff(mean_burst)/binsize^2; %- Like this is rate of change of spikes/time. If I want rate of change of spike rate/time is binsize^2
            maxRiseSlope = max(burst_dt);

            %-save stuff
            save([pathToData '/' recname '/results.mat'],"burstProfiles","mean_burst","maxRiseSlope","NormSingleMaxRiseSlopes","-append")
        end
        
    end

    cd(mainfolder)

end

clearvars('-except',"mainfolder")
close all;
