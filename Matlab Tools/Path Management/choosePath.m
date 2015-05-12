%% startup.m
%  This is the startup function for MATLAB
%  In this script, the user will be asked to choose which project will be
%  worked on and automatically add corresponding folders
%  This script can be used on HJ's Macbook Pro only
%
%  (HJ) Oct, 2013

%% Clean up
clear; clc; close all;

%% Generate toolbox name and path structure
folderNames = {'ISET', 'ISETBio','Frontend','Color Vision Experiment', ...
               'ctToolbox', 'HJ Matlab-Learner', 'L3', ...
               'PDC Soft', 'Vista Disp'};
folderPath  = {'~/iset', '~/isetbio', {'~/isetbio', '~/frontend'}, ...
               '~/colorVisionExperiment', '~/ctToolbox', ...
               '~/Matlab-Learner', {'~/iset', '~/fbCamera', '~/L3'}...
               '~/PDCSoft', '~/VistaDisp'};

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
    return;
end

try
    for ii = 1 : length(answer)
        fName = folderPath{answer(ii)};
        if ~iscell(fName)
            fName = {fName};
        end
        for jj = 1 : length(fName)
            % swich folder
            cd(fName{jj});
            % check git status
            if answer(ii) < 8
                cprintf('*Keywords', '%s:\n', fName{jj});
                git status;
            end
            addpath(genpath(fName{jj}));
        end
    end
catch
end
clear;