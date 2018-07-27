%% Analysis of MC_rack data (MCD files)

% Input: Filename and path to MCD file
% Output: Saved to directory of the MCD files:
    % 1) Summary data raw and normalized (csv)
    %    (normalization to the defined baseline => idxsNorm)  
    % 2) Data and parameters as matlab file (mat)
    % 3) Summary plots and plot of CAP sweeps (pdf)

% Comment 1: partial CAP area
% intervalLength of partial CAP area can be manually defined within the
% analyse_CAP function (see line 150). e.g. as fixed length of 1ms.

% Comment 2: Gaussian fit
% The Gaussian fit determines the three gaussian distributions that sum up
% to best fit the total CAP area (error functions R2 and RMSE, included in 
% summary output data).
% This is helpfull to follow changes in peak 3 which cannot always be
% defined as a maximum.

% Requires the Neuroshare Library, which can be downloaded from:
%  https://www.multichannelsystems.com/software/neuroshare-library

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Example script for CAP analysis %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Configure analysis

% Specify the path to the DLL (Neuroshare library)
pathDLL = ['/Users/%username%/Documents/MATLAB/nsMCDLibrary_MacOSX_3.7b/'...
   'Matlab/Matlab-Import-Filter/Matlab_Interface/nsMCDLibrary.dylib'];

% Specify the filenames of the MCD file
fnMCD_exp = 'example_Ramp_1_10_25_50Hz.mcd';

% Specify the directory of the MCD file
dirData_exp = '/Users/%username%/Documents/MATLAB/CAP-analysis Frontiers/Example CAP recording';

% Specify which of the 'segment' channels to load and analyze
chToLoad_exp = 10;

% Specify set of sweeps/CAPs to use for normalisation
% (example data: 1 min baseline sampled at 0.4 Hz)
idxsNorm = 1:24;

% Call the function to analyse the data sets, choose if you want to do
% gaussian fitting (doFit true or false).
% threshold for gaussian fitting => adjustments to improve fitting.
doFit = true;
threshGauss = 1.8;

%% Run Analyis, Using pre-defined boundaries
% Analysis can be made using pre-specified bondary condition/selections.
% The following values have been used for the example data
% Parameters for example file: example_Ramp_1_10_25_50Hz.mcd

edgesArea = [115, 300];
edgesAreaPartial = [115, 165];
edgesBaseline = [20, 90];
edgesPeaks = [114,128;133,160];

[dataCAP_exp, dataCAP_exp_norm] = analyse_CAP(dirData_exp, ...
    fnMCD_exp, pathDLL, chToLoad_exp, edgesBaseline, edgesArea, doFit, ...
    [], threshGauss, idxsNorm, edgesAreaPartial, edgesPeaks);

%% Plot and Analyse output results

% Plot a selected sweep
iSweep = 10;
plot(dataCAP_exp_norm.tt, dataCAP_exp_norm.data_sweeps(:, iSweep))
legend(num2str(iSweep));

% Plot the gaussian fit of a selected sweep
if doFit == true
    figure();
    gSweep = 10;
    plot_gauss(dataCAP_exp, gSweep)
end

% Plot single sweeps when changing stimulation frequency
lastB = 24;
listOfSweeps = [lastB, lastB + 55, lastB + 115, lastB + 175, lastB + 235];
listOfTitles = {'BL', '1 Hz', '10 Hz', '25 Hz', '50 Hz'};


Hfig = figure();
title([fnMCD_exp(1:end-4) ' Gaussian fits under different stimulations'], 'Interpreter', 'none')   %%%%%????

nPlots = numel(listOfSweeps);
for iPlot = 1:nPlots
  
    nSweep = listOfSweeps(iPlot);
    subplot(4,2,iPlot)
    plot_gauss(dataCAP_exp, nSweep);
    title(listOfTitles{iPlot})
    axis([1,8,-1,8])
    
end

hold off

% Produce a summary plot
fnFull_plot = fullfile(dirData_exp, ...
    [fnMCD_exp(1:end-4) '_summary']);
plot_summary(dataCAP_exp, fnFull_plot)

% Produce a normalised summary plot
fnFull_plot_norm = fullfile(dirData_exp, ...
    [fnMCD_exp(1:end-4) '_summary_norm']);
plot_summary(dataCAP_exp_norm, fnFull_plot_norm)
