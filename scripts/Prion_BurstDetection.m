%% Plot ratserplots and STH, bursdetection

clearvars('-except',"mainfolder")

clc; close all;

disp('Plot ratserplots and STH, perform burst detection')

%-move to the main folder
cd(mainfolder)
DIVs = dir('*DIV*');

for fld = 1: length(DIVs)

    %-navigate to the folder
    cd(DIVs(fld).name)
    disp(DIVs(fld).name)
    cd spiketimes

    %-list recordings
    recordings = dir('*.mat');

    %- analysis
    for r = 1:length(recordings)
        
        recname = recordings(r).name;
        recname = strsplit(recname,'.');
        recname = cell2mat(recname(1));
        pathToSaveDATA = ['../RESULTS/' recname];
        pathToSaveFigs = [mainfolder '/statistics_figures'];
        mkdir(pathToSaveDATA)
        mkdir(pathToSaveFigs)

        disp(recname)

        load(recname, "QSTinfo")
        
        %- rasterplot
        rasterData = rasterplot(recname,0);
        raster = gcf;
        hold on      
        
        %- STH
        binsize = 5;
        [spikeHistogram, binsize, allspks] = spikehist(recname, binsize, QSTinfo.recDuration_ms,0);
        save(recname,"allspks","-append")
        STH = gcf;
        hold on
        
        %- burst detection
        absThr = 0.15;
        minThr = 0.015;
        waiTime_ms = 50;
        minBurstDuration_ms = 25;
        bursts = burstDetection(spikeHistogram, binsize, QSTinfo.NactiveElectrodes, minThr, waiTime_ms, minBurstDuration_ms, absThr);

        %- enrich raster and STH with bursts starts and ends (if there's
        %any)

        if istable(bursts) == 1

            figure(raster)
            set(raster, 'visible', 'off')
            hold on
    
            for b = 1 : height(bursts)
    
                plot([bursts.burst_start_ms(b)/1000 bursts.burst_start_ms(b)/1000], ...
                    [0 120], 'g-','LineWidth',2)
                plot([bursts.burst_end_ms(b)/1000 bursts.burst_end_ms(b)/1000], ...
                    [0 120], 'r-','LineWidth',2)
            
            end
    
            set(raster, 'visible', 'on')
                
            figure(STH)
            set(STH, 'visible', 'off')
            hold on
            plot([0 QSTinfo.recDuration_ms/100],[absThr*QSTinfo.NactiveElectrodes ...
                absThr*QSTinfo.NactiveElectrodes],'r--')
            plot([0 QSTinfo.recDuration_ms/100],[minThr*QSTinfo.NactiveElectrodes ...
                minThr*QSTinfo.NactiveElectrodes],'g--')
            
            
            for bb = 1:height(bursts)
    
                plot([bursts.burst_start_ms(bb)/1000 bursts.burst_start_ms(bb)/1000], ...
                    [0 QSTinfo.NactiveElectrodes], 'g-','LineWidth',2)
                plot([bursts.burst_end_ms(bb)/1000 bursts.burst_end_ms(bb)/1000], ...
                    [0 QSTinfo.NactiveElectrodes], 'r-','LineWidth',2)
    
            end
    
            set(STH, 'visible', 'on')

        end
        %pause

        %-save and close figures and burst detection parameters
        mkdir([pathToSaveFigs '/rasters'])
        mkdir([pathToSaveFigs '/spikehistograms'])
      
        rasterfigname = [recname '_raster.fig'];
        savefig(raster,[pathToSaveFigs '/rasters/' rasterfigname])
        STHfigname = [recname '_STH.fig'];
        savefig(STH, [pathToSaveFigs '/spikehistograms/' STHfigname]) 
        
        savefig(raster,[pathToSaveDATA '/raster'])      
        savefig(STH, [pathToSaveDATA '/STH'])

        BurstDetectionParameters = table(binsize,absThr,minThr,waiTime_ms,minBurstDuration_ms);
        writetable(BurstDetectionParameters,[pathToSaveFigs '/BurstDetectionParameters.xlsx'])

        close all

        %-spikes in bursts VS spikes outside
        if istable(bursts) == 1
            burst_start = bursts.burst_start_idx;
            burst_end = bursts.burst_end_idx;
        else
            burst_start = [];
            burst_end = [];
        end
            [spikesINbursts, spikesOUTbursts, ratio_inVSout] = burstVSrandomSpikes(spikeHistogram, burst_start, burst_end);
            spikes.Ntotal = spikesINbursts+spikesOUTbursts;
            spikes.NinBursts = spikesINbursts;
            spikes.NoutBursts = spikesOUTbursts;
            spikes.ratioInVsOut = ratio_inVSout;

        save([pathToSaveDATA '/results'],"spikeHistogram","recname", "QSTinfo","bursts","spikes", "binsize","allspks")
        

    end

    cd(mainfolder)

end

clearvars('-except',"mainfolder")

close all;
