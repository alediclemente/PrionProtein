%% Import and organize data for Cross Correlation Analysis for Pion Project
%First saved on 14/08/2025

clearvars('-except',"mainfolder"); close all;

cd(mainfolder)
CrossCorrFolder = [mainfolder '/CrossCorrelation'];
cd(CrossCorrFolder)

%% create a List of failed jobs

failedJobsList = ListFailedJobs([CrossCorrFolder '/OUTPUT_FILES']);
writetable(failedJobsList,'ListOfFailedJobs.xlsx')

%% Remove all the non-failed jobs from the ToUpload Foder, remove the failed one from the output files

%--from upload folder (remove non-failed)
keeplist = string(failedJobsList.recording);

ToUploadFolder = '/Users/alessio/ToUpload';

allfolders = dir([ToUploadFolder '/*DIV*']);

for k = 1:numel(allfolders)

    if ~ismember(allfolders(k).name, keeplist)
       rmdir(fullfile(ToUploadFolder, allfolders(k).name), 's');
       fprintf('Deleted from UPLOAD folder: %s\n', allfolders(k).name);
    else
       fprintf('Kept in UPLOAD folder: %s\n', allfolders(k).name);
    end

end

%--from OUTPUT_FILES (remove failed ones)
deleteList = keeplist;

ToOUTPUT_FILES = [mainfolder '/OUTPUT_FILES'];

allfolders = dir([ToOUTPUT_FILES '/*DIV*']);

for k = 1:numel(allfolders)

    if ismember([allfolders(k).name '.dat'], deleteList)
       rmdir(fullfile(ToOUTPUT_FILES, allfolders(k).name), 's');
       fprintf('Deleted from OUTPUT folder: %s\n', allfolders(k).name);
    else
       fprintf('Kept in OUTPUT folder: %s\n', allfolders(k).name);
    end

end




%% Reorganizing and import in MATLAB

clearvars -except mainfolder CrossCorrFolder
close all

%--Import in Matlab and save to 'results'
cd(CrossCorrFolder)

OutputFilesPath = [CrossCorrFolder '/OUTPUT_FILES/'];
resultsPath = [CrossCorrFolder '/results/'];
mkdir(resultsPath)

allrecs = dir([OutputFilesPath '*DIV*']);

for i = 1:numel(allrecs)

    recname = allrecs(i).name;
    peaks = readtable([OutputFilesPath recname '/peaks.txt']);
    peaks.Properties.VariableNames = {'ChanA','ChanB','CrossCorrPeak','PeakIdx','PeakShift_ms'};
    save([resultsPath recname],"peaks")

end

%--Organize by DIV
mkdir([resultsPath 'DIV10'])
mkdir([resultsPath 'DIV17'])
mkdir([resultsPath 'DIV23'])

try
    movefile([resultsPath '*DIV10*'],[resultsPath 'DIV10'])
catch
end

try
    movefile([resultsPath '*DIV17*'],[resultsPath 'DIV17'])
catch
end

try
    movefile([resultsPath '*DIV14*'],[resultsPath 'DIV17'])
catch 
end

try 
    movefile([resultsPath '*DIV23*'],[resultsPath 'DIV23'])
catch
end
try 
    movefile([resultsPath '*DIV22*'],[resultsPath 'DIV23'])
catch
end
try
    movefile([resultsPath '*DIV24*'],[resultsPath 'DIV23'])
catch
end

%--Organize KO e WT
DIVs = dir([resultsPath '*DIV*']);

for j = 1:numel(DIVs)

    DIV = DIVs(j).name;
    pathToDIV = [resultsPath DIV '/'];

    mkdir([pathToDIV 'KO'])
    mkdir([pathToDIV 'WT'])

    movefile([pathToDIV '*_KO_*'],[pathToDIV 'KO'])
    movefile([pathToDIV '*_WT_*'],[pathToDIV 'WT'])

end
