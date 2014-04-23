function weight = coneWeightDetect(I, conePos, rgcPos, d)
%% function coneWeightDetect(I, conePos, rgcPos)
%    Detect the cone width of line between the cone and the rgc receptive
%    field
%
%  (HJ) April, 2014

%% Init
if notDefined('I'), error('Image required'); end
if notDefined('conePos'), error('cone position required'); end
if notDefined('rgcPos'), error('rgc position required'); end
if notDefined('d'), d = 10; end

if size(I, 3) ~= 1, I = rgb2gray(I); end
conePos = conePos(:)'; rgcPos = rgcPos(:)';

%% Find line segments
bgColor = quantile(I(:), 0.3); % assume background covers more than 30%
ptPos = [1/5 1/4 1/3 1/2 2/3];
k = -(rgcPos(1) - conePos(1)) / (rgcPos(2) - conePos(2));
if isinf(k)
    offset = [0 d];
else
    offset = d * [1/sqrt(1+k^2) k/sqrt(1+k^2)];
end

weight = zeros(length(ptPos), 1);
for ii = 1 : length(ptPos)
    cc = (1 - ptPos(ii)) * conePos + ptPos(ii) * rgcPos;
    pts = [cc + offset; cc - offset]; 
    c = improfile(I, pts(:,1), pts(:,2));
    weight(ii) = sum(c);
end

weight(isnan(weight)) = [];
weight = median(weight) - bgColor * d;

end