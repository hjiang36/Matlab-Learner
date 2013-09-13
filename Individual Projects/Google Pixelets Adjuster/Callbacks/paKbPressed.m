function paKbPressed(~, evt)
%% function paKbPressed(~, evt)
%    This is the keyboard callback function for pixelet adjuster.
%
%  Supports keys:
%      - Number 1 ~ 9  used to select corresponding pixelets
%      - Number 0      used to select whole window
%      - Arrow Key     used to move the selected pixelet up/down/left/right
%      - CMD + z       used to undo last command
%      - i / o         used to zoom in / out
%      - ESC           cancel selection and exit edit mode
%
%  See also
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Get pixelet info
hG.fig = findobj('Tag','PixeletAdjustment');
hG = getappdata(hG.fig,'handles');

if ~isfield(hG,'kbSelected')
    inEdit = false;
end

curPix = hG.kbSelected;
if ~curPix
    curPos = get(hG.fig,'Position');
else
    curPos = hG.pixelets{curPix}.dispPos;
end

%% Process key pressed request
switch evt.Key
    case 'uparrow'
        if ~inEdit, return; end
        if ~curPix
            set(hG.fig,'Position',[curPos(1) curPos(2)+1 curPos(3:4)]);
            return;
        elseif curPos(1)>1
            hG.pixelets{curPix}.dispPos(1) = curPos(1) - 1;
        end
    case 'downarrow'
        if ~inEdit, return; end
        if ~curPix
            set(hG.fig,'Position',[curPos(1) curPos(2)-1 curPos(3:4)]);
            return;
        elseif curPos(1) < size(hG.dispI,1)
            hG.pixelets{curPix}.dispPos(1) = curPos(1) + 1;
        end
    case 'leftarrow'
        if ~inEdit, return; end
        if ~curPix
            set(hG.fig,'Position',[curPos(1)-1 curPos(2:4)]);
            return;
        elseif curPos(2) > 1
            hG.pixelets{curPix}.dispPos(2) = curPos(2) - 1;
        end
    case 'rightarrow'
        if ~inEdit, return; end
        if ~curPix
            set(hG.fig,'Position',[curPos(1)+1 curPos(2:4)]);
            return;
        elseif curPos(2) < size(hG.dispI,2)
            hG.pixelets{curPix}.dispPos(2) = curPos(2) + 1;
        end
    case 'z'
        % Command Z - revert last operation
        if isunix
            modifier = 'command';
        else
            modifier = 'control';
        end
        if length(evt.Modifier) == 1 && strcmp(evt.Modifier{1},modifier)
            if ~isempty(hG.history)
                hG.pixelets = hG.history.pixelets;
                hG = rmfield(hG, 'kbSelected');
                hG.mouseDown  = false;
            else
                warning('No steps to be reverted');
            end
        end
    case 'i'
        % Increase image size by 1 pix
        POS = get(hG.fig,'Position');
        set(hG.fig, 'Position',[POS(1) POS(2) POS(3)+1 POS(4)+1]);
        setappdata(hG.fig,'handles',hG);
    case 'o'
        % Decrease image size by 1 pix
        POS = get(hG.fig,'Position');
        set(hG.fig, 'Position',[POS(1) POS(2) POS(3)-1 POS(4)-1]);
        setappdata(hG.fig,'handles',hG);
    case 'escape'
        hG = rmfield(hG, 'kbSelected');
    otherwise % Should be number keys - for selecting pixelets
        curPix = floor(str2double(evt.Key));% make sure curPix is int
        if isnan(curPix), return; end
        if curPix ~= 0 && ~isValidPixIndex(curPix) % 0 for whole figure
            return;
        end
        hG.kbSelected = curPix;
end

% Redraw
hG.dispI = refreshPixelets(hG);

setappdata(hG.fig,'handles',hG);
end