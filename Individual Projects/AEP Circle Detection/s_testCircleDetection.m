%% s_testCircleDetection
%  script to test repeatability for circle detection
%
%  Written by HJ
%  July, 2013

%% Test Mark Bot Images
%  Inner circle is detected by CGL, outer cicle is detected by Min CGL
c = zeros(5,2,2); % Number of Image * 2 (centerX, centerY) * 2 (Inner, Outer)
r = zeros(5,2); % Number of Image * 2 (Inner, Outer)
for i = 1 : 5
    % Load Image
    I = imread(['./CD Marks/MarkTBot' num2str(i) '.bmp']);
    % Detect Inner Circle
    [c(i,:,1),r(i,1)] = cdCircleDetectionByMinimum(I,[65 65 13]);
    % Detect Outer Circle
    %[c(i,:,2),r(i,2)] = cdCircleDetectionByGradient(I,[66 66 27]);
    [c(i,:,2),r(i,2)] = cdCircleDetectionByMinimum(I,[66 66 30]);
end

% Compute std of R
disp(['Inner Circle Radius std:' num2str(std(r(:,1)))]);
disp(['Outer Circle Radius std:' num2str(std(r(:,2)))]);
disp(['Circle Relative Center std:' num2str(std(c(:,:,2)-c(:,:,1)))]);

%% Test Mark Top Image
%  Inner circle is detected by CGL, outer cicle is detected by Gradient
c = zeros(5,2,2); % Number of Image * 2 (centerX, centerY) * 2 (Inner, Outer)
r = zeros(5,2); % Number of Image * 2 (Inner, Outer)
for i = 1 : 5
    % Load Image
    I = imread(['./CD Marks/MarkTop' num2str(i) '.bmp']);
    % Detect Inner Circle
    [c(i,:,1),r(i,1)] = cdCircleDetectionByMinimum(I,[69 69 17]);
    % Detect Outer Circle
    [c(i,:,2),r(i,2)] = cdCircleDetectionByGradient(I,[68 70 33]);
end

% Compute std of R
disp(['Inner Circle Radius std:' num2str(std(r(:,1)))]);
disp(['Outer Circle Radius std:' num2str(std(r(:,2)))]);
disp(['Circle Relative Center std:' num2str(std(c(:,:,2)-c(:,:,1)))]);

%% Test Newly Captured Images
%  List all files in newly captured folder
lstStr  = dir('./Test-2013-7-24-19-27-41/*.bmp');
nImages = length(lstStr);

% Init center and radius
uC = zeros(nImages,2,2); % Number of Image * 2 (centerX, centerY) * 2 (Inner, Outer)
uR = zeros(nImages,2); % Number of Image * 2 (Inner, Outer)

lC = zeros(nImages,2,2); % Number of Image * 2 (centerX, centerY) * 2 (Inner, Outer)
lR = zeros(nImages,2); % Number of Image * 2 (Inner, Outer)

sub_size=128; % size of each image: 128*128
ulx=666; uly=642;
llx=670; lly=728; 


% Circle detection
for i = 1 : nImages
    % Load Image
    I = imread(['./Test-2013-7-24-19-27-41/' lstStr(i).name]);
    % Find upper circle
    I_upper=I(uly-sub_size/2:uly+sub_size/2-1,...
                     ulx-sub_size/2:ulx+sub_size/2-1);
    % Detect Inner Circle, assuming radius is between 7 and 20
    [uC(i,:,1),uR(i,1)] = cdCircleDetectionByMinimum(I_upper,[7 20]);
    % Detect Outer Circle, assuming radius is between 30 and 50
    [uC(i,:,2),uR(i,2)] = cdCircleDetectionByGradient(I_upper,[20 40]);
    % [uC(i,:,2),uR(i,2)] = cdCircleDetectionByMinimum(I_upper,[78 55 30]);
    % Find lower circle
    I_lower=I(lly-sub_size/2:lly+sub_size/2-1,...
              llx-sub_size/2:llx+sub_size/2-1);
                 
    % Detect Inner Circle
    [lC(i,:,1),lR(i,1)] = cdCircleDetectionByMinimum(I_lower,[74 56 11]);
    % Detect Outer Circle
    [lC(i,:,2),lR(i,2)] = cdCircleDetectionByMinimum(I_lower,[74 56 25]);
end

% Compute std of R
disp(['Upper Image Inner Circle Radius std:' num2str(std(uR(:,1)))]);
disp(['Upper Image Outer Circle Radius std:' num2str(std(uR(:,2)))]);
disp(['Upper Image Circle Relative Center std:' num2str(std(uC(:,:,2)-uC(:,:,1)))]);


disp(['Lower Image Inner Circle Radius std:' num2str(std(lR(:,1)))]);
disp(['Lower Image Outer Circle Radius std:' num2str(std(lR(:,2)))]);
disp(['Lower Image Circle Relative Center std:' num2str(std(lC(:,:,2)-lC(:,:,1)))]);

