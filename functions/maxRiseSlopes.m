

function singleMaxRiseSlopes = maxRiseSlopes(burstProfiles,binsize,save_dir,show)

    singleMaxRiseSlopes = zeros(size(burstProfiles,1),1);
    
    for b = 1:size(burstProfiles,1)
    
        burst_profile = burstProfiles(b,:);
        [peak_ampl, peak_idx] = max(burst_profile);
        burst_rise = burst_profile(1:peak_idx);
    
        RiseSlope_dt = diff(burst_rise)/binsize^2;    
        [maxSlope,maxSlope_idx] = max(RiseSlope_dt);

        if isempty(maxSlope) == 1
           maxSlope = nan;
        end
        
        singleMaxRiseSlopes(b) = maxSlope;

        %-plot
        x_axis = 0:binsize:(size(burstProfiles,2)-1)*binsize;
    
        MaxSlopeFig = figure("Visible","off");

        if show == 1
           set(MaxSlopeFig, 'visible', 'on')
           set(MaxSlopeFig, 'WindowState', 'maximized')
        end

        subplot(2,1,1)
        plot(x_axis,burst_profile,'-','LineWidth',2,'color',[0.4 0.4 0.4])
        hold on
        plot([maxSlope_idx*binsize maxSlope_idx*binsize],[0 peak_ampl],'r--')
        ax = gca;
        ax.TickDir = "out";
        ax.FontWeight = "bold";
        ax.FontSize = 12;
        set(gca,'TickLabelInterpreter', 'none');
        ylabel('# Spikes','FontSize',14)
        xlabel('Time (ms)','FontSize',14)
        legend('burst','max Rising Slope','Location','northeast')

        subplot(2,1,2)
        plot(RiseSlope_dt,'r-','LineWidth',2)
        ax = gca;
        ax.TickDir = "out";
        ax.FontWeight = "bold";
        ax.FontSize = 12;
        set(gca,'TickLabelInterpreter', 'none');
        ylabel('Slope (ms^-1)','FontSize',14)

        set(MaxSlopeFig, 'visible', 'on')
        figname = ['RiseSlope_' sprintf('%d', b) '.fig'];
        savefig(MaxSlopeFig,[save_dir '/' figname])
    
        if show == 1
           pause
           disp('press any key to continue')
        end
 

    end


end