% Plot and save single bursts from single recording
% function with four arguments:
% 1) burstProfile - a matrix where each row is the spikecount of a burst
% 2) binsize - binsize used to generate the spikecount (in ms)
% 3) save_dir - path to the folder to save the figures
% 4) show - logical, single burst plot will be shown if == 1

function plotSingleBursts(burstProfiles, binsize, save_dir, show)

        for b = 1:size(burstProfiles,1)

            burst_profile = burstProfiles(b,:);
            x_axis = 0:binsize:(size(burstProfiles,2)-1)*binsize;

            singleburst = figure("Visible","off");
            if show == 1
                set(singleburst, 'visible', 'on')
            end
            plot(x_axis,burst_profile,'k-','LineWidth',2)
            figname = ['burst_' sprintf('%d', b) '.fig'];
            savefig(singleburst,[save_dir '/' figname], "compact")

            if show ==1
                pause
                disp('press any key to continue')
            end

            set(singleburst, 'visible', 'on')
            close(singleburst)

        end


end