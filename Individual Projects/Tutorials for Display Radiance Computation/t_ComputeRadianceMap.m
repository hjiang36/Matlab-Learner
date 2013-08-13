%% t_ComputeRadianceMap
%    
%    Tutorial for how to generate ISET scene for any given bitmap
%
%  This tutorial will including following part
%    1. Generate ISET scene from bitmap
%    2. Show ISET scene, get basic analysis
%    3. More computations from the scene
%
%  Pre-requisit:
%    ISETbio - can be downloaded for free from:
%        https://github.com/wandell/isetbio
%
%  (HJ) VISTASOFT Team 2013

%% Init
s_initISET;

%% Create scene from file
%  Init data file path
imgFileName = 'colorChecker.jpg';
dispBVMFile = 'OLED-SonyBVM.mat';
dispPVMFile = 'OLED-SonyPVM.mat';

%  Check existence
if ~exist(imgFileName,'file'), error('Image file not found'); end
if ~exist(dispBVMFile,'file'), error('BVM Display file not found.'); end
if ~exist(dispPVMFile,'file'), error('PVM Display file not found.'); end

%  Init scene parameters
fov         = 1;               % field of view
vd          = 6;               % Viewing distance- Six meters

%  Create scene from file
%  Scene on BVM
sceneB = sceneFromFile(imgFileName,'rgb',[],dispBVMFile);
sceneB = sceneSet(sceneB,'fov',fov);      
sceneB = sceneSet(sceneB,'distance',vd);
sceneB = sceneSet(sceneB,'name','Scene on BVM');

%  Scene on PVM
sceneP = sceneFromFile(imgFileName,'rgb',[],dispBVMFile);
sceneP = sceneSet(sceneP,'fov',fov);
sceneP = sceneSet(sceneP,'distance',vd);
sceneP = sceneSet(sceneP,'name','Scene on PVM');

%  Show created scenes
vcAddAndSelectObject('scene',sceneB);
vcAddAndSelectObject('scene',sceneP);
sceneWindow;