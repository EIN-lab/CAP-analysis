function idxToUse = crop_gui(tt, vv, strBoundary)

    % Specify how many points to choose
    nPoints = 2;

    % Set up the information messages etc
    strLRTB = 'LEFT and RIGHT';
    strFigTitleTop = sprintf('Select the %s %s boundaries', ...
        strLRTB, strBoundary);
    strMsg = 'Click outside the image to use all the way to that edge.';
    strFigTitle = sprintf('%s\n%s', strFigTitleTop, strMsg);
    
    % Work out the data spacing
    ttSpacing = mean(tt(2:end) - tt(1:end-1));

    % Create the figure
    hFig = figure;
    yMax = max(vv(:));
    yMin = min(vv(:));
    yRange = yMax - yMin;
    yLimFrac = 0.05;
    yLims = [yMin-yLimFrac*yRange, yMax+yLimFrac*yRange];
    plot(tt, vv)
    hold on
    title(strFigTitle)
    ylim(yLims)
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