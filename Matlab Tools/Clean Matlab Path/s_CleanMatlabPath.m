%% s_CleanMatlabPath
%    clean up matlab path file, namely, clean up .svn and .git folders from
%    the matlab search path. I believe we won't need these in Matlab search
%    path.

%% Load and Parse Matlab Path
curPath = matlabpath;
curPath = strsplit(curPath,':');

%% Taversal through path name
matchStr = {'.svn','.git'};
for i = 1 : length(curPath)
    for j = 1 : length(matchStr)
        if ~isempty(strfind(curPath{i},matchStr{j})) || ...
           ~exist(curPath{i},'dir')
            disp(['Removing Path:' curPath{i}]);
            rmpath(curPath{i});
            break;
        end
    end
end