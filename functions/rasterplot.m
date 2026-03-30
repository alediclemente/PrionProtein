
%-- plot RASTERPLOTS. Function with 1 single argument which is the filename
%of the recording to plot (fullpath to the file works too). 
%for the function to work the 
%file needs to be a .mat file with inside vectors of spiketimes for each electrode

function rasterData = rasterplot(file,show)

    load(file)

    if show == 1
        raster = figure;
    elseif show == 0
        raster = figure("Visible","off");
    end

    yelectrodes = cell(length(electrodes),1);
    rasterData = cell(length(electrodes),3);

    recDuration_s = QSTinfo.recDuration_ms/1000;

    for i = 1:length(electrodes)

            elecname = electrodes(i).name;
            elecname = strsplit(elecname,'.');
            elecname = cell2mat(elecname(1));
           
            try
                yvalue = repmat(i,length(eval(elecname)),1);
                yelectrode = elecname(1:2);
            catch
                elecname = ['X' elecname];
                yvalue = repmat(i,length(eval(elecname)),1);
                yelectrode = elecname(1:3);
            end

            yelectrodes{i} = yelectrode;

            plot(eval(elecname)./1000,yvalue,'.k')
            hold on

            rasterData{i,1} = yelectrode;
            rasterData{i,2} = eval(elecname);
            rasterData{i,3} = yvalue;

    end

    ax = gca;
    ax.TickDir = "none";
    ax.FontWeight = "bold";
    ax.FontSize = 8;
    set(gca,'TickLabelInterpreter', 'none');

    xlim([0 recDuration_s]) 
    yticks(linspace(1,120,120))
    yticklabels(yelectrodes)
    ylabel('Electrode','FontSize',14)
    xlabel('seconds','FontSize',14)
    title(file,'Interpreter','none','FontSize',16)

    if show == 1
        disp('press a key to coninue')
        pause
    end

    %savefig(raster,[file '.fig'])


end
