%% s_createPreComputation
%  script to create pre-computation files
%
%  Written by HJ
%  July, 2013

gridSize = 128; % grid size, default 128*128
rRange   = [1 round(gridSize/2)-1]; % radius range, default full range

% Loop over radius range
for r = rRange(1):rRange(2)
    cdSincCircleIntegration(gridSize, r);
end