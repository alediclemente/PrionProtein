
%-- Simple function to store spiketimes from .txt files to 
%-- arrays in a .mat file (one for each recording)
%-- The "path" arguments must be the path to the folder
%-- which contains the subfolders, one for each recordings,
%-- with the .txt files of the spiketimes. Output files are saved
%-- to the folder "spiketimes", two level above the current folder

function txt2mat(path)

    whereIgoBack = pwd();
    cd(path)

    folders = dir;

    for i = 1:length(folders)
    
        rec_name = folders(i).name;
        disp(rec_name)
        shouldIskip = isfolder(rec_name) == 0 | strcmp(rec_name, '..')...
            | strcmp(rec_name, '.');

        if shouldIskip == 1
            continue
        end

        try
            infofiles = dir([folders(i).name '/*info.txt']);
            infotxt = importdata([folders(i).name '/' infofiles(1).name]);
        catch
            infotxt = [1800000; 45000000; 25000];
        end

        try
            QSTactivity = readtable([folders(i).name '/info_activityQST.txt']);
        catch
            Var1 = {'Number of Active Electrodes'; ...
            'Number of Spikes'; ...
            'Number of Bursts'; ...
            'Mean Burst Duration'; ...
            'Standard Deviation of Burst Duration'; ...
            'Mean Inter-Burst-Interval (IBI)'; ...
            'Standard Deviation of IBI'};
            Var2 = nan(7,1);
            QSTactivity = table(Var1,Var2);
        end

        QSTinfo.recDuration_ms = infotxt(1);
        QSTinfo.datapoints = infotxt(2);
        QSTinfo.samplingRate = infotxt(3);
        QSTinfo.NactiveElectrodes = QSTactivity.Var2(1);
        QSTinfo.Nbursts = QSTactivity.Var2(3);
        QSTinfo.MeanBurstDuration_ms = QSTactivity.Var2(4);
        QSTinfo.StdBurstDuration_ms = QSTactivity.Var2(5);
        QSTinfo.meanIBI_ms = QSTactivity.Var2(6);
        QSTinfo.StdIBI_ms = QSTactivity.Var2(7);

        electrodes = dir([folders(i).name '/*spikes.txt']);
        activeElec = 0;
        
        for k = 1:length(electrodes)
        
           filename = electrodes(k).name;
           disp(['loading ' filename])
           load([folders(i).name '/' filename]);

           elname = erase(filename, '.txt');
           nspikes = numel(eval(elname));

           if nspikes > 36
               activeElec = activeElec+1;
           end
        
        end

        QSTinfo.NactiveElectrodes = activeElec;

        whereIam = pwd;
        slashes = strfind(whereIam,'/');
    
        whereIsave = whereIam(1:slashes(end-1));

        mkdir([whereIsave 'spiketimes'])
    
        disp(['saving ' rec_name])
        clearvars('ans','i','k','infotxt','infofiles','QSTactivity','shouldIskip','slashes')
        save([whereIsave 'spiketimes/' rec_name '.mat'])
           
    end

    cd(whereIgoBack)

end

