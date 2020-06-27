function [percentageOfErrorPlotLine, calculationTimeOfAdaptiveFEMPlotLine, calculationTimeForRegularFEM] = runCasesOfFEM(initialNumberOfMeshRefinements, minimumBoundaryOfAPosterioriError, step, minPercentageOfError, maxPercentageOfError, isPercentageOfErrorAdaptive)

startTime = posixtime(datetime('now'));

% setup the percentage of error type string based on if the percentage of error is adaptive
percentageOfErrorTypeString = Constants.PERCENTAGE_OF_ERROR;
percentageOfErrorTypeTitle = percentageOfErrorTypeString;
if isPercentageOfErrorAdaptive
    percentageOfErrorTypeTitle = Constants.ADAPTIVE_PERC_ERROR;
    percentageOfErrorTypeString = Constants.ADAPTIVE_PERCENTAGE_OF_ERROR;
end

% -- create figures --
figureName1 = ['Scatter plots for ', Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.COLON, num2str(minimumBoundaryOfAPosterioriError)];
figure1 = figure('Name', figureName1, 'NumberTitle', 'off', 'WindowState', 'maximized');
sgtitle(figureName1)

figureName2 = ['Plot of Time of Calculation per ', percentageOfErrorTypeString];
figure2 = figure('Name', figureName2, 'NumberTitle', 'off', 'WindowState', 'maximized');
percentageOfErrorPlotLine = [];
calculationTimeOfAdaptiveFEMPlotLine = [];

n = ceil((maxPercentageOfError-minPercentageOfError)/(2*step)+1);
index=1;
for percentageOfErrorMinBound = minPercentageOfError: step: maxPercentageOfError
    [dataOfNumOfElemAndErrors, ~, ~, ~, ~, calculationTimeForAdaptiveFEM] = ...
        solvePDEProblemWithFEM(initialNumberOfMeshRefinements, minimumBoundaryOfAPosterioriError, Constants.ADAPTIVE_FEM, percentageOfErrorMinBound, isPercentageOfErrorAdaptive);
    
    % data for figure2
    percentageOfErrorPlotLine = [percentageOfErrorPlotLine ; percentageOfErrorMinBound];
    calculationTimeOfAdaptiveFEMPlotLine = [calculationTimeOfAdaptiveFEMPlotLine ; calculationTimeForAdaptiveFEM];
    
    % add the plot to figure1
    figure(figure1)
    subplot(2,n,index)
    x = dataOfNumOfElemAndErrors(:,1);
    y = dataOfNumOfElemAndErrors(:,2);
    scatter(x,y,5,'filled')
    grid on
    xlabel(Constants.NUMBER_OF_NODES)
    ylabel(Constants.A_POSTERIORI_ERROR)
    titleLine1 = Constants.ADAPTIVE_FEM_TITLE;
    titleLine2 = [percentageOfErrorTypeTitle, Constants.COLON, num2str(percentageOfErrorMinBound)];
    title({titleLine1,titleLine2})
    index=index+1;
end

[dataOfNumOfElemAndErrors, ~, ~, ~, ~, calculationTimeForRegularFEM] = solvePDEProblemWithFEM(initialNumberOfMeshRefinements,...
    minimumBoundaryOfAPosterioriError, Constants.REGULAR_FEM);

% create the folder to save results
folderPath = UtilsClass.createFolderPath(minimumBoundaryOfAPosterioriError);

% add plot to figure1
figure(figure1)
subplot(2,n,index)
x = dataOfNumOfElemAndErrors(:,1);
y = dataOfNumOfElemAndErrors(:,2);
scatter(x,y,5,'filled')
grid on
xlabel(Constants.NUMBER_OF_NODES)
ylabel(Constants.A_POSTERIORI_ERROR)
title(Constants.REGULAR_FEM_TITLE)
% save figure1
fileName = [folderPath 'scatter_plots_', percentageOfErrorTypeString, Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError)];
saveas(figure1, [fileName, Constants.FIG_TYPE])
saveas(figure1, [fileName, Constants.JPG_TYPE])
close(figure1)

% add plot for Time of calculation per percentageOfError to figure2
figure(figure2)
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
filename = [folderPath 'plot_time_per_', percentageOfErrorTypeString, Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError)];
saveas(figure2, [filename, Constants.FIG_TYPE])
saveas(figure2, [filename, Constants.JPG_TYPE])
close(figure2)

endTime = posixtime(datetime('now'));
timeOfComputationOfRunCasesOfFem = endTime - startTime
end