
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

%% HFS protocol example 1

% Specify the filenames of the MCD files
fnMCD_HFS = '2015_07_16_N2689_HFS0001.mcd';

% Specify the directory of the MCD files
dirData_HFS = 'F:\Data\Optic Nerve Analysis\Dataset 2';

% Specify which of the 'segment' channels to load
chToLoad_HFS = 10;

% Call the function to analyse the data sets, this time with fitting
doFit1 = true;
dataCAP_HFS1 = analyse_CAP(dirData_HFS, fnMCD_HFS, ...
    pathDLL, chToLoad_HFS, [], [], doFit1);

%% HFS protocol example 2

% Specify the filenames of the MCD files
fnMCD_HFS2 = '2015_07_17_N2690_HFS0001.mcd';

% Specify the directory of the MCD files
dirData_HFS2 = 'F:\Data\Optic Nerve Analysis\Dataset 3';

% Specify which of the 'segment' channels to load
chToLoad_HFS2 = 10;

% Specify which sweeps to use for normalisation
idxsNorm = 10:30;

% Call the function to analyse the data sets, this time with fitting
doFit2 = true;
[dataCAP_HFS2, dataCAP_HFS2_norm] = analyse_CAP(dirData_HFS2, ...
    fnMCD_HFS2, pathDLL, chToLoad_HFS2, [], [], doFit2, [], [], idxsNorm);

% Produce a summary plot
fnFull_plot = fullfile(dirData_HFS2, ...
    [fnMCD_HFS2(1:end-4) '_summary']);
plot_summary(dataCAP_HFS2, fnFull_plot)

% Produce a normalised summary plot
fnFull_plot_norm = fullfile(dirData_HFS2, ...
    [fnMCD_HFS2(1:end-4) '_summary_norm']);
plot_summary(dataCAP_HFS2_norm, fnFull_plot_norm)

% Plot the gaussian fit
nSweep = 50;
plot_gauss(dataCAP_HFS2, nSweep)
