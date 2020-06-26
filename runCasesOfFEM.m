function [percentageOfErrorPlotLine, calculationTimeOfAdaptiveFEMPlotLine, calculationTimeForRegularFEM] = runCasesOfFEM(initialNumberOfMeshRefinements, minimumBoundaryOfAPosterioriError, step, minOfPercentageError, maxPercentageOfError, isPercentageOfErrorAdaptive)

startTime = posixtime(datetime('now'));

% setup the percentage of error type string based on if the percentage of error is adaptive
percentageOfErrorTypeString = Constants.PERCENTAGE_OF_ERROR;
if isPercentageOfErrorAdaptive
    percentageOfErrorTypeString = Constants.PERCENTAGE_OF_ERROR_MIN_BOUND;
end

% -- create figures --
figureName1 = ['Log-Log plots for ', Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.COLON, num2str(minimumBoundaryOfAPosterioriError)];
figureOfLogLogPlots = figure('Name',figureName1,'NumberTitle','off');

figureName2 = ['Plot of Time of Calculation per ', percentageOfErrorTypeString];
figureOfTimeOfCalculationPerPercentageErrorPlot = figure('Name',figureName2,'NumberTitle','off');
percentageOfErrorPlotLine = [];
calculationTimeOfAdaptiveFEMPlotLine = [];

n = ceil((maxPercentageOfError-minOfPercentageError)/(2*step)+1);
index=1;
for percentageOfErrorMinBound = minOfPercentageError: step: maxPercentageOfError
    [dataOfNumOfElemAndErrors, ~, ~, ~, ~, calculationTimeForAdaptiveFEM] = ...
        solvePDEProblemWithFEM(initialNumberOfMeshRefinements, minimumBoundaryOfAPosterioriError, Constants.ADAPTIVE_FEM, percentageOfErrorMinBound, isPercentageOfErrorAdaptive);
    
    % data for figureOfTimeOfCalculationPerPercentageErrorPlot
    percentageOfErrorPlotLine = [percentageOfErrorPlotLine ; percentageOfErrorMinBound];
    calculationTimeOfAdaptiveFEMPlotLine = [calculationTimeOfAdaptiveFEMPlotLine ; calculationTimeForAdaptiveFEM];
    
    % add the log log plot to figure figureOfLogLogPlots
    figure(figureOfLogLogPlots)
    subplot(2,n,index)
    x = dataOfNumOfElemAndErrors(:,1);
    y = dataOfNumOfElemAndErrors(:,2);
    loglog(x,y)
    grid on
    xlabel(Constants.NUMBER_OF_NODES)
    ylabel(Constants.A_POSTERIORI_ERROR)
    titleLine1 = Constants.ADAPTIVE_FEM_TITLE;
    titleLine2 = [percentageOfErrorTypeString, Constants.COLON, num2str(percentageOfErrorMinBound)];
    title({titleLine1,titleLine2})
    index=index+1;
end

[dataOfNumOfElemAndErrors, ~, ~, ~, ~, calculationTimeForRegularFEM] = solvePDEProblemWithFEM(initialNumberOfMeshRefinements,...
    minimumBoundaryOfAPosterioriError, Constants.REGULAR_FEM);

% create the folder to save results
folderPath = UtilsClass.createFolderPath(minimumBoundaryOfAPosterioriError);

% add the log log plot to figure
figure(figureOfLogLogPlots)
subplot(2,n,index)
x = dataOfNumOfElemAndErrors(:,1);
y = dataOfNumOfElemAndErrors(:,2);
loglog(x,y)
grid on
xlabel(Constants.NUMBER_OF_NODES)
ylabel(Constants.A_POSTERIORI_ERROR)
title(Constants.REGULAR_FEM_TITLE)
filename = [folderPath 'log_log_plots_', percentageOfErrorTypeString, Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError), Constants.FIG_TYPE];
saveas(figureOfLogLogPlots, filename)

% add plot for Time of calculation per percentageOfError to figure figureOfTimeOfCalculationPerPercentageErrorPlot
figure(figureOfTimeOfCalculationPerPercentageErrorPlot)
plot(percentageOfErrorPlotLine, calculationTimeOfAdaptiveFEMPlotLine, 'DisplayName', Constants.ADAPTIVE_FEM_TITLE)
hold on
scatter(1, calculationTimeForRegularFEM, 'filled', 'DisplayName', Constants.REGULAR_FEM_TITLE)
hold off
grid on
xlabel(percentageOfErrorTypeString)
ylabel(Constants.TIME_OF_CALCULATION)
titleLine3 = [Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.COLON, num2str(minimumBoundaryOfAPosterioriError)];
title(titleLine3)
lg = legend;
lg.Location = 'northwest';
filename = [folderPath 'plot_time_per_', percentageOfErrorTypeString, Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError), Constants.FIG_TYPE];
saveas(figureOfTimeOfCalculationPerPercentageErrorPlot, filename)

endTime = posixtime(datetime('now'));
timeOfComputationOfRunCasesOfFem = endTime - startTime
end