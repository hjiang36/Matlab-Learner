%% choosePath.m
%
%  This is the startup function for MATLAB
%  In this script, the user will be asked to choose which project will be
%  worked on and automatically add corresponding folders
%  This script can be used on HJ's Macbook Pro / Windows Desktop only
%
%  This script could be renamed to startup.m and put to MATLAB folder to
%  get automatically executed on startup of MATLAB
%
%  (HJ) May, 2015

%% Clean up
clear; clc; close all;

%% Generate toolbox name and path structure
if ispc
    % Windows system
    basePath = 'C:\Users\Haomiao\Documents\GitHub';
    folderNames = {'ISET', 'ISETBio', 'Frontend', ...
        'Color Vision Experiment', 'HJ Matlab-Learner', 'L3'};
    folderPath  = {'iset', 'isetbio', {'isetbio', 'frontend'}, ...
        'colorVisionExperiment', 'Matlab-Learner', ...
        {'iset', 'fbCamera', 'L3'}};
else
    % Mac or Linux system
    basePath = '~/';
    folderNames = {'ISET', 'ISETBio', 'Frontend', ...
        'Color Vision Experiment', 'HJ Matlab-Learner', 'L3'};
    folderPath  = {'iset', 'isetbio', {'isetbio', 'frontend'}, ...
        'colorVisionExperiment', 'Matlab-Learner', ...
        {'iset', 'L3'}};
end

%% Get project number
s = sprintf('Welcome to MATLAB\n');

s = [s sprintf('Please select which toolbox to be added:\n')];
s = [s '0 - None\n'];
for ii = 1 : length(folderNames)
    s = [s sprintf('%d - %s\n', ii, folderNames{ii})];
end

answer = input([s 'Your choice (seperated by spaces):'], 's');

%% Remove all toolbox from path
path(pathdef);

%% Add selected toolbox to path
answer = str2double(strsplit(answer, ' '));
if any(answer == 0)
    clear; clc;
    return
end

try
    for ii = 1 : length(answer)
        fName = folderPath{answer(ii)};
        if ~iscell(fName)
            fName = {fName};
        end
        for jj = 1 : length(fName)
            % swich folder
            cd(fullfile(basePath, fName{jj}));
            
            % check git status
            cprintf('*Keywords', '%s:\n', fName{jj});
            git status;
            
            % add to path
            addpath(genpath(fullfile(basePath, fName{jj})));
        end
    end
catch
end
clear;