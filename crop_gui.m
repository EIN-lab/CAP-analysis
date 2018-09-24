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

function idxToUse = crop_gui(tt, vv, strBoundary, varargin)

    % Specify how many points to choose
    nPoints = 2;
    if nargin > 3
        nPoints = varargin{1};
    end

    strLRTB = 'LEFT and RIGHT';
    if nargin > 4
        strLRTB =  varargin{2};
    end

    % Set up the information messages etc
    strFigTitleTop = sprintf('Select the %s %s boundaries', ...
        strLRTB, strBoundary);
    strMsg = 'Click outside the image to use all the way to that edge.';
    strFigTitle = sprintf('%s\n%s', strFigTitleTop, strMsg);

    % Work out the data spacing
    ttSpacing = mean(tt(2:end) - tt(1:end-1));

    % Create the figure
    hFig = figure;
    yLims = plot_traces(tt, vv);
    hold on
    title(strFigTitle)
    hold off

    % Preallocate memory
    x = zeros(1, nPoints);
    y = x;
    idxToUse = x;
    for iPoint = 1:nPoints

        % receive points from user
        [x(iPoint), y(iPoint)] = ginput(1);

        % Adjust points to ensure they are within the image range
        outsideImageRight = x(iPoint) > max(tt);
        outsideImageLeft = x(iPoint) < min(tt);
        if outsideImageRight
            x(iPoint) = max(tt);
        elseif outsideImageLeft
            x(iPoint) = min(tt);
        end

        % Find the index of the point we picked
        idxToUse(iPoint) = round(x(iPoint)/ttSpacing) + 1;

        % Plot a line to show what was picked
        hold on
        plot(x(iPoint).*[1 1], yLims, 'r--')
        refresh
        pause(.01);
        hold off

    end;

    % Close the figure
    close(hFig)

    % Sort and return the points
    idxToUse = sort(idxToUse);

end
