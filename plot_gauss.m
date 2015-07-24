function varargout = plot_gauss(data, nSweep)

% Prepare some data/formatting parameters for printing the figure
colOrder = get(0, 'DefaultAxesColorOrder');
tt_close = linspace(data.tt(1), data.tt(end), 1000);
vv_fit_sum = feval(data.fit_object{nSweep}, tt_close);
funGauss = @(aa, bb, cc) aa*exp(-((tt_close-bb)./cc).^2);
vv_fit(:,1) = funGauss(data.fit_object{nSweep}.a1, ...
    data.fit_object{nSweep}.b1, data.fit_object{nSweep}.c1);
vv_fit(:,2) = funGauss(data.fit_object{nSweep}.a2, ...
    data.fit_object{nSweep}.b2, data.fit_object{nSweep}.c2);
vv_fit(:,3) = funGauss(data.fit_object{nSweep}.a3, ...
    data.fit_object{nSweep}.b3, data.fit_object{nSweep}.c3);

hFig = figure;
axes('FontSize', 12)
if nargout > 0
    varargout{1} = hFig;
end

yMax = max(data.data_sweeps(:, nSweep));
yMin = min(data.data_sweeps(:, nSweep));
yRange = yMax - yMin;
yLimFrac = 0.05;
yLims = [yMin-yLimFrac*yRange, yMax+yLimFrac*yRange];

hold on
plot(data.tt, data.data_sweeps(:, nSweep), 'Color', colOrder(1, :))
plot(tt_close, vv_fit_sum, 'Color', colOrder(2, :))
plot(repmat((data.peak_time_raw(nSweep, :)).*ones(1,2), 2, 1), ...
    yLims, ':', 'Color', colOrder(1, :))
plot(repmat((data.peak_time_fit(nSweep, :)).*ones(1,3), 2, 1), ...
    yLims, ':', 'Color', colOrder(2, :))
plot(tt_close, vv_fit, '--', 'Color', colOrder(2, :))
ylim(yLims)
xlabel('Time [ms]')
ylabel('Voltage [mV]')
legend('Maximum in Raw Data', 'Maximum in Gaussian Fit'), legend('boxoff')   % by Zoe
hold off

end