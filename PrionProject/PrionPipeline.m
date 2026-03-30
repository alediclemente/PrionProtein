%% Analysis pipeline for Prion protein knocout project

%Here maybe a comment with the steps of the entire pipeline

%% Set mainfolder for analysis

clear; clc; close all;

h = msgbox('Select main folder for analysis','Instructions','modal');
uiwait(h);
mainfolder = uigetdir('title');
cd(mainfolder)

%% Convert timestamps in txt
disp('converting timestamps from jld2 to txt')

DIVs = dir('*DIV*');

juliaExe   = '/Users/alessio/.juliaup/bin/julia';  % or full path to Julia executable
juliaScript = '/Users/alessio/Library/CloudStorage/OneDrive-SISSA/JULIA/jdl2_to_txt.jl';

for f = 1:length(DIVs)

    DIV = DIVs(f).name;
    pathToDIV = [mainfolder '/' DIV];

    genotype = [dir([pathToDIV '/*WT*']); dir([pathToDIV '/*KO*'])];

    for g = 1:length(genotype)

        pathToConversion = [pathToDIV '/' genotype(g).name];

        cmd = sprintf('"%s" "%s" "%s"', juliaExe, juliaScript, pathToConversion);
        [status, out] = system(cmd);

        disp(out)

        if status ~= 0
            error('Julia script failed for folder: %s', pathToConversion);
        end

    end

end

%% Clean timestamps from artifacts

clearvars('-except',"mainfolder")

close all;

cd(mainfolder)

disp('cleaning spikes timestamps from artifacts')

DIVs = dir('*DIV*');
h = msgbox('Select artifact list file','Instructions','modal');
uiwait(h);
artifactList = readtable(uigetfile('*.xlsx'));

for f = 1:length(DIVs)

    DIV = (DIVs(f).name);

    conditions = dir([DIV '/']);

    for c = 1:length(conditions)

        iscondition = strcmp(conditions(c).name, 'WT') | strcmp(conditions(c).name, 'KO');

        if iscondition == 0
            continue
        end

        pathToSpikes = [conditions(c).folder '/' conditions(c).name '/OUTPUT_PREPROCESSED_TXT'];

        recordings = dir([pathToSpikes '/*DIV*']);

        for r = 1:length(recordings)

            recname = recordings(r).name;

            artifacts_idx = strcmp(artifactList.recording_name,recname);

            if ~any(artifacts_idx)
                continue
            end

            badTimeIntervals = artifactList(artifacts_idx,:);
            spikesfiles = dir([recordings(r).folder '/' recname '/*spikes.txt']);

            for j = 1:length(spikesfiles)
                
                pathToFile = fullfile(spikesfiles(j).folder,spikesfiles(j).name);
                spikeTimes = readmatrix(pathToFile);

                keepMask = true(size(spikeTimes));

                for k = 1:height(badTimeIntervals)
                    keepMask = keepMask & ~(spikeTimes > badTimeIntervals.start_ms(k) & ...
                        spikeTimes < badTimeIntervals.end_ms(k));
                end

                spikeTimesClean = spikeTimes(keepMask);
                writematrix(spikeTimesClean, pathToFile, 'Delimiter', 'tab');

            end

        end

    end

end

clearvars('-except',"mainfolder")

clc; close all;


%% convert timestamps in .mat files, 1 file for each recording.

clearvars('-except',"mainfolder")

close all;

cd(mainfolder)

disp('importing spikes timestamps')

DIVs = dir('*DIV*');

for f = 1:length(DIVs)

    DIV = (DIVs(f).name);

    conditions = dir([DIV '/']);

    for c = 1:length(conditions)

        iscondition = strcmp(conditions(c).name, 'WT') | strcmp(conditions(c).name, 'KO');

        if iscondition == 0
            continue
        end
        
        path = [conditions(c).folder '/' conditions(c).name '/OUTPUT_PREPROCESSED_TXT'];
        txt2mat(path)

    end

end

clearvars('-except',"mainfolder")

clc; close all;


%% Detect and do a quick fist hand charactrization of bursts. Plot rasterplot, STH

Prion_BurstDetection


%% Burst analysis - burst profiling+mean burst, burst smoothing (savitzky-golay), rising slope of each burst

Prion_BurstAnalysis


%% Reverberation analysis on each single bursts with STFT and CWT techniques

%Prion_BurstReverberation

%% Reverberation analysis on the average bursts with STFT and CWT techniques

%Prion_ReverberationMeanBurst


%% statistics/Number of bursts

disp('Number of bursts')

Prion_statistics_Nbursts


%% Statistics/Burst duration

disp('Burst duration')

Prion_statistics_burstDuration

%% Statistics/Burst Amplitude

disp('Burst Amplitude')

Prion_statistics_burstAmplitudes

%% Statistics/Spikes outside bursts VS inside bursts

disp('percentage of spikes inside and outside bursts')

Prion_statistics_spikes

%% Statistics/Number of active electrodes

disp('Number of active electrodes')

Prion_statistics_ActiveElec

%% Statistics/Max rise slope

disp('burst max rising slope')

%-on the average burst of each recording
%Prion_statistics_maxRiseSlope_avgBurst

%-on each burst
Prion_statistics_maxRiseSlope_singleBursts


%% Statistics/Average burst profile

disp('Average burst profiles')

Prion_statistics_meanBurst

%% Statistics/time to peak

disp('Time To Burst Peak')

Prion_statistics_TimeToPeak

%% Statistics/IBI

disp('Inter Burst Intervals')

Prion_statistics_IBIs

%% Statistics/Cross Correlation

disp('CrossCorrelation')

OrganizeDataCrossCorr

Prion_statistics_CrossCorr


%% Organize statistics_figure folder
clearvars('-except',"mainfolder")
close all

pathToOrganize = [mainfolder '/statistics_figures/'];

mkdir([pathToOrganize '/graphs_png'])
mkdir([pathToOrganize '/graphs_fig'])
mkdir([pathToOrganize '/excel_tables'])
mkdir([pathToOrganize '/mat_files'])

movefile([pathToOrganize '*.png'],[pathToOrganize '/graphs_png'])
movefile([pathToOrganize '*.fig'],[pathToOrganize '/graphs_fig'])
movefile([pathToOrganize '*.xlsx'],[pathToOrganize '/excel_tables'])
movefile([pathToOrganize '*.mat'],[pathToOrganize '/mat_files'])





