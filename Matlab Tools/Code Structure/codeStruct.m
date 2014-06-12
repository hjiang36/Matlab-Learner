function [fName, connM] = codeStruct(dirName, varargin)
%% compute code structure for given folder
%    [fName, connM] = codeStruct(dirName, [varargin]);
%
%  (HJ) June, 2014

%% Init
assert(isdir(dirName), 'Directory cannot be found');
curPath = path;
addpath(genpath(dirName));

%% Get all function names in folder
%  get all files
fName = getAllFiles(dirName);

%  filter out data files, git files, etc.
for ii = 1 : length(fName)
    [~, name, ext] = fileparts(fName{ii});
    if ismember(ext, {'.m', '.p'}) && exist(name, 'file')
        fName{ii} = name;
    else
        fName{ii} = [];
    end
end

fName = fName(~cellfun('isempty', fName));

% check uniqueness
[fName, ~, idx] = unique(fName);
[count, idx] = hist(idx, unique(idx));
if any(count > 1) % make and schema, etc.
    indx = find(count > 1);
    warning('Duplicated file names found:');
    for ii = 1 : length(indx)
        fprintf('%s\n', fName{idx(indx)});
    end
end

%% Compute connection matrix
connM = zeros(length(fName));
for ii = 1 : length(fName)
    fullPath = which(fName{ii});
    depFuncs = depfun(fullPath, '-toponly', '-quiet');
    for jj = 1 : length(depFuncs)
        [~, depName, ~] = fileparts(depFuncs{jj});
        connM(ii, find(strcmp(fName, depName), 1)) = 1;
    end
end

% remove self connectivity
connM = connM - eye(length(fName));

%% Print unused functions
idx = find(sum(connM) == 0);
fprintf('Unused functions:\n');
for ii = 1 : length(idx)
    fprintf('%s\n', fName{idx(ii)});
end

%% Restore old search path
path(curPath);

end