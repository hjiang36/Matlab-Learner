%% s_Brettel_SET
%
%    This script compares Brettel's simulation method and spectral
%    estimation theory predictions in xy color space
%
%    The result are used as figure 3.1 in EI paper
%
% HJ, VISTA TEAM, 2015

% Init 
ieInit;

% Load XYZ matching data
wave = 400:720;
XYZ = ieReadSpectra('XYZ', wave);

% Compute visible region in xy space
xy = bsxfun(@rdivide, XYZ, sum(XYZ, 2)); xy = xy(:, 1:2);
xy = [xy; xy(1,:)];

% define white point
wp = ieXYZFromEnergy(1e-3*ones(length(wave),1)', wave);

% Compute predictions by Brettel and spectral estimation theory for
% monochrome light in eyes of three types of dichromatic observers
vcNewGraphWin([], 'wide');
for cbType = 1 : 3 % for protanope and deuteranope
    % plot visible region
    subplot(1, 3, cbType); hold on;
    plot(xy(:, 1), xy(:, 2), 'k'); xlabel('CIE-x'); ylabel('CIE-y');
    
    % Compute and plot predictions of Brettel's method
    XYZ_B = lms2xyz(xyz2lms(XYZ, cbType, 'Brettel', wp));
    xy_B = bsxfun(@rdivide, XYZ_B, sum(XYZ_B, 2)); xy_B = xy_B(:, 1:2);
    in = inpolygon(xy_B(:,1), xy_B(:,2), xy(:,1), xy(:,2));
    hb = plot(xy_B(in,1), xy_B(in,2), 'r', 'lineWidth', 2);
    
    % Compute predictions of spectral estimation theory
    if cbType < 3
        % annotation wavelength
        markerWave = [476 490 500 575]; % wavelength to annotate
        markerIndex = arrayfun(@(x) find(wave==x), markerWave);
        markerText = arrayfun(@num2str, markerWave, 'UniformOutput', 0);
        
        XYZ_S = lms2xyz(xyz2lms(XYZ, cbType, 'Linear'));
        xy_S = bsxfun(@rdivide, XYZ_S, sum(XYZ_S, 2)); xy_S = xy_S(:, 1:2);
        in = inpolygon(xy_S(:,1), xy_S(:,2), xy(:,1), xy(:,2));
        hs = plot(xy_S(in,1), xy_S(in,2), '--b', 'lineWidth', 2);
    else
        markerWave = [476 500 550 575 620]; % wavelength to annotate
        markerIndex = arrayfun(@(x) find(wave==x), markerWave);
        markerText = arrayfun(@num2str, markerWave, 'UniformOutput', 0);
        
        XYZ_S = lms2xyz(dColorTransform(xyz2lms(XYZ), cbType));
        xy_S = bsxfun(@rdivide, XYZ_S, sum(XYZ_S, 2)); xy_S = xy_S(:, 1:2);
        hs = plot(xy_S(:,1), xy_S(:,2), '--b', 'lineWidth', 2);
    end
    
    % add marker
    plot(xy_B(markerIndex, 1), xy_B(markerIndex, 2), 'ro');
    plot(xy_S(markerIndex, 1), xy_S(markerIndex, 2), 'bo');
    text(xy_S(markerIndex, 1)+0.02, xy_S(markerIndex, 2)-0.02, markerText);
    
    % add legend
    legend([hb hs], {'Brettel''s Method', 'Spectral Estimation Theory'});
end

% Plot measurement data
load('Alpern_Tritanope.mat');
plot(Alpern_Figure2(:, 1), Alpern_Figure2(:, 2), ':g', 'LineWidth', 2);