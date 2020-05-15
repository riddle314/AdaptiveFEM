ADAPTIVE_FEM = 1;
REGULAR_FEM = 2;

initialNumberOfMeshRefinements = 1;
minimumBoundaryOfAPosterioriError = 0.8;

figureName = ['Log-Log plots for minimumBoundaryOfAPosterioriError: ', num2str(minimumBoundaryOfAPosterioriError)];
figureOfLogLogPlots = figure('Name',figureName,'NumberTitle','off');

step = 0.1;
minOfPercentageError = 0.1;
maxPercentageOfError = 1;
n = ceil((maxPercentageOfError-minOfPercentageError)/(2*step)+1);
i=1;
for percentageOfError = minOfPercentageError: step: maxPercentageOfError
    [dataOfNumOfElemAndErrors, ~, ~, ~, ~] = solvePDEProblemWithFEM(initialNumberOfMeshRefinements,...
        minimumBoundaryOfAPosterioriError, ADAPTIVE_FEM, percentageOfError);
    
    % add the log log plot to figure
    figure(figureOfLogLogPlots)
    subplot(2,n,i)
    x = dataOfNumOfElemAndErrors(:,1);
    y = dataOfNumOfElemAndErrors(:,2);
    loglog(x,y)
    grid on
    xlabel('number of nodes')
    ylabel('aPosterioriError')
    titleLine1 = 'Adaptive FEM';
    titleLine2 = ['percentageOfError: ',num2str(percentageOfError)];
    title({titleLine1,titleLine2})
    i=i+1;
end

[dataOfNumOfElemAndErrors, ~, ~, ~, ~] = solvePDEProblemWithFEM(initialNumberOfMeshRefinements,...
    minimumBoundaryOfAPosterioriError, REGULAR_FEM);
figure(figureOfLogLogPlots)
subplot(2,n,i)
x = dataOfNumOfElemAndErrors(:,1);
y = dataOfNumOfElemAndErrors(:,2);
loglog(x,y)
grid on
xlabel('number of nodes')
ylabel('aPosterioriError')
title('Regular FEM')
