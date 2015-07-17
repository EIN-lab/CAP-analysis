function varargout = plot_traces(tt, vv)

% Setup the color values for the 
nSweeps = size(vv, 2);
colorVals = parula(nSweeps);

% Maximize the figure
set(gcf,'units','normalized','outerposition',[0 0 1 1])

% Plot the figure
yMax = max(vv(:));
yMin = min(vv(:));
yRange = yMax - yMin;
yLimFrac = 0.05;
yLims = [yMin-yLimFrac*yRange, yMax+yLimFrac*yRange];
hold on
for iSweep = 1:nSweeps
    plot(tt, vv(:, iSweep), 'Color', colorVals(iSweep, :))
end
hold off
ylim(yLims)

% Pass the output argument
if nargout > 0
    varargout{1} = yLims;
end

end