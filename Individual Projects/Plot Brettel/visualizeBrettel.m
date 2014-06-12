function hf = visualizeBrettel(anchor, cbType, varargin)
%% function visualizeBrettel(anchor, [varargin])
%    visualize Brettel transform algorithm
%
%  Inputs:
%    anchor   - 2 elements indicating the two achor wavelength
%    cbType   - colorblind type, 1~3 for protan/deutan/tritan respectively
%    varargin - optional inputs, could include:
%               - color points
%               - output file to be exported (NYI)
%
%  Outputs:
%    hf       - handle of figure
%
%  Example:
%    hf = visualizeBrettel([475 550], 1);
%
%  Note
%
%  (HJ) May, 2014

%% Init
if notDefined('cbType'), cbType = 1; end
if notDefined('anchor')
    switch cbType
        case {1,2}
            anchor = [475 575];
        case 3
            anchor  = [485 660];
        otherwise
            error('unknown colorblind type');
    end
end

hf = figure; hold on;
grid on;

%% Plot anchor directions
%  plot monochrome anchor
wave = (400:700)';
anchorLMS = zeros(length(anchor),3);
for ii = 1 : length(anchor)
    energy = zeros(length(wave),1);
    energy(wave==anchor(ii)) = 1;
    achorXYZ = ieXYZFromEnergy(energy', wave);
    curLMS = xyz2lms(reshape(achorXYZ, [1 1 3]));
    anchorLMS(ii,:) = curLMS(:)' / sum(curLMS(:));
    quiver3(0,0,0,anchorLMS(ii, 1), anchorLMS(ii, 2), anchorLMS(ii, 3), ...
        '--', 'Color', [0.2 0.2 0.2]);
end
%  plot equal energy light
energy(:) = 1 / length(wave);
achorXYZ = ieXYZFromEnergy(energy', wave);
eqLMS = xyz2lms(reshape(achorXYZ, [1 1 3]));
eqLMS = eqLMS(:)' / sum(eqLMS);
quiver3(0,0,0,eqLMS(1), eqLMS(2), eqLMS(3), '--', ...
    'Color', [0.2 0.2 0.2]);

%% Plot dichromatic color plane
n = length(anchor);
p = patch([zeros(1,n); 0.8 * anchorLMS(:, 1)'; 0.8 * eqLMS(1)*ones(1,n)], ...
          [zeros(1,n); 0.8 * anchorLMS(:, 2)'; 0.8 * eqLMS(2) * ones(1,n)], ...
          [zeros(1,n); 0.8 * anchorLMS(:, 3)'; 0.8 * eqLMS(3) * ones(1,n)], ...
          [1 1]);
set(p,'FaceColor','flat', 'CData', [45 45],...
'CDataMapping','direct');
colormap('gray')

%% Plot test color and the transformed points


%% Labels and annotations for the plot
xlabel('L'); ylabel('M'); zlabel('S');

%% END