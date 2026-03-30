

function NormSingleMaxRiseSlopes = NormMaxRiseSlopes(burstProfiles,binsize,save_dir,show)

    NormSingleMaxRiseSlopes = zeros(size(burstProfiles,1),1);
    
    for b = 1:size(burstProfiles,1)
    
        burst_profile = burstProfiles(b,:);
        %burst_profile = burst_profile((50/binsize):end);
        [peak_ampl, peak_idx] = max(burst_profile);
        burst_profile = burst_profile/peak_ampl;
        Burst_rise = burst_profile(1:peak_idx);
    
        RiseSlope_dt = diff(Burst_rise)/binsize;
        [maxSlope,maxSlope_idx] = max(RiseSlope_dt);

        if isempty(RiseSlope_dt) == 1
           NormSingleMaxRiseSlopes(b) = nan;
           continue
        end

        NormSingleMaxRiseSlopes(b) = maxSlope; 

        %-plot
        x_axis = (0:1:(peak_idx-1))*binsize;
    
        MaxSlopeFig = figure("Visible","off");

        if show == 1
           set(MaxSlopeFig, 'visible', 'on')
           set(MaxSlopeFig, 'WindowState', 'maximized')
        end

        subplot(2,1,1)
        plot(x_axis,burst_profile(1:peak_idx),'-','LineWidth',2,'color',[0.4 0.4 0.4])
        hold on
        plot([(maxSlope_idx)*binsize (maxSlope_idx)*binsize],[0 1],'r--')
        ax = gca;
        ax.TickDir = "out";
        ax.FontWeight = "bold";
        ax.FontSize = 12;
        set(gca,'TickLabelInterpreter', 'none');
        ylabel('Normalized Spike Rate','FontSize',14)
        xlabel('Time (ms)','FontSize',14)
        legend('Normalized burst','max Rising Slope','Location','northwest')

        subplot(2,1,2)
        plot(x_axis(2:end),RiseSlope_dt,'r-','LineWidth',2)
        ax = gca;
        ax.TickDir = "out";
        ax.FontWeight = "bold";
        ax.FontSize = 12;
        set(gca,'TickLabelInterpreter', 'none');
        ylabel('Slope (ms^-2)','FontSize',14)

        %set(MaxSlopeFig, 'visible', 'on')
        figname = ['RiseSlope_' sprintf('%d', b) '.fig'];
        savefig(MaxSlopeFig,[save_dir '/' figname])
    
        if show == 1
           pause
           disp('press any key to continue')
        end

        close(MaxSlopeFig) 


    end


end