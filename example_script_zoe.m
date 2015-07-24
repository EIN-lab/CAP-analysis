
% Specify the path to the DLL
pathDLL = ['/Users/zoelooser/Documents/MATLAB/nsMCDLibrary_MacOSX_3.7b/'...
    'Matlab/Matlab-Import-Filter/Matlab_Interface/nsMCDLibrary.dylib'];



%% Aglycemia protocol example

% Specify the filenames of the MCD files
fnMCD_glucose = '2015_07_21_N3219_HFS.mcd';
% fnMCD_ramp1 = '2015_07_14_N3790_Ramp.mcd';
% fnMCD_ramp2 = '2015_07_14_N3790_Ramp0001.mcd';
% fnMCD_ramp3 = '2015_07_14_N3790_Ramp0002.mcd';

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

%% HFS protocol example

% Specify the filenames of the MCD files
fnMCD_HFS = '2015_07_23_N1918_HFS0001.mcd';

% Specify the directory of the MCD files
dirData_HFS = '/Users/zoelooser/Desktop/Weber_Lab/DATA HFS/THYATP/2015_07_23_N1918';

% Specify which of the 'segment' channels to load
chToLoad_HFS = 10;

% Call the function to analyse the data sets, this time with fitting
doFit = true;
dataCAP_HFS = analyse_CAP(dirData_HFS, fnMCD_HFS, ...
    pathDLL, chToLoad_HFS, [], [], doFit);


%% HFS protocol example 2

% Specify the filenames of the MCD files
fnMCD_HFS2 = '2015_07_23_N3220_HFS0001.mcd';

% Specify the directory of the MCD files
dirData_HFS2 = '/Users/zoelooser/Desktop/Blub';

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
