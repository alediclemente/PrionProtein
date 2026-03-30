% Function to filter burst profiles with savitzky golay. Also plot and save the single burst and its "smoothed" version
% function with five arguments:
% 1) burstProfile - a matrix where each row is the spikecount of a burst
% 2) binsize - binsize used to generate the spikecount (in ms)
% 3) window - length (in ms) of the sliding window to use for the
% filtering. Order of the polynomial equation employed is then defined as
% round(window/3)
% 4) save_dir - path to the folder to save the figures
% 5) show - logical, single burst plot will be shown if == 1


function smoothedBursts = sgolaysmoothing(burstProfiles,binsize,sl_window,save_dir,show)

    sl_window = round(sl_window/binsize);
    if mod(sl_window, 2) == 0
        sl_window = sl_window + 1;
    end
    order = round(sl_window/5);
    smoothedBursts = sgolayfilt(burstProfiles',order,sl_window);
    smoothedBursts = smoothedBursts';
    
    for b = 1:size(burstProfiles,1)
    
        burst_profile = burstProfiles(b,:);
        smoothed_burst = smoothedBursts(b,:);
        x_axis = 0:binsize:(size(burstProfiles,2)-1)*binsize;
    
        smoothburst = figure("Visible","off");

        if show == 1
           set(smoothburst, 'visible', 'on')
           set(smoothburst, 'WindowState', 'maximized')
        end

        plot(x_axis,burst_profile,'-','LineWidth',2,'color',[0.4 0.4 0.4])
        hold on
        plot(x_axis,smoothed_burst,'r-','LineWidth',2)
        ax = gca;
        ax.TickDir = "out";
        ax.FontWeight = "bold";
        ax.FontSize = 12;
        set(gca,'TickLabelInterpreter', 'none');
        ylabel('# Spikes','FontSize',14)
        xlabel('Time (ms)','FontSize',14)
        legend('original burst','sgolay filtered burst','Location','northeast')

        %set(smoothburst, 'visible', 'on')
        figname = ['smoothBurst_' sprintf('%d', b) '.fig'];
        savefig(smoothburst,[save_dir '/' figname])
    
        if show == 1
           pause
           disp('press any key to continue')
        end

        %pause(0.5)
        close(smoothburst)
    
    end

end
