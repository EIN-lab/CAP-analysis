%% HFS protocol example
% Specify the path to the DLL
pathDLL = ['/Users/zoelooser/Documents/MATLAB/nsMCDLibrary_MacOSX_3.7b/'...
    'Matlab/Matlab-Import-Filter/Matlab_Interface/nsMCDLibrary.dylib'];

% Specify the filenames of the MCD files
fnMCD_HFS2 = '2015_07_23_N3220_HFS0001.mcd';

% Specify the directory of the MCD files
dirData_HFS2 = '/Users/zoelooser/Desktop/Blub';

% Specify which sweeps to use for normalisation
idxsNorm = 160:180;

% Specify which of the 'segment' channels to load
chToLoad_HFS2 = 10;

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

% Produce summary plots with xlims
xLims = [9 17];
fnFull_plot_zoom = fullfile(dirData_HFS2, ...
    [fnMCD_HFS2(1:end-4) '_summary_zoom']);
plot_summary(dataCAP_HFS2, fnFull_plot_zoom, xLims)
fnFull_plot_norm_zoom = fullfile(dirData_HFS2, ...
    [fnMCD_HFS2(1:end-4) '_summary_norm_zoom']);
plot_summary(dataCAP_HFS2_norm, fnFull_plot_norm_zoom, xLims)

% Plot the gaussian fit
nSweep = 25;
figure, axes('FontSize', 12)
plot_gauss(dataCAP_HFS2, nSweep)

% Plot single sweeps when changing stimulation frequency

% define last sweep of baseline
lastB = 30;  %last Sweep of Baseline
listOfSweeps = [lastB, lastB + 30, lastB + 60, lastB + 90, lastB + 120, lastB + 150, lastB + 151, lastB + 160];
listOfTitles = {{'Last Baseline = ' lastB}, '1 Hz', '5 Hz', '10 Hz', '25 Hz', '50 Hz', '1st Sweep Recovery', '10th Sweep Recovery'};

figure(), hold on

nPlots = 8;
for iPlot = 1:nPlots
  
    nSweep = listOfSweeps(iPlot);
    subplot(4,2,iPlot)
    plot_gauss(dataCAP_HFS2, nSweep);
    title(listOfTitles{iPlot})
    
end
hold off