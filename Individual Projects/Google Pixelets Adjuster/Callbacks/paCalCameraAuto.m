function hG = paCalCameraAuto(hG, varargin)
    [hG, transS, srcROI, dstROI] = cameraPosCalibration;
    hG.dispI = refreshPixelets(hG);
    setappdata(hG.fig, 'handles', hG);
end