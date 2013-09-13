function fullPath = paRootPath(varargin)
%% function paRootPath([varargin])
%    get the full root path to the pixelet adjuster
%
%  Input:
%    varargin  - used to get some parameters, not used now
%
%  Output:
%    fullPath  - full path of pixelet adjuster root path
%
%  Example:
%    rootPath = paRootPath();
%
%  (HJ) Sep, 2013

%% Get current path
curPath = pwd;
fullPath = fileparts(mfilename('fullpath'));

%% Get root path
cd(fullPath); cd('../');
fullPath = pwd;

%% Restore current directory
cd(curPath);

end