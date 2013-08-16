function ang = doCbDirTrial(display, winPtr, cbParams)
%% function doCbDirTrial
%
%    function that finds colorblind direction for one trial
%
%  Inputs:
%
%  Outputs:
%
%  Example:
%
%  See Also:
%
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('Window pointer needed'); end
if nargin < 2, error('color blind parameter structure needed'); end

%% Draw initial state
M = 800; N = 600;% patch size, shall change to computed size
refColorRGB   = cbParams.refColor;
bgColorRGB    = cbParams.bgColor;
curTrial      = cbParams.curTrial;
curAngle      = cbParams.initDir(curTrial)/180 * pi;
curColorRGB   = RGBForContrastChange(display,refColorRGB,bgColorRGB,...
                  cbParams.dist(curTrial)*[cos(curAngle) sin(curAngle) 0]');
colorImg      = repmat(reshape(curColorRGB,[1 1 3]),[M N 1]); 
%colorImg      = repmat(reshape([0 255 0],[1 1 3]),[M N 1]); 
imgTex        = Screen('MakeTexture',winPtr,colorImg);

% Draw to screen
Screen('DrawTexture', winPtr, imgTex);
Screen('Flip', winPtr);

%% Start Trial
while true
    [~,keyCode] = KbWait(-1);
    if iscell(keyCode), continue; end
    switch KbName(keyCode)
        case 'Return' % Confirm and submit
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
    imgTex        = Screen('MakeTexture',winPtr,colorImg);
    Screen('DrawTexture', winPtr, imgTex);
    Screen('Flip', winPtr);
    WaitSecs(0.1);
end
ang = curAngle;

end % end of main function

function matchRGB = RGBForContrastChange(display,refRGB,bgRGB,deltaContrast)
    %bgStim        = color2struct(bgRGB);
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