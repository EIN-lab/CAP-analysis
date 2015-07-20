function varargout = plot_summary(data, fnFull_plot)

colOrder = get(groot,'DefaultAxesColorOrder');

propsAxes = {'FontSize', 12};

nRows = 6;
nCols = 1;

time_sweeps = data.time_sweeps/60;
xLims = [min(time_sweeps), max(time_sweeps)];

hFig = figure;
if nargout > 0
    varargout{1} = hFig;
end

subplot(nRows, nCols, 1, propsAxes{:}), hold on
plot(time_sweeps, data.area_CAP, 'Color', 'k', ...
    'DisplayName', sprintf('Sweeps %d to %d', data.edges_area))
xlim(xLims)
title(data.filename, 'Interpreter', 'none')
ylabel('CAP Area') % (incl edges)
legend('Show'), legend('boxoff')
hold off

subplot(nRows, nCols, 2, propsAxes{:}), hold on
plot(time_sweeps, data.area_CAP_partial, 'Color', 'k', ...
    'DisplayName', sprintf('Sweeps %d to %d', data.edges_area_partial))
xlim(xLims)
ylabel('Partial CAP Area') % (incl edges)
legend('Show'), legend('boxoff')
hold off

subplot(nRows, nCols, 3, propsAxes{:}), hold on
plot(time_sweeps, data.peak_area_fit(:,1), '--', ...
    'Color', colOrder(1, :), 'DisplayName', 'Peak 1 fit')
plot(time_sweeps, data.peak_area_fit(:,2), '--', ...
    'Color', colOrder(2, :), 'DisplayName', 'Peak 2 fit')
plot(time_sweeps, data.peak_area_fit(:,3), '--', ...
    'Color', colOrder(3, :), 'DisplayName', 'Peak 3 fit')
xlim(xLims)
ylabel('Peak Area')
legend('Show'), legend('boxoff')
hold off

subplot(nRows, nCols, 4, propsAxes{:}), hold on
plot(time_sweeps, data.peak_height_raw(:,1), ...
    'Color', colOrder(1, :), 'DisplayName', 'Peak 1 raw')
plot(time_sweeps, data.peak_height_fit(:,1), '--', ...
    'Color', colOrder(1, :), 'DisplayName', 'Peak 1 fit')
plot(time_sweeps, data.peak_height_raw(:,2), ...
    'Color', colOrder(2, :), 'DisplayName', 'Peak 2 raw')
plot(time_sweeps, data.peak_height_fit(:,2), '--', ...
    'Color', colOrder(2, :), 'DisplayName', 'Peak 2 fit')
plot(time_sweeps, data.peak_height_fit(:,3), '--', ...
    'Color', colOrder(3, :), 'DisplayName', 'Peak 3 fit')
xlim(xLims)
ylabel('Peak Height')
legend('Show'), legend('boxoff')
hold off

subplot(nRows, nCols, 5, propsAxes{:}), hold on
plot(time_sweeps, data.peak_time_raw(:,1), ...
    'Color', colOrder(1, :), 'DisplayName', 'Peak 1 raw')
plot(time_sweeps, data.peak_time_fit(:,1), '--', ...
    'Color', colOrder(1, :), 'DisplayName', 'Peak 1 fit')
plot(time_sweeps, data.peak_time_raw(:,2), ...
    'Color', colOrder(2, :), 'DisplayName', 'Peak 2 raw')
plot(time_sweeps, data.peak_time_fit(:,2), '--', ...
    'Color', colOrder(2, :), 'DisplayName', 'Peak 2 fit')
plot(time_sweeps, data.peak_time_fit(:,3), '--', ...
    'Color', colOrder(3, :), 'DisplayName', 'Peak 3 fit')
xlim(xLims)
ylabel('Peak Time')
legend('Show'), legend('boxoff')
hold off

% Peak fitting metrics
subplot(nRows, nCols, 6, propsAxes{:}), hold on
plot(time_sweeps, data.fit_rsquared_adj, '-', ...
    'Color', 'k', 'DisplayName', 'Adj. R2')
plot(time_sweeps, data.fit_rmse, '--', ...
    'Color', 'k', 'DisplayName', 'RMSE')
xlim(xLims)
ylabel('Fitting Metric')
xlabel('Sweep Time [mins]')
legend('Show'), legend('boxoff')
hold off

%%

% Produce and save a plot
paperSize = [21.0, 29.7];
set(hFig, 'PaperUnits', 'centimeters')
set(hFig, 'PaperSize', paperSize)
set(hFig, 'PaperPositionMode', 'manual')
set(hFig, 'PaperPosition', [0 0 paperSize])
pause(1) % pause for 1 second to allow plot to resize
print(hFig, fnFull_plot, '-dpdf')

end