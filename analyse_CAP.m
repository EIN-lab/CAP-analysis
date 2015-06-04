function data = analyse_CAP(dirData, fnMCD, pathDLL, chToLoad, varargin)

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

% Load the appropriate DLL
[nsresult] = ns_SetLibrary(pathDLL);
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
[nsresult, timeSweeps, dataSweeps] = ns_GetSegmentData(hfile, ...
    idxChannel, 1:nSweeps);
if (nsresult ~= 0)
    error('Segment Data could not be loaded!');
end

%% Perform the calculations

% Calculate the time vector for each sweep, multiplying by 10^3 to make 
% the numbers nicer
nDataPoints = size(dataSweeps, 1);
tt = (0:nDataPoints-1)'.*FileInfo.TimeStampResolution/1E-3;

% Multiply the recording by 10^3 to make the numbers nicer
dataSweeps = 1E3*dataSweeps;

% Find baseline value(s)?
if isempty(edgesBL)
    edgesBL = crop_gui(tt, dataSweeps, 'BASELINE');
end
edgesToUseBL = edgesBL(1):edgesBL(2);

% Find edges where to calculate area
if isempty(edgesArea)
    edgesArea = crop_gui(tt, dataSweeps, 'AREA');
end
edgesToUseArea = edgesArea(1):edgesArea(2);

% Loop through and calculate the area
dataCAP = zeros(nSweeps, 1);
dataBL = dataCAP;
for iSweep = 1:nSweeps
    
    % Calculate the baseline for each sweep
    dataBL(iSweep) = mean(dataSweeps(edgesToUseBL, iSweep));
    
    % Calculate the CAP area for each sweep, subtracting out the baseline
    dataCAP(iSweep) = trapz(tt(edgesToUseArea), ...
        dataSweeps(edgesToUseArea, iSweep) - dataBL(iSweep));
    
end

%% Prepare the outputs

% Package the relevant data into a structure
data.area_CAP = dataCAP;
data.baseline = dataBL;
data.edges_area = edgesArea;
data.edges_baseline = edgesBL;
data.time_sweeps = timeSweeps;

% Prepare some data/formatting parameters for writing the data
delimiter = ',';
hdrNames = {'Sweep_Time', 'Baseline', 'CAP_Area'};
hdrStr = sprintf(['%s' delimiter], hdrNames{:});
strEdgesBL = sprintf(['Edge_Idx_Baseline' delimiter '%d', ...
    delimiter, '%d'], data.edges_baseline(1), data.edges_baseline(2));
strEdgesArea = sprintf(['Edge_Idx_Area' delimiter '%d', ...
    delimiter, '%d'], data.edges_area(1), data.edges_area(2));
dataMat = [data.time_sweeps, data.baseline, data.area_CAP];

% Write the data to a csv file
[~, fnMCD_stripped, ~] = fileparts(fnMCD);
fnFullCSV = fullfile(dirData, [fnMCD_stripped, '.csv']);
dlmwrite(fnFullCSV, strEdgesBL, 'delimiter', '');
dlmwrite(fnFullCSV, strEdgesArea, '-append', 'delimiter', '');
dlmwrite(fnFullCSV, hdrStr(1:end-1), '-append', 'delimiter', '');
dlmwrite(fnFullCSV, dataMat, '-append', 'delimiter', delimiter, ...
    'precision', '%.5f');

end