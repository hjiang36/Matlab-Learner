function paMouseDown(~, ~)
%% function paMouseDown
%    put comments here
%
%
%
%  (HJ) Aug, 2013

%% Get pixelet adjuster handler
hG = paGetHandler();
if isempty(hG), return; end

%% Get selected pixelet
if strcmp(get(gca,'units'),'normalized')
    set(gca,'units','pixels');
    pos = get(gca,'CurrentPoint');
    set(gca,'units','normalized');
else
    pos = get(gca,'CurrentPoint');
end

[curPix,pix] = pixeletIndxByPos(hG.pixelets,pos(1, [2 1]));
if ~curPix, return; end

% Save History
hG.history.pixelets = hG.pixelets;

%% Process mouse click request
if strcmpi(get(hG.fig,'selectiontype'),'alt') % Right click
    prompt = {'Blur Size (Left)','Blur Size (Right)',...
        'Display Size (Height)', 'Display Size (Width)'};
    dlg_title = 'Adjust Parameters';
    def = {num2str(pix.blurL),num2str(pix.blurR),...
        num2str(pix.dispSize(1)), num2str(pix.dispSize(2))};
    answer = inputdlg(prompt, dlg_title, 1, def);
    % Check inputs
    if isempty(answer), return; end
    if any(isnan(str2double(answer))), return; end
    % Deal with Blue Size
    newBlur = str2double(answer(1:2));
    if any(newBlur ~= [pix.blurL; pix.blurR])
        hG.pixelets{curPix} = pixeletAdjBlurSize(pix,newBlur);
    end
    % Deal with dispSize
    hG.pixelets{curPix} = pixeletSet(pix, 'display size', ...
        [str2double(answer{3}) str2double(answer{4})]);
    
elseif strcmpi(get(hG.fig,'selectiontype'), 'normal') % Left click
    hG.mouseDown = true;
    hG.downPos  = round(pos(1,[2 1]));
    hG.selected = curPix;
    
elseif strcmpi(get(hG.fig,'selectiontype'), 'open') % Double click
    % Ask user for new mean luminance
    prompt = {'Mean Luminance (Avg Msk)'};
    dlg_title = 'Adjust Msk';
    originalMean = mean(pix.msk(:));
    def = {num2str(originalMean)};
    answer = inputdlg(prompt, dlg_title, 1, def);
    if isempty(answer), return; end
    newMean = str2double(answer{1});
    % Avoid 0 as input
    if newMean < 1/512; newMean = 1/512; end
    scalar = newMean / originalMean;
    
    % Adjust mask values
    hG.pixelets{curPix} = pixeletSet(hG.pixelets{curPix}, 'msk', ...
          pixeletGet(hG.pixelets{curPix}, 'msk') * scalar);

    % Save adjusted values
    setappdata(hG.fig, 'handles', hG);
    
    % Adjust by Region, this part will be removed
    curMsk = pixeletGet(hG.pixelets{curPix}, 'msk');
    newMsk = paAdjMskByRegion(curMsk);
    hG.pixelets{curPix} = pixeletSet(hG.pixelets{curPix}, 'msk', newMsk);
    
end

%% Save adjusted value
setappdata(hG.fig,'handles',hG);

end