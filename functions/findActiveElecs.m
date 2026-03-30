
%Function to find and select most active electrodes. Works with .mat
% files coming from txt2mat function. Input arguments are: 1)file = the filename
% (fullpath to the file works as well); 2) quant = the quantile used as threshold to
% select the most active electrodes (e.g. if quant is 0.9 the function will
% list 12 most active electrodes (10% of 120)

function mostActiveElecs = findActiveElecs(file, quant)

    load(file)

    spikeXelec = zeros(length(electrodes),1);
    electrodenames = cell(length(electrodes),1);

    for i = 1:length(electrodes)

        elecname = electrodes(i).name;
        elecname = strsplit(elecname,'.');
        elecname = cell2mat(elecname(1));
        
        spikeXelec(i) = length(eval(elecname));
        electrodenames{i} = elecname;
        
    end

    activityThreshold = quantile(spikeXelec, quant);

    mostActiveElecs = electrodenames(spikeXelec >= activityThreshold);

end
