function [coneType, xy, coneWeight] = conePosDetect(I)
%% function conePosDetect(Img, coneColor)
%   
%  Notes:
%    Here, we assume that:
%      1) LMS cones are marked in red/green/blue repectively. 
%      2) Connection line is bright and the convergence point is close to 
%         white.
%      3) Background is much darker than the lines and dots
%
%  (HJ) April, 2014

%% Check inputs
if notDefined('I'), error('Image required'); end
if max(I(:)) > 1, I = double(I) / 255; end % assume 8 bit here

% crop to avoid boarder effect
I = I(2:end-2, 2:end-2,:);

%% Find cone type and positions
%  Here, cone position will be defined in units of pixels
avgI = 1/3 * sum(I, 3);
pos = cell(3,1);
connImg = rgb2gray(I);
% L = zeros(size(avgI));
% Lstart = 0;
for ii = 1 : 3 % Loop for LMS
    % threshold and get bw image
    diffI = I(:,:,ii) - avgI;
    diffI(diffI < 0) = 0;
    level = graythresh(diffI);
    bw = im2bw(diffI, level);
    
    % Show image for validation
    % figure; imshow(repmat(bw/2, [1 1 3]) + I/2);
    
    % Get positions of the points
    CC = bwconncomp(bw, 4);
    S = regionprops(CC,'Centroid', 'Area');
    % curL = bwlabel(bw) + Lstart;
    % L = max(L, curL);
    % Lstart = max(L(:));
    
    % Remove cones from image
    se = strel('square', 5);
    connImg(imdilate(bw,se)) = 0;
    
    pos{ii} = cat(1, S.Centroid);
    pos{ii} = pos{ii}(cat(1, S.Area)>30,:);
    
    % hold on;
    % plot(pos{ii}(:,1), pos{ii}(:,2), 'k*');
end

tDist = sqrt(median(cat(1, S.Area))*1.2);

% Combine cell entries into matrix and generate coneType matrix
coneType = [2*ones(length(pos{1}),1);
            3*ones(length(pos{2}),1);
            4*ones(length(pos{3}),1)];
xy = cat(1, pos{1}, pos{2}, pos{3});

%% Detect centroids (rgc position)
%  Find connected components in cone-removed image
% level = graythresh(connImg);
% bw = im2bw(connImg, level);
% 
% % show image for validation
% figure; imshow(repmat(bw/2, [1 1 3]) + I/2);
%

bw = im2bw(connImg, 0.93);
se = strel('square', 7);
bw = imdilate(bw, se);

hf = figure; imshow(I);

CC = bwconncomp(bw, 8);
S = regionprops(CC,'Centroid', 'Area');

rgcPos = cat(1, S.Centroid);
area = cat(1, S.Area);
rgcPos = rgcPos(area > 100 & area < 1000, :);

hold on;
plot(rgcPos(:,1), rgcPos(:,2), 'k*');

% Allow user to modify position
% Here, we first get the rgc index to be changed by finding the one closest
% to the point clicked by the user
while true
    fprintf('Click on rgc position to be changed (RETURN for none):');
    [x,y] = ginput(1);
    if isempty(x), break; end
    
    dist = sum((repmat([x y], [length(rgcPos) 1]) - rgcPos).^2, 2);
    [~, indx] = min(dist);
    plot(rgcPos(indx,1), rgcPos(indx,2), 'r*');
    fprintf('Done...\n');
    
    fprintf('Click on new position for the centroid:');
    [x,y] = ginput(1);
    if isempty(x), continue; end
    rgcPos(indx,:) = [x y];
    plot(x, y, 'g*');
    fprintf('(%d, %d)..Done..\n', round(x), round(y));
end

% Allow user to add more rgc nodes
while true
    fprintf('Click on rgc positions to be added (RETURN for none):');
    [x,y] = ginput(1);
    if isempty(x), break; end
    rgcPos = [rgcPos; [x y]];
    plot(x, y, 'g*');
    fprintf('(%d, %d)..Done..\n', round(x), round(y));
end

close(hf);

%% Detect for connection matrix
%  Init connection matrix, maybe sparse matrix will be more proper for
%  large number of cones / rgc
coneWeight = zeros(length(rgcPos), length(coneType));
bgColor = quantile(avgI(:), 0.3); % assume background covers at least 30%

%  Plot for validation
figure; imshow(I);

%  Looping between each cone and each rgc
for ii = 1 : length(coneType) % cone index
    for jj = 1 : length(rgcPos) % rgc index
        % now check if cone(ii) and rgc(jj) are connected
        % the check is done by comparing the median value of the line
        % segment between xy(ii) and rgcPos(jj) with the background color
        % of the image
        c = improfile(avgI, [xy(ii,1), rgcPos(jj,1)], ...
                            [xy(ii,2), rgcPos(jj,2)]);
        if quantile(c, 0.15) > bgColor * 1.25
            % They are connected
            % Now detect line width. Here, we detect line width by drawing
            % a short perpendicular line to this line segment and compute
            % the integration along the line. The answer is justified by
            % the background color. That is, if there's no line, the width
            % will be detected as zero
            coneWeight(jj, ii) = coneWeightDetect(I, ...
                                    xy(ii,:),rgcPos(jj,:), tDist);
            hold on;
            plot([xy(ii,1), rgcPos(jj,1)], [xy(ii,2),rgcPos(jj,2)], ...
                    '--k', 'lineWidth', coneWeight(jj,ii)/3);
            drawnow;
        end
    end
end

%% User Modification & Validation
%  In this section, we let the user to add some connections not detected by
%  the previous auto-detect sections


%% Ask user for connection matrix
%  This is a manual way to do it.
%  (HJ) will try to design some algorithms to handle it more automatically
%  See above two sections

% figure; imshow(I/2); hold on;
% nGroups = 0; coneWeight = [];
% for ii = 1 : length(coneType)
%     h = plot(xy(ii,1), xy(ii,2), 'w*');
%     gNum = 1;
%     while gNum >= 0
%         gNum = input('Group Number (0 = New, -1 = Next node):');
%         assert(isnumeric(gNum), 'Numeric required');
%         if gNum < 0, break; end
%         gNum = round(gNum);
%         if gNum == 0
%             nGroups = nGroups + 1;
%             coneWeight = [coneWeight cell(1,1)];
%             gNum = nGroups;
%         end
%         weight = input('cone weight (0~1):');
%         coneWeight{gNum} = [coneWeight{gNum}; [ii weight]];
%         text(xy(ii,1), xy(ii,2), num2str(gNum), 'color', 'w');
%     end
%     delete(h);
% end

end % End of main function