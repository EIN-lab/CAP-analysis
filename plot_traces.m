function varargout = plot_traces(tt, vv)

% Maximize the figure
set(gcf,'units','normalized','outerposition',[0 0 1 1])

% Plot the figure
yMax = max(vv(:));
yMin = min(vv(:));
yRange = yMax - yMin;
yLimFrac = 0.05;
yLims = [yMin-yLimFrac*yRange, yMax+yLimFrac*yRange];
plot(tt, vv)
ylim(yLims)

% Pass the output argument
if nargout > 0
    varargout{1} = yLims;
end

end