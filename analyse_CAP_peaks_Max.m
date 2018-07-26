function dataPeaksMax = analyse_CAP_peaks_Max(dataCAP, fnBase, varargin)

% Pull out some information about the sweeps
[~, nSweeps] = size(dataCAP.data_sweeps);

% Work out which sweeps to use
sweepsToUse = 1:nSweeps;
hasSweepsToUse = nargin > 1 && ~isempty(varargin{1});
if hasSweepsToUse
    tempSweepsToUse = varargin{1};
    tempSweepsToUse = tempSweepsToUse(:);
    isGoodSweepsToUse = isnumeric(tempSweepsToUse) && ...
        all(isfinite(tempSweepsToUse)) && all(tempSweepsToUse > 1) && ...
        all(tempSweepsToUse <= nSweeps);
    if isGoodSweepsToUse
        sweepsToUse = tempSweepsToUse;
    else
        error('AnalyseCAPPeaks:BadSweepsToUse', ['Something is wrong ' ...
            'with the supplied values for sweepsToUse.  They could be ' ...
            'non-numeric, contain inf/NaN values, contain values ' ...
            'smaller than 1, or contain values larger than the total ' ...
            'number of sweeps available.'])
    end
end

% Extract the time vector
tt = dataCAP.tt;

% Create an average trace
vv = mean(dataCAP.data_sweeps(:, sweepsToUse), 2);

% % Figure out which times to use for the fitting
% strLabel = 'gaussian fitting';
% edgesTime = crop_gui(tt, vv, strLabel);
% idxToUse = edgesTime(1):edgesTime(2);

% Figure out the initial guesses for the peak fitting
nPoints = 3;
strBoundary = 'estimated peak locations';
idxPeaks = crop_gui(tt(idxToUse), vv(idxToUse), strBoundary, ...
    nPoints, strLabel);
pp0 = zeros(9,1);
pp0([1,4,7]) = vv(idxPeaks);
pp0([2,5,8]) = tt(idxPeaks);
pp0([3,6,9]) = [0.12, 0.33, 0.66];

% Fit a sum of 3 gaussians to the curve
modelName = 'gauss3';
fitOptions = fitoptions(modelName, 'StartPoint', pp0);
fitObj = fit(tt(idxToUse), vv(idxToUse), modelName, fitOptions);

%% Prepare the outputs

% Prepare the data structure
dataPeaksMax.edges_fit = edgesTime;
dataPeaksMax.fit = fitObj;
dataPeaksMax.peakTime_manual = tt(idxPeaks)';
dataPeaksMax.peakTime_fit = [fitObj.b1, fitObj.b2, fitObj.b3];
dataPeaksMax.tt = tt;
dataPeaksMax.voltage = vv;

% Save the data
[fnDir, fnName, ~] = fileparts(fnBase);
fnData = fullfile(fnDir, [fnName, '_data_Peaks']);
save(fnData, 'dataPeaks')

% Prepare some data/formatting parameters for writing the data
delimiter = ',';

% Prepare some data/formatting parameters for writing the summary data
hdrNames = {'Time', 'Voltage'};
hdrStrSummary = sprintf(['%s' delimiter], hdrNames{:});
strPeakTimeManual = sprintf(['Peak_Time_Manual' delimiter '%.3f', ...
    delimiter, '%.3f', delimiter, '%.3f'], dataPeaksMax.peakTime_manual(1), ...
    dataPeaksMax.peakTime_manual(2), dataPeaksMax.peakTime_manual(3));
strPeakTimeFit = sprintf(['Peak_Time_Fit' delimiter '%.3f', ...
    delimiter, '%.3f', delimiter, '%.3f'], dataPeaksMax.peakTime_fit(1), ...
    dataPeaksMax.peakTime_fit(2), dataPeaksMax.peakTime_fit(3));
dataMat = [dataPeaksMax.tt, dataPeaksMax.voltage];

% Setup up the filename
[fnDir, fnName, ~] = fileparts(fnBase);
fnFullCSV = fullfile(fnDir, [fnName, '_peaks.csv']);

% Write the summary data to a csv file
dlmwrite(fnFullCSV, strPeakTimeManual, 'delimiter', '');
dlmwrite(fnFullCSV, strPeakTimeFit, '-append', 'delimiter', '');
dlmwrite(fnFullCSV, hdrStrSummary(1:end-1), '-append', 'delimiter', '');
dlmwrite(fnFullCSV, dataMat, '-append', 'delimiter', delimiter, ...
    'precision', '%.5f');

% Prepare some data/formatting parameters for printing the figure
colOrder = get(0, 'DefaultAxesColorOrder');
tt_close = linspace(tt(1), tt(end), 1000);
vv_fit_sum = feval(fitObj, tt_close);
funGauss = @(aa, bb, cc) aa*exp(-((tt_close-bb)./cc).^2);
vv_fit(:,1) = funGauss(fitObj.a1, fitObj.b1, fitObj.c1);
vv_fit(:,2)  = funGauss(fitObj.a2, fitObj.b2, fitObj.c2);
vv_fit(:,3)  = funGauss(fitObj.a3, fitObj.b3, fitObj.c3);

% Plot the 'raw' figure
hFig_raw = figure;
plot_traces(tt, vv);
xlabel('Time [ms]')
ylabel('Voltage [mV]')

% Plot the 'fitted' figure
hFig_fitted = figure;
yLims = plot_traces(tt, vv);
hold on
plot(tt_close, vv_fit_sum, 'Color', colOrder(2, :))
plot(repmat((dataPeaksMax.peakTime_manual').*ones(3,1), 1, 2), yLims, ':', ...
    'Color', colOrder(1, :))
plot(repmat((dataPeaksMax.peakTime_fit').*ones(3,1), 1, 2), yLims, ':', ...
    'Color', colOrder(2, :))
plot(tt_close, vv_fit, '--', 'Color', colOrder(2, :))
hold off
xlabel('Time [ms]')
ylabel('Voltage [mV]')
legend('Raw Data', 'Gaussian Fit')
legend('boxoff')

% Save the figures
save_fig(hFig_raw, fnBase, '_peaks_raw')
save_fig(hFig_fitted, fnBase, '_peaks_fitted')

end

function save_fig(hFig, fnBase, fnExtra)

% Setup up the filename
[fnDir, fnName, ~] = fileparts(fnBase);
fnFull = fullfile(fnDir, [fnName, fnExtra]);

% Format the figure
paperSize = [32, 18];
set(hFig, 'PaperUnits', 'centimeters')
set(hFig, 'PaperSize', paperSize)
set(hFig, 'PaperPositionMode', 'manual')
set(hFig, 'PaperPosition', [0 0 paperSize])
pause(1) % pause for 1 second to allow plot to resize

% Save the figure
print(hFig, fnFull, '-dpdf')

end