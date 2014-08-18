%% s_nBasisForNaturalScenes
from = '/Users/Killua/Downloads/complete_ms_data';
caveData = loadCAVEData(from);

statistics = zeros(length(caveData), 1);
nnbasis = zeros(length(caveData), 1);
cone = coneCreate;
spd = coneGet(cone, 'absorptance');
% sensor = sensorCreate('human');
% spd = sensorGet(sensor, 'spectral qe');
% spd = spd(:, 2:4);
% spd = bsxfun(@rdivide, spd, max(spd));

% cut-off to 400 ~ 650 nm
% spd = spd(1:26, :);

% normalize by light
% the cave dataset is actually reflectance data
% And it's based on a D65 light
il = illuminantCreate('D65');
s  = illuminantGet(il, 'photons');
s  = reshape(s, [1 1 length(s)]) / max(s);

xw_total = [];
light_total = [];
for ii = 1 : length(caveData)
    reflectance = bsxfun(@times, caveData(ii).reflectance, s);
    [xw, r, c] = RGB2XWFormat(reflectance);
    
    % Now, we found the directions for the plane, note they are not
    % orthognal
    M = (spd' * spd); % 3 x 3
    coef = M \ (xw * spd)'; % coef - 3xN
    projection = sum((coef' * M) .* coef', 2);
    lightEnergy = sum(xw.^2, 2);
    indx = lightEnergy > quantile(lightEnergy, 0.05);
    explained = projection(indx) ./ lightEnergy(indx);
    
    statistics(ii) = mean(explained);
    
    % Print for latex
    fprintf('%s & %.2f & %.2f \\\\\n', caveData(ii).name(1:end-3), ...
                    mean(explained), std(explained));
    
    % for optimal basis, we should not forget the constraints that the
    % absorptance curve should be non-negative.
    % That means, PCA doesn't make sense here.
    % Instead, we could use non-negative factorization to get the solution
    [~, H] = nnmf(xw, size(spd, 2));
    H = H';
    M = (H' * H);
    coef = M \ (xw * H)';
    projection = sum((coef'*M) .* coef', 2);
    nnbasis(ii) = median(projection(indx) ./ lightEnergy(indx));
    
    % cat all
    xw_total = cat(1, xw_total, xw(indx, :));
    light_total = cat(1, light_total, lightEnergy(indx));
end

% Compute optimal basis for all scenes
% clear caveData
[~, H] = nnmf(xw_total, size(spd, 2));
H = H';
M = (H' * H);
coef = M \ (xw_total * H)';
projection = sum((coef' * M) .* coef', 2);
nnbasis_total = projection ./ light_total;