
startTime = posixtime(datetime('now'));

% -- initial data in order to begin calculations --
initialNumberOfMeshRefinements = 1;
minimumBoundaryOfAPosterioriError = 0.05;
step = 0.01;
minOfPercentageError = 0.1;
maxPercentageOfError = 1;

[percentageOfErrorPlotLine1, calculationTimeOfAdaptiveFEMPlotLine1, calculationTimeForRegularFEM1] = runCasesOfFEM(initialNumberOfMeshRefinements,...
    minimumBoundaryOfAPosterioriError, step, minOfPercentageError, maxPercentageOfError, false);

[percentageOfErrorPlotLine2, calculationTimeOfAdaptiveFEMPlotLine2, calculationTimeForRegularFEM2] = runCasesOfFEM(initialNumberOfMeshRefinements,...
    minimumBoundaryOfAPosterioriError, step, minOfPercentageError, maxPercentageOfError, true);

% create the folder to save results
folderPath = UtilsClass.createFolderPath(minimumBoundaryOfAPosterioriError);

% add plot for Time of calculation per percentageOfError to figure figureOfTimeOfCalculationPerPercentageErrorPlot
figureName = 'Comparison of different FEM types';
figureOfTimeOfCalculationPerPercentageErrorPlot = figure('Name',figureName,'NumberTitle','off');

plot(percentageOfErrorPlotLine1,calculationTimeOfAdaptiveFEMPlotLine1, 'DisplayName','Adaptive FEM isPercentageOfErrorAdaptive: false')
hold on
plot(percentageOfErrorPlotLine2,calculationTimeOfAdaptiveFEMPlotLine2, 'DisplayName', 'Adaptive FEM isPercentageOfErrorAdaptive: true')
scatter(1, calculationTimeForRegularFEM1,'filled', 'DisplayName', Constants.REGULAR_FEM_TITLE)
scatter(1, calculationTimeForRegularFEM2,'filled', 'DisplayName', Constants.REGULAR_FEM_TITLE)
hold off
grid on
xlabel(Constants.PERCENTAGE_OF_ERROR)
ylabel(Constants.TIME_OF_CALCULATION)
titleLine = [Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.COLON, num2str(minimumBoundaryOfAPosterioriError)];
title(titleLine)
lg = legend;
lg.Location = 'northwest';

filename = [folderPath 'comparison_plot', Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError), Constants.FIG_TYPE];
saveas(figureOfTimeOfCalculationPerPercentageErrorPlot, filename)

endTime = posixtime(datetime('now'));
timeOfComputationOfComparisonScript = endTime - startTime
