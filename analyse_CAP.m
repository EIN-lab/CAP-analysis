function data = analyse_CAP(dirData, fnMCD, pathDLL, chToLoad, varargin)

% Requires the Neuroshare Library, which can be downloaded from:
%   http://www.multichannelsystems.com/downloads/software

%% Parse Arguments

% This optional argument specifies the edges (i.e. indices) of the array to
% use for calculating the baseline
data.edges_baseline = [];
if nargin > 4
    data.edges_baseline = varargin{1};
end

% This optional argument specifies the edges (i.e. indices) of the array to
% use for calculating the CAP area
data.edges_area = [];
if nargin > 5
    data.edges_area = varargin{2};
end

doFit = false;
if nargin > 6
    doFit = varargin{3};
end

data.min_prominence = 0.25;
if nargin > 7
    data.min_prominence = varargin{4};
end

data.thresh_end_gauss = 0.75;
if nargin > 8
    data.thresh_end_gauss = varargin{5};
end

%% Load Files

% Add the NeuroShare directory to the path, if necessary
hasNSPath = exist('ns_SetLibrary.m', 'file');
if ~hasNSPath
    dirNS = fileparts(pathDLL);
    addpath(dirNS)
end

% Load the appropriate DLL
nsresult = ns_SetLibrary(pathDLL);
if (nsresult ~= 0)
    disp('DLL was not found!');
    return
end

% Load data file and display some info about the file
% Open data file. For error messages see "NeuroshareAPI-1-3.pdf"
fnFullMCD = fullfile(dirData, fnMCD);
[nsresult, hfile] = ns_OpenFile(fnFullMCD);
if (nsresult ~= 0)
    error('*.mcd-file did not open!');
end

% Get file information
[nsresult, FileInfo] = ns_GetFileInfo(hfile);
if (nsresult ~= 0)
    disp('File info could not be loaded!');
    return
end

% Load Information of the different entities recorded (electrode, 
% trigger, digital channel)
[nsresult, EntityInfo]  = ns_GetEntityInfo(hfile, 1:1:FileInfo.EntityCount);
if (nsresult ~= 0)
    error('Entity info could not be loaded!');
end

% Find the correct channel to load.  We want only segments (EntityType 3)
% and assume the channel number is the last two digits in the column
% EntityLabel.
maskSegment = [EntityInfo(:).EntityType]' == 3;
maskChannel = ~cellfun(@isempty, regexp({EntityInfo(:).EntityLabel}', ...
    sprintf('%02.0f$', chToLoad)));
maskTotal = maskSegment & maskChannel;
hasTooManyChs = sum(maskTotal) > 1;
if hasTooManyChs
    error('More than one matching channel was found!')
else
    idxChannel = find(maskTotal, 1, 'first');
end

% Load the segment data
nSweeps = EntityInfo(idxChannel).ItemCount;
[nsresult, data.time_sweeps, dataSweepsRaw] = ns_GetSegmentData(hfile, ...
    idxChannel, 1:nSweeps);
if (nsresult ~= 0)
    error('Segment Data could not be loaded!');
end

%% Perform the calculations

% Calculate the time vector for each sweep, multiplying by 10^3 to make 
% the numbers nicer
nDataPoints = size(dataSweepsRaw, 1);
data.tt = (0:nDataPoints-1)'.*FileInfo.TimeStampResolution/1E-3;

% Multiply the recording by 10^3 to make the numbers nicer
dataSweepsRaw = 1E3*dataSweepsRaw;

% Find baseline value(s)?
if isempty(data.edges_baseline)
    data.edges_baseline = crop_gui(data.tt, dataSweepsRaw, 'BASELINE');
end
edgesToUseBL = data.edges_baseline(1):data.edges_baseline(2);

% Calculate the baseline for each sweep, and baseline correct the data
data.baseline = mean(dataSweepsRaw(edgesToUseBL, :), 1)';
data.data_sweeps = bsxfun(@minus, dataSweepsRaw, data.baseline');

% Find edges where to calculate area
if isempty(data.edges_area)
    data.edges_area = crop_gui(data.tt, data.data_sweeps, 'AREA');
end
idxToUseArea = data.edges_area(1):data.edges_area(2);

% Set up initial guesses for the gaussian peak fitting
pp0 = zeros(9,1);
pp0([1,4,7]) = [4, 4, 2.5];         % estimated peak heights
pp0([2,5,8]) = [2.3, 2.7, 3.4];     % estimated peak latencies
pp0([3,6,9]) = [0.12, 0.33, 0.66];  % estimated peak widths
modelName = 'gauss3';
fitOptions = fitoptions(modelName, 'StartPoint', pp0);

% Preallocate memory for variables
data.area_CAP = zeros(nSweeps, 1);
data.peak_time_raw = zeros(nSweeps, 2);
data.peak_height_raw = data.peak_time_raw;
data.edge_fit = data.area_CAP;
data.peak_time_fit = zeros(nSweeps, 3);
data.peak_height_fit = data.peak_time_fit;
data.peak_area_fit = data.peak_time_fit;
data.peak_width_fit = data.peak_time_fit;
data.fit_rsquared_adj = data.area_CAP;
data.fit_rmse = data.area_CAP;
data.fit_object = cell(nSweeps, 1);

% Loop through and calculate the required metrics
for iSweep = 1:nSweeps
    
    % Calculate the CAP area for each sweep, subtracting out the baseline,
    % and taking the absolute value to ensure negative areas are also
    % counted as positive
    data.area_CAP(iSweep) = trapz(data.tt(idxToUseArea), ...
        abs(data.data_sweeps(idxToUseArea, iSweep)));
    
    if doFit
    
        % Find the 'raw' peaks for each CAP
        [peakHeightTemp, peakLocsRaw] = findpeaks(...
            data.data_sweeps(idxToUseArea, iSweep), ...
            'MinPeakProminence', data.min_prominence);
        nPeaks = length(peakLocsRaw);
        if nPeaks > 0
            nPeaks = min([nPeaks, 2]);
            peakLocsAdj = data.edges_area(1) + peakLocsRaw - 1;
            data.peak_time_raw(iSweep, 1:nPeaks) = ...
                data.tt(peakLocsAdj(1:nPeaks));
            data.peak_height_raw(iSweep, 1:nPeaks) = peakHeightTemp(1:nPeaks);
        else
            warning('AnalyseCAP:NoPeaks', ['No peaks found in sweep %d :-( . ' ...
                'This may influence the fitting process.'], iSweep)
        end
    
        % Figure out where to end the gaussian fit (when the peak first 
        % drops below a threshold value mV
        hasPeak2 = data.peak_time_raw(iSweep, 2) > 0;
        if hasPeak2
            idxPeakStart = peakLocsAdj(2);
        else
            idxPeakStart = find(data.tt > 2.5, 1,  'first');
        end
        idxGaussEnd = find(data.data_sweeps(idxPeakStart:end, iSweep) < ...
            data.thresh_end_gauss, 1, 'first');
        
        % Check that we have enough points
        minNPoints = 30;
        hasEnoughPoints = idxGaussEnd > minNPoints;
        if ~hasEnoughPoints
            warning('AnalyseCAP:NotEnoughPoints', ['There were less ' ...
                'than %d points found for the fitting.  Something ' ...
                'weird is probably happening.  Try looking at the ' ...
                'traces, or else see Matt.'], minNPoints)
        end
        
        % Fit a sum of 3 gaussians to the curve
        idxToUseFit = (1:idxGaussEnd) + idxPeakStart - 1;
        data.edge_fit(iSweep) = idxToUseFit(end);
        [data.fit_object{iSweep}, gof] = fit(...
            data.tt(idxToUseFit), data.data_sweeps(idxToUseFit, iSweep), ...
            modelName, fitOptions);

        % Extract information from the gaussian fit
        data.peak_time_fit(iSweep, :) = [data.fit_object{iSweep}.b1, ...
            data.fit_object{iSweep}.b2, data.fit_object{iSweep}.b3];
        data.peak_height_fit(iSweep, :) = [data.fit_object{iSweep}.a1, ...
            data.fit_object{iSweep}.a2, data.fit_object{iSweep}.a3];
        data.peak_width_fit(iSweep, :) = abs([data.fit_object{iSweep}.c1, ...
            data.fit_object{iSweep}.c2, data.fit_object{iSweep}.c3]);
        data.peak_area_fit(iSweep, :) = data.peak_width_fit(iSweep, :).* ...
            data.peak_height_fit(iSweep, :).*sqrt(2*pi);
        data.fit_rsquared_adj(iSweep) = gof.adjrsquare;
        data.fit_rmse(iSweep) = gof.rmse;
        
    end
    
end

%% Prepare the outputs

% Sort the structure fields into alphabetical order
data = orderfields(data);

% Prepare some data/formatting parameters for writing the data
delimiter = ',';
[~, fnMCD_stripped, ~] = fileparts(fnMCD);

% Save the data
fnData = fullfile(dirData, [fnMCD_stripped, '_data']);
save(fnData, 'data')

% Prepare some data/formatting parameters for writing the summary data
fnFullCSV_summary = fullfile(dirData, [fnMCD_stripped, '_summary.csv']);
hdrNames = {'Sweep_Time', 'Baseline', 'CAP_Area', 'Peak_Time_1_Raw', ...
    'Peak_Time_2_Raw', 'Peak_Height_1_Raw', 'Peak_Height_2_Raw', ...
    'Peak_Time_1_Fit', 'Peak_Time_2_Fit', ...
    'Peak_Time_3_Fit', 'Peak_Height_1_Fit', 'Peak_Height_2_Fit', ...
    'Peak_Height_3_Fit', 'Peak_Width_1_Fit', 'Peak_Width_2_Fit', ...
    'Peak_Width_3_Fit', 'Peak_Area_1_Fit', 'Peak_Area_2_Fit', ...
    'Peak_Area_3_Fit', 'Fit_Edge', 'Fit_RSquared_Adj', 'Fit_RMSE'};
hdrStrSummary = sprintf(['%s' delimiter], hdrNames{:});
strEdgesBL = sprintf(['Edge_Idx_Baseline' delimiter '%d', ...
    delimiter, '%d'], data.edges_baseline(1), data.edges_baseline(2));
strEdgesArea = sprintf(['Edge_Idx_Area' delimiter '%d', ...
    delimiter, '%d'], data.edges_area(1), data.edges_area(2));
dataMat = [data.time_sweeps, data.baseline, data.area_CAP, ...
    data.peak_time_raw, data.peak_height_raw, data.peak_time_fit, ...
    data.peak_height_fit, data.peak_width_fit, data.peak_area_fit, ...
    data.edge_fit, data.fit_rsquared_adj, data.fit_rmse];

% Prepare some data/formatting parameters for writing the summary data
hdrStrRaw = ['time' delimiter sprintf(['sweep_%d' delimiter], 1:nSweeps)];
fnFullCSV_raw = fullfile(dirData, [fnMCD_stripped, '_sweeps.csv']);

% Write the summary data to a csv file
dlmwrite(fnFullCSV_summary, strEdgesBL, 'delimiter', '');
dlmwrite(fnFullCSV_summary, strEdgesArea, '-append', 'delimiter', '');
dlmwrite(fnFullCSV_summary, hdrStrSummary(1:end-1), '-append', ...
    'delimiter', '');
dlmwrite(fnFullCSV_summary, dataMat, '-append', 'delimiter', delimiter, ...
    'precision', '%.5f');

% Write the raw traces data to a csv file
dlmwrite(fnFullCSV_raw, hdrStrRaw(1:end-1), 'delimiter', '');
dlmwrite(fnFullCSV_raw, [data.tt, data.data_sweeps], '-append', ...
    'delimiter', delimiter, 'precision', '%.5f');

% Prepare some data/formatting parameters for printing the figure
paperSize = [32, 18];
fnFull_plot = fullfile(dirData, [fnMCD_stripped, '_sweeps']);

% Produce and save a plot
hFig = figure;
plot_traces(data.tt, data.data_sweeps)
xlabel('Time [ms]')
ylabel('Voltage [mV]')
set(hFig, 'PaperUnits', 'centimeters')
set(hFig, 'PaperSize', paperSize)
set(hFig, 'PaperPositionMode', 'manual')
set(hFig, 'PaperPosition', [0 0 paperSize])
pause(1) % pause for 1 second to allow plot to resize
print(hFig, fnFull_plot, '-dpdf')

end
