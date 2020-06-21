
startTime = posixtime(datetime('now'));

% The modes of FEM
ADAPTIVE_FEM = 1;
REGULAR_FEM = 2;

% Constant strings for naming
PERCENTAGE_OF_ERROR_MIN_BOUND = 'percentageOfErrorMinBound';
PERCENTAGE_OF_ERROR = 'percentageOfError';
MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR = 'minimumBoundaryOfAPosterioriError';
ADAPTIVE_FEM_TITLE = 'Adaptive FEM';
REGULAR_FEM_TITLE = 'Regular FEM';
ADAPTIVE_FEM_TITLE_WITH_DASH = 'Adaptive_FEM';
REGULAR_FEM_TITLE_WITH_DASH = 'Regular_FEM';
DASH = '_';
COLON = ': ';
COMMA = ', ';
LEFT_SLASH = '\';
JPG_TYPE = '.jpg';
FIG_TYPE = '.fig';
FOLDER_NAME = 'results';

% -- initial data in order to begin calculations --
initialNumberOfMeshRefinements = 1;
minimumBoundaryOfAPosterioriError = 0.8;
step = 0.1;
minOfPercentageError = 0.1;
maxPercentageOfError = 1;

% -- create figures --
figureName1 = ['Log-Log plots for minimumBoundaryOfAPosterioriError: ', num2str(minimumBoundaryOfAPosterioriError)];
figureOfLogLogPlots = figure('Name',figureName1,'NumberTitle','off');

figureName2 = 'Plot of CalculationTime per PercentageOfError';
figureOfTimeOfCalculationPerPercentageErrorPlot = figure('Name',figureName2,'NumberTitle','off');
percentageOfErrorPlotLine = [];
calculationTimeOfAdaptiveFEMPlotLine = [];

n = ceil((maxPercentageOfError-minOfPercentageError)/(2*step)+1);
index=1;
for percentageOfErrorMinBound = minOfPercentageError: step: maxPercentageOfError
    [dataOfNumOfElemAndErrors, ~, ~, ~, ~, calculationTime] = solvePDEProblemWithFEM(initialNumberOfMeshRefinements,...
        minimumBoundaryOfAPosterioriError, ADAPTIVE_FEM, percentageOfErrorMinBound, false);
    
    % data for figureOfTimeOfCalculationPerPercentageErrorPlot
    percentageOfErrorPlotLine = [percentageOfErrorPlotLine ; percentageOfErrorMinBound];
    calculationTimeOfAdaptiveFEMPlotLine = [calculationTimeOfAdaptiveFEMPlotLine ; calculationTime];
    
    % add the log log plot to figure figureOfLogLogPlots
    figure(figureOfLogLogPlots)
    subplot(2,n,index)
    x = dataOfNumOfElemAndErrors(:,1);
    y = dataOfNumOfElemAndErrors(:,2);
    loglog(x,y)
    grid on
    xlabel('number of nodes')
    ylabel('aPosterioriError')
    titleLine1 = ADAPTIVE_FEM_TITLE;
    titleLine2 = ['percentageOfErrorMinBound: ',num2str(percentageOfErrorMinBound)];
    title({titleLine1,titleLine2})
    index=index+1;
end

[dataOfNumOfElemAndErrors, ~, ~, ~, ~, ~] = solvePDEProblemWithFEM(initialNumberOfMeshRefinements,...
    minimumBoundaryOfAPosterioriError, REGULAR_FEM, false);

% create the folder to save results
folderName = [FOLDER_NAME, LEFT_SLASH, MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, DASH, num2str(minimumBoundaryOfAPosterioriError)];
mkdir(folderName)
folderPath = [pwd, LEFT_SLASH, folderName, LEFT_SLASH];

% add the log log plot to figure
figure(figureOfLogLogPlots)
subplot(2,n,index)
x = dataOfNumOfElemAndErrors(:,1);
y = dataOfNumOfElemAndErrors(:,2);
loglog(x,y)
grid on
xlabel('number of nodes')
ylabel('aPosterioriError')
title(REGULAR_FEM_TITLE)
filename = [folderPath 'log_log_plots_minimumBoundaryOfAPosterioriError_', num2str(minimumBoundaryOfAPosterioriError), FIG_TYPE];
saveas(figureOfLogLogPlots, filename)

% add plot of calculationTime per percentageOfError to figureOfTimeOfCalculationPerPercentageErrorPlot
figure(figureOfTimeOfCalculationPerPercentageErrorPlot)
plot(percentageOfErrorPlotLine,calculationTimeOfAdaptiveFEMPlotLine)
grid on
xlabel('percentageOfError')
ylabel('calculationTime')
titleLine3 = ['Plot for minimumBoundaryOfAPosterioriError: ', num2str(minimumBoundaryOfAPosterioriError)];
title(titleLine3)
filename = [folderPath 'plot_calculationTime_per_percentageOfError_minimumBoundaryOfAPosterioriError_', num2str(minimumBoundaryOfAPosterioriError), FIG_TYPE];
saveas(figureOfTimeOfCalculationPerPercentageErrorPlot, filename)

endTime = posixtime(datetime('now'));
totalTimeOfComputation = endTime - startTime