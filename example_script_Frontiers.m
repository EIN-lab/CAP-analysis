%   Copyright (C) 2018  Zoe J. Looser et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

% ======================================================================= %

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

% Prompt user for the path to the DLL (Neuroshare library)
fprintf('Please select the neuroshare library DLL file\n');
[filename, pathname] = uigetfile('*.dylib', ['Pick the Neuroshare', ...
    'library DLL file']);
if isequal(filename,0) || isequal(pathname,0)
    error(['Please install and select neuroshare library. The library', ...
    ' can be downloaded from ', ...
    'https://www.multichannelsystems.com/software/neuroshare-library'])
else
    pathDLL = fullfile(pathname, filename);
end

% Or specify path programmatically
% pathDLL = ['/Users/%username%/Documents/MATLAB/nsMCDLibrary_MacOSX_3.7b/'...
%    'Matlab/Matlab-Import-Filter/Matlab_Interface/nsMCDLibrary.dylib'];

% Specify the filenames of the MCD file
fnMCD_exp = 'example_Ramp_1_10_25_50Hz.mcd';

% Specify the directory of the MCD file
dirData_exp = '/Users/zoelooser/Documents/MATLAB/CAP-analysis Frontiers/Example CAP recording';

% Specify which of the 'segment' channels to load and analyze
chToLoad_exp = 10;

% Specify set of sweeps/CAPs to use for normalisation
% (example data: 1 min baseline sampled at 0.4 Hz)
idxsNorm = 1:24;

doFit = false;

% Threshold for gaussian fitting. Adjust to improve fitting.
threshGauss = 1.8;

%% Run Analysis, Manual selection of boundaries

% Baseline, CAP, partial CAP and peak identification from direct user input
[dataCAP_exp, dataCAP_exp_norm] = analyse_CAP(dirData_exp, ...
    fnMCD_exp, pathDLL, chToLoad_exp, [], [], doFit, ...
    [], threshGauss, idxsNorm);

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

% Produce a summary plot
fnFull_plot = fullfile(dirData_exp, ...
    [fnMCD_exp(1:end-4) '_summary']);
plot_summary(dataCAP_exp, fnFull_plot)

% Produce a normalised summary plot
fnFull_plot_norm = fullfile(dirData_exp, ...
    [fnMCD_exp(1:end-4) '_summary_norm']);
plot_summary(dataCAP_exp_norm, fnFull_plot_norm)
