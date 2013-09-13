function result = isValidPixIndex(pixIndex)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    maxIndx = length(hG.pixelets);
    if pixIndex >= 1 && pixIndex <= maxIndx
        result = true;
    else
        result = false;
    end
end