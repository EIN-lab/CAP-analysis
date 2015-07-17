
% Specify the path to the DLL
pathDLL = ['C:\Users\Matthew Barrett\Documents\MATLAB\' ...
    'Neuroshare-Library\Matlab_Interface\nsMCDLibrary64.dll'];



%% Aglycemia protocol example

% Specify the filenames of the MCD files
fnMCD_glucose = '2015_06_02_ON01_AglycExp.mcd';
fnMCD_ramp1 = '2015_06_02_ON01_Stim_Ramp.mcd';
fnMCD_ramp2 = '2015_06_02_ON01_Stim_Ramp0002.mcd';
fnMCD_ramp3 = '2015_06_02_ON01_Stim_Ramp0003.mcd';

% Specify the directory of the MCD files
dirData_glucose = 'F:\Data\Optic Nerve Analysis\Dataset 1';

% Specify which of the 'segment' channels to load
chToLoad_glucose = 2;

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

%% HFS protocol example

% Specify the filenames of the MCD files
fnMCD_HFS = '2015_07_16_N2689_HFS0001.mcd';

% Specify the directory of the MCD files
dirData_HFS = 'F:\Data\Optic Nerve Analysis\Dataset 2';

% Specify which of the 'segment' channels to load
chToLoad_HFS = 10;

% Call the function to analyse the data sets, this time with fitting
doFit = true;
dataCAP_HFS = analyse_CAP(dirData_HFS, fnMCD_HFS, ...
    pathDLL, chToLoad_HFS, [], [], doFit);

