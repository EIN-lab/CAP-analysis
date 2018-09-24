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

function varargout = plot_traces(tt, vv)

% Setup the color values for the
nSweeps = size(vv, 2);
colorVals = jet(nSweeps);

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
