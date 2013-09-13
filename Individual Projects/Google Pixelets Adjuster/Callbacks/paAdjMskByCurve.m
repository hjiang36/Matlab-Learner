function msk = paAdjMskByCurve(curMsk, direction)
%% function paAdjMskByCurve(curMsk, [direction])
%    This function is abbandoned somehow. Might get back to this sometime
%    in the future
%    More comments to be put here
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Sep, 2013

%% Check inputs
if nargin < 1, error('current mask image required'); end
if nargin < 2, direction = 0; end

%% Adjust interactively by curve
fig = figure;
msk = curMsk;
if direction == 0
    plot(curMsk(1,:,1),'LineWidth',2);
else
    plot(curMsk(:,1,1),'LineWdith',2);
end
ylim([0 1.1]);
dcm_obj = datacursormode(fig);
set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','on','Enable','on');
end