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