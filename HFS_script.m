%% HFS protocol example
% Specify the path to the DLL
pathDLL = ['/Users/zoelooser/Documents/MATLAB/nsMCDLibrary_MacOSX_3.7b/'...
    'Matlab/Matlab-Import-Filter/Matlab_Interface/nsMCDLibrary.dylib'];

% Specify the filenames of the MCD files
fnMCD_HFS2 = '2015_07_23_N1918_HFS0001.mcd';

% Specify the directory of the MCD files
dirData_HFS2 = '/Users/zoelooser/Desktop/Weber_Lab/DATA HFS/THYATP/2015_07_23_N1918';

% Specify which sweeps to use for normalisation
idxsNorm = 1:3;

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
xLims = [1, 6];
fnFull_plot_zoom = fullfile(dirData_HFS2, ...
    [fnMCD_HFS2(1:end-4) '_summary_zoom']);
plot_summary(dataCAP_HFS2, fnFull_plot_zoom, xLims)
fnFull_plot_norm_zoom = fullfile(dirData_HFS2, ...
    [fnMCD_HFS2(1:end-4) '_summary_norm_zoom']);
plot_summary(dataCAP_HFS2_norm, fnFull_plot_norm_zoom, xLims)

% % Plot the gaussian fit
% nSweep = 25;
% figure, axes('FontSize', 12)
% plot_gauss(dataCAP_HFS2, nSweep)


% Plot single sweeps when changing stimulation frequency
% define last sweep of baseline
lastB = 3;  %last Sweep of Baseline
listOfSweeps = [lastB, lastB + 30, lastB + 60, lastB + 90, lastB + 120, lastB + 150, lastB + 151, lastB + 160];
listOfTitles = {{'Last Baseline = ' lastB}, '1 Hz', '5 Hz', '10 Hz', '25 Hz', '50 Hz', '1st Sweep Recovery', '10th Sweep Recovery'};

figure(19), hold on
Hfig = figure(19);

nPlots = 8;
for iPlot = 1:nPlots
  
    nSweep = listOfSweeps(iPlot);
    subplot(4,2,iPlot)
    plot_gauss(dataCAP_HFS2, nSweep);
    title(listOfTitles{iPlot})
    
end

title('Gaussian fits under different stimulations')

hold off

% Produce and save a plot
Hname = [fnMCD_HFS2(1:end-4), '_Gauss_sweeps.pdf'];

paperSize = [21.0, 29.7];
set(Hfig, 'PaperUnits', 'centimeters')
set(Hfig, 'PaperSize', paperSize)
set(Hfig, 'PaperPositionMode', 'manual')
set(Hfig, 'PaperPosition', [0 0 paperSize])
pause(1) % pause for 1 second to allow plot to resize
print(Hfig, Hname, '-dpdf')
movefile(Hname, dirData_HFS2)


% Peak Height depending on stimulation frequency

frequ = [0.1, 1, 5, 10, 25, 50, 60];

nPeak = 7;
peakHeight1 = zeros(1, nPeak);   %creates matrix with zeros which is "filled up" in the loop
peakHeight2 = zeros(1, nPeak);
peakHeight3 = zeros(1, nPeak);
for iPeak = 1:nPeak
    
    peakHeight1(iPeak) = dataCAP_HFS2_norm.peak_height_fit(listOfSweeps(iPeak),1);
    peakHeight2(iPeak) = dataCAP_HFS2_norm.peak_height_fit(listOfSweeps(iPeak),2);    
    peakHeight3(iPeak) = dataCAP_HFS2_norm.peak_height_fit(listOfSweeps(iPeak),3);
    
end

figure(20), hold on
Hfig2 = figure(20);
plot(frequ, peakHeight1, 'o-', 'MarkerSize', 5)
plot(frequ, peakHeight2, 'o-', 'MarkerSize', 5)
plot(frequ, peakHeight3, 'o-', 'MarkerSize', 5)

set(gca,'XTick',frequ)
set(gca,'XTickLabel',[0.1, 1, 5, 10, 25, 50, 0.1]);

ylabel('Peak Height fit [mV]'), xlabel('Stimulation Frequency')
title('Peak Heights under HFS')
legend('Peak 1', 'Peak 2', 'Peak 3')
hold off

% Produce and save a plot
Hname2 = [fnMCD_HFS2(1:end-4), '_PeakHeights.pdf'];
print(Hfig2, Hname2, '-dpdf')
movefile(Hname2, dirData_HFS2)