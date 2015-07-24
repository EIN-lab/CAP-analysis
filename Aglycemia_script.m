
%% Aglycemia protocol example

% Specify the path to the DLL
pathDLL = ['/Users/zoelooser/Documents/MATLAB/nsMCDLibrary_MacOSX_3.7b/'...
    'Matlab/Matlab-Import-Filter/Matlab_Interface/nsMCDLibrary.dylib'];


% Specify the filenames of the MCD files
fnMCD_glucose = '2015_07_21_N3219_HFS.mcd';
fnMCD_ramp1 = '2015_07_14_N3790_Ramp.mcd';
fnMCD_ramp2 = '2015_07_14_N3790_Ramp0001.mcd';
fnMCD_ramp3 = '2015_07_14_N3790_Ramp0002.mcd';

% Specify the directory of the MCD files
dirData_glucose = '/Users/zoelooser/Desktop/collection of recordings/THYATP/N3219';

% Specify which of the 'segment' channels to load
chToLoad_glucose = 10;

% Call the function to analyse the data sets.  For the first data set, the
% user will be prompted to select the baseline and area regions
dataCAP_glucose = analyse_CAP(dirData_glucose, fnMCD_glucose, ...
    pathDLL, chToLoad_glucose);

% Call the function to find the peak latencies
sweepsToUse_glucose = 10:30;
fnBase_glucose = fullfile(dirData_glucose, fnMCD_glucose);
dataPeaks_glucose = analyse_CAP_peaks(dataCAP_glucose, ...
    fnBase_glucose, sweepsToUse_glucose);

% For the next datasets, we can use the baseline and area regions from the
% first data set.  So, we extract these here for convenience.
edgesBaseline = dataCAP_glucose.edges_baseline;
edgesArea = dataCAP_glucose.edges_area;

% Call the function to analyse the remaining data sets
dataCAP_ramp1 = analyse_CAP(dirData_glucose, fnMCD_ramp1, ...
    pathDLL, chToLoad_glucose, ...
    edgesBaseline, edgesArea);
dataCAP_ramp2 = analyse_CAP(dirData_glucose, fnMCD_ramp2, ...
    pathDLL, chToLoad_glucose, ...
    edgesBaseline, edgesArea);
dataCAP_ramp3 = analyse_CAP(dirData_glucose, fnMCD_ramp3, ...
    pathDLL, chToLoad_glucose, ...
    edgesBaseline, edgesArea);
