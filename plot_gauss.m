%   Copyright (C) 2018  Zoe J. Looser et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

% ======================================================================= %

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

% hFig = figure;
% axes('FontSize', 12)
%if nargout > 0
%    varargout{1} = hFig;
% end
varargout{1} = [];

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
legend('Raw Data', 'Gaussian Fit'), legend('boxoff')
hold off

end
