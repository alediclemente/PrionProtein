% Set main folder
mainFolder = '/Users/alessio/ToAnalyze/PrionProject/KnockOut'; % <-- change this

DIVs = {'DIV10','DIV17','DIV24'};
conditions = {'KO','WT'};

for c = 1:length(conditions)
    cond = conditions{c};
    
    % Get MEA codes for each DIV
    codes = struct();
    for d = 1:length(DIVs)
        folderPath = fullfile(mainFolder,DIVs{d},cond);
        dirs = dir(folderPath);
        dirs = dirs([dirs.isdir] & ~startsWith({dirs.name},'.'));
        codes.(DIVs{d}) = cellfun(@(x) regexp(x,'I\d+','match','once'), {dirs.name}, 'UniformOutput', false);
    end
    
    % 1) DIV24 -> check also in DIV17 AND DIV10
    div24 = codes.DIV24;
    div17 = codes.DIV17;
    div10 = codes.DIV10;
    div24_common = div24( cellfun(@(x) ismember(x,div17) && ismember(x,div10), div24) );
    
    % 2) DIV17 but not in DIV24 -> check if present in DIV10
    div17_only = setdiff(div17, div24);
    div17_only_in_div10 = div17_only( cellfun(@(x) ismember(x,div10), div17_only) );
    
    % Display results
    fprintf('Condition %s:\n', cond);
    fprintf('  DIV24 present also in DIV17 AND DIV10: %d\n', length(div24_common));
    if ~isempty(div24_common)
        fprintf('    MEAs: %s\n', strjoin(div24_common,', '));
    end
    fprintf('  DIV17 (not in DIV24) present in DIV10: %d\n', length(div17_only_in_div10));
    if ~isempty(div17_only_in_div10)
        fprintf('    MEAs: %s\n', strjoin(div17_only_in_div10,', '));
    end
    fprintf('\n');
end
