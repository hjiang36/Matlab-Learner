function ang = doCbDirTrial(display, winPtr, cbParams)
%% function doCbDirTrial
%
%    function that finds colorblind direction for one trial
%
%  Inputs:
%    display  - ISET compatible display structure
%    winPtr   - Window pointer for certain opened PTB screen
%    cbParams - Experiment parameters, 
%
%  Outputs:
%    ang      - User selected angle
%
%  Example:
%    ang = doCbDirTrial(display, winPtr, cbParams)
%
%  See Also:
%    cbTestDirection
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('Window pointer needed'); end
if nargin < 2, error('color blind parameter structure needed'); end

%% Draw initial state
M = angle2pix(display,cbParams.patchSz(1)); 
N = angle2pix(display,cbParams.patchSz(2));

refColorRGB   = cbParams.refColor;
bgColorRGB    = cbParams.bgColor;
curTrial      = cbParams.curTrial;
curAngle      = cbParams.initDir(curTrial)/180 * pi;
curColorRGB   = RGBForContrastChange(display,refColorRGB,bgColorRGB,...
                  cbParams.dist(curTrial)*[cos(curAngle) sin(curAngle) 0]');
colorImg      = repmat(reshape(curColorRGB,[1 1 3]),[M N 1]); 

imgTex        = Screen('MakeTexture',winPtr,colorImg, 0, 0, 2);

% Draw to screen
Screen('DrawTexture', winPtr, imgTex);
Screen('Flip', winPtr);

%% Start Trial
while true
    [~,keyCode] = KbWait(-1);
    if iscell(keyCode), continue; end
    switch KbName(keyCode)
        case 'Return' % Confirm and submit
            WaitSecs(0.1);
            break;
        case 'LeftArrow' % Change color
            curAngle = mod(curAngle - 1/180 * pi, 2*pi);
        case 'RightArrow' % Change color
            curAngle = mod(curAngle + 1/180 * pi, 2*pi);
        otherwise % Unknown keys, ignore
            continue;
    end
    curColorRGB   = RGBForContrastChange(display,refColorRGB,bgColorRGB,...
        cbParams.dist(curTrial)*[cos(curAngle) sin(curAngle) 0]');
    colorImg      = repmat(reshape(curColorRGB,[1 1 3]),[M N 1]);
    imgTex        = Screen('MakeTexture',winPtr,colorImg, 0, 0, 2);
    Screen('DrawTexture', winPtr, imgTex);
    Screen('Flip', winPtr);
    WaitSecs(0.025);
end
ang = curAngle;

end % end of main function

function matchRGB = RGBForContrastChange(display,refRGB,bgRGB,deltaContrast)
    refContrast   = RGB2ConeContrast(display,...
        color2struct(refRGB - bgRGB));
    matchContrast = refContrast + deltaContrast;
    matchStim     = cone2RGB(display,color2struct(matchContrast));
    if max(bgRGB) > 1
        matchRGB      = bgRGB' + matchStim.dir*matchStim.scale*255;
    else
        matchRGB      = bgRGB' + matchStim.dir*matchStim.scale;
    end
end