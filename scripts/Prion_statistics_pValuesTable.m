
clear; close all;
mainfolder = '/Users/alessio/ToAnalyze/PrionProject/KnockOut/statistics_figures/mat_files';
cd(mainfolder)

variables = dir("*statistics*");

pValues = cell(length(variables)+1,7);
parameters = {'variable','test','pValue','significant','Median','IQR','effectSize_r2'};
pValues(1,:) = parameters;

for i = 1:length(variables)

    load(variables(i).name)

    varName = variables(i).name;
    varName = strsplit(varName,{'_','.'});
    varName = cell2mat(varName(2));

    disp(varName)

    pValues{i+1,1} = varName;
    pValues{i+1,2} = test;
    pValues{i+1,3} = pValue;
    if pValues{i+1,3} < 0.05
        pValues{i+1,4} = '*';
    else
        pValues{i+1,4} = '-';
    end
    pValues{i+1,5} = mediana;
    pValues{i+1,6} = IQR;
    pValues{i+1,7} = effectSize_r2;

    clearvars("-except","pValues","variables")

end

writecell(pValues,"../excel_tables/pValues.xlsx")

clearvars