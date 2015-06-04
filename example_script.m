
% Specify the filenames of the MCD files
fnMCD_glucose = '2015_06_02_ON01_AglycExp.mcd';
fnMCD_ramp1 = '2015_06_02_ON01_Stim_Ramp.mcd';
fnMCD_ramp2 = '2015_06_02_ON01_Stim_Ramp0002.mcd';
fnMCD_ramp3 = '2015_06_02_ON01_Stim_Ramp0003.mcd';

% Specify the directory of the MCD files
dirData = 'F:\Data\Optic Nerve Analysis\Dataset 1';

% Specify the path to the DLL
pathDLL = ['C:\Users\Matthew Barrett\Documents\MATLAB\' ...
    'Neuroshare-Library\Matlab_Interface\nsMCDLibrary64.dll'];

% Specify which of the 'segment' channels to load
chToLoad = 2;

% Call the function to analyse the data sets.  For the first data set, the
% user will be prompted to select the baseline and area regions
dataCAP_glucose = analyse_CAP(dirData, fnMCD_glucose, pathDLL, chToLoad);

% For the next datasets, we can use the baseline and area regions from the
% first data set.  So, we extract these here for convenience.
edgesBaseline = dataCAP_glucose.edges_baseline;
edgesArea = dataCAP_glucose.edges_area;

% Call the function to analyse the remaining data sets
dataCAP_ramp1 = analyse_CAP(dirData, fnMCD_ramp1, pathDLL, chToLoad, ...
    edgesBaseline, edgesArea);
dataCAP_ramp2 = analyse_CAP(dirData, fnMCD_ramp2, pathDLL, chToLoad, ...
    edgesBaseline, edgesArea);
dataCAP_ramp3 = analyse_CAP(dirData, fnMCD_ramp3, pathDLL, chToLoad, ...
    edgesBaseline, edgesArea);
