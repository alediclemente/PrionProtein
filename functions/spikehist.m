%-- Plot STH. Function with 3 arguments: 
% 1) file is the filename of the recording to plot (fullpath can work too), for the function to work the 
%file needs to be a .mat file with inside vectors of spiketimes for each electrode,
% 2) binsize is the size of the bins for the spiketime histogram in milliseconds
% 3) recDuration_ms is the duration of the recording in ms
% The function returns the spike time instogram, the binsize used and plot and save the
% corresponding figure 


function [spikecount, binsize, allspks] = spikehist(file, binsize, recDuration_ms, show)

    load(file)
    allspks = [];
    binsize = binsize;

    for i = 1:length(electrodes)

            elecname = electrodes(i).name;
            elecname = strsplit(elecname,'.');
            elecname = cell2mat(elecname(1));
            
            try
                allspks = vertcat(allspks, eval(elecname));
            catch
                elecname = ['X' elecname];
                allspks = vertcat(allspks, eval(elecname));
            end
            
    end

    edges = 0:binsize:recDuration_ms;
    spikecount = histcounts(allspks,edges);
    
    leftedges_seconds = edges(1:end-1)/1000;
    
    if show == 1
        STH = figure;
    elseif show == 0
        STH = figure("Visible","off");
    end
    plot(leftedges_seconds,spikecount,'-k')
    
    ax = gca;
    ax.TickDir = "out";
    ax.FontWeight = "bold";
    ax.FontSize = 12;
    set(gca,'TickLabelInterpreter', 'none');
    ylabel('# Spikes','FontSize',14)
    xlabel('seconds','FontSize',14)
    xlim([0 recDuration_ms/1000])
    title(file,'Interpreter','none','FontSize',16)

    if show == 1
        disp('press a key to coninue')
        pause
    end
    

end