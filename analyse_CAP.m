function dataCAP = analyse_CAP(dirData, fnMCD, pathDLL, chToLoad, varargin)

% Requires the Neuroshare Library, which can be downloaded from:
%   http://www.multichannelsystems.com/downloads/software

%% Parse Arguments

% This optional argument specifies the edges (i.e. indices) of the array to
% use for calculating the baseline
edgesBL = [];
if nargin > 4
    edgesBL = varargin{1};
end

% This optional argument specifies the edges (i.e. indices) of the array to
% use for calculating the CAP area
edgesArea = [];
if nargin > 5
    edgesArea = varargin{2};
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
[nsresult, timeSweeps, dataSweepsRaw] = ns_GetSegmentData(hfile, ...
    idxChannel, 1:nSweeps);
if (nsresult ~= 0)
    error('Segment Data could not be loaded!');
end

%% Perform the calculations

% Calculate the time vector for each sweep, multiplying by 10^3 to make 
% the numbers nicer
nDataPoints = size(dataSweepsRaw, 1);
tt = (0:nDataPoints-1)'.*FileInfo.TimeStampResolution/1E-3;

% Multiply the recording by 10^3 to make the numbers nicer
dataSweepsRaw = 1E3*dataSweepsRaw;

% Find baseline value(s)?
if isempty(edgesBL)
    edgesBL = crop_gui(tt, dataSweepsRaw, 'BASELINE');
end
edgesToUseBL = edgesBL(1):edgesBL(2);

% Calculate the baseline for each sweep, and baseline correct the data
dataBL = mean(dataSweepsRaw(edgesToUseBL, :), 1)';
dataSweeps = bsxfun(@minus, dataSweepsRaw, dataBL');

% Find edges where to calculate area
if isempty(edgesArea)
    edgesArea = crop_gui(tt, dataSweeps, 'AREA');
end
edgesToUseArea = edgesArea(1):edgesArea(2);

% Loop through and calculate the area
rawdataCAP = zeros(nSweeps, 1);
for iSweep = 1:nSweeps
    
    % Calculate the CAP area for each sweep, subtracting out the baseline,
    % and taking the absolute value to ensure negative areas are also
    % counted as positive
    rawdataCAP(iSweep) = trapz(tt(edgesToUseArea), ...
        abs(dataSweeps(edgesToUseArea, iSweep) - dataBL(iSweep)));
    
end

%% Prepare the outputs

% Package the relevant data into a structure
dataCAP.area_CAP = rawdataCAP';
dataCAP.baseline = dataBL';
dataCAP.data_sweeps = dataSweeps;
dataCAP.edges_area = edgesArea;
dataCAP.edges_baseline = edgesBL;
dataCAP.time_sweeps = timeSweeps';
dataCAP.tt = tt;

% Prepare some data/formatting parameters for writing the data
delimiter = ',';
[~, fnMCD_stripped, ~] = fileparts(fnMCD);

% Save the data
fnData = fullfile(dirData, [fnMCD_stripped, '_data_CAP']);
save(fnData, 'dataCAP')

% Prepare some data/formatting parameters for writing the summary data
fnFullCSV_summary = fullfile(dirData, [fnMCD_stripped, '_summary.csv']);
hdrNames = {'Sweep_Time', 'Baseline', 'CAP_Area'};
hdrStrSummary = sprintf(['%s' delimiter], hdrNames{:});
strEdgesBL = sprintf(['Edge_Idx_Baseline' delimiter '%d', ...
    delimiter, '%d'], dataCAP.edges_baseline(1), dataCAP.edges_baseline(2));
strEdgesArea = sprintf(['Edge_Idx_Area' delimiter '%d', ...
    delimiter, '%d'], dataCAP.edges_area(1), dataCAP.edges_area(2));
dataMat = [dataCAP.time_sweeps, dataCAP.baseline, dataCAP.area_CAP];

% Prepare some data/formatting parameters for writing the summary data
hdrStrRaw = ['time' delimiter sprintf(['sweep_%d' delimiter], 1:nSweeps)];
fnFullCSV_raw = fullfile(dirData, [fnMCD_stripped, '_sweeps.csv']);

% Write the summary data to a csv file
dlmwrite(fnFullCSV_summary, strEdgesBL, 'delimiter', '');
dlmwrite(fnFullCSV_summary, strEdgesArea, '-append', 'delimiter', '');
dlmwrite(fnFullCSV_summary, hdrStrSummary(1:end-1), '-append', 'delimiter', '');
dlmwrite(fnFullCSV_summary, dataMat, '-append', 'delimiter', delimiter, ...
    'precision', '%.5f');

% Write the raw traces data to a csv file
dlmwrite(fnFullCSV_raw, hdrStrRaw(1:end-1), 'delimiter', '');
dlmwrite(fnFullCSV_raw, [tt, dataSweeps], '-append', 'delimiter', delimiter, ...
    'precision', '%.5f');

% Prepare some data/formatting parameters for printing the figure
paperSize = [32, 18];
fnFull_plot = fullfile(dirData, [fnMCD_stripped, '_sweeps']);

% Produce and save a plot
hFig = figure;
plot_traces(tt, dataSweeps)
xlabel('Time [ms]')
ylabel('Voltage [mV]')
set(hFig, 'PaperUnits', 'centimeters')
set(hFig, 'PaperSize', paperSize)
set(hFig, 'PaperPositionMode', 'manual')
set(hFig, 'PaperPosition', [0 0 paperSize])
pause(1) % pause for 1 second to allow plot to resize
print(hFig, fnFull_plot, '-dpdf')

end