% Solve the PDE with an adaptive or regular Finite Element Method.
%
% Take as parameters 5 values:
% - initialNumberOfMeshRefinements (a integer number) the initial number of
% mesh refinements
% - minimumBoundaryOfAPosterioriError (a double number) is the minimum error we want to achieve
% - modeOfMethod if is 1 run as ADAPTIVE FEM else for any other input run as REGULAR FEM
% - percentageOfErrorMinBound (a double number) is the minimum percentage of
% the general error (aPosterioriError) we may take,
% for which we will try to find the triangles with the biggest errors (errorPerTriangle)
% that form it and we will refine them in order to shrink the general error (aPosterioriError)
% - isPercentageOfErrorAdaptive where enables or disable the
% percentageOfError to be adaptive based on percentageOfErrorMinBound
%
% returns 6 variables:
% - dataOfNumOfElemAndErrors the data for each computation of the number of nodes and the aPostaerioriError,
% the last element of that matrix has the final number of triangles of the mesh and the final aPostaerioriError
% - p, e, t the mesh data where: p is Point Matrix, e is Edge Matrix, t is Triangle Matrix
% - u the values of our solution per node / point we have
% - timeOfComputation
function [dataOfNumOfElemAndErrors, p, e, t, u, timeOfComputation] = solvePDEProblemWithFEM(initialNumberOfMeshRefinements, minimumBoundaryOfAPosterioriError, modeOfMethod, percentageOfErrorMinBound, isPercentageOfErrorAdaptive)
startTime = posixtime(datetime('now'));

% check the input arguments and give default values if we don't give input
% for some values
if nargin < 3
    if nargin ==0
        initialNumberOfMeshRefinements = 1;
        minimumBoundaryOfAPosterioriError = 0.6;
    elseif nargin == 1
        minimumBoundaryOfAPosterioriError = 0.5;
    end
    modeOfMethod = Constants.REGULAR_FEM;
    percentageOfErrorMinBound = 1;
    isPercentageOfErrorAdaptive = false;
else
    if modeOfMethod == Constants.ADAPTIVE_FEM
        if nargin == 3
            percentageOfErrorMinBound = 0.5;
            isPercentageOfErrorAdaptive = false;
        elseif nargin == 4
            isPercentageOfErrorAdaptive = false;
        end
    else
        modeOfMethod = Constants.REGULAR_FEM;
        percentageOfErrorMinBound = 1;
        isPercentageOfErrorAdaptive = false;
    end
end

% setup the percentage of error type string based on if the percentage of error is adaptive
percentageOfErrorTypeString = Constants.PERCENTAGE_OF_ERROR;
if isPercentageOfErrorAdaptive
    percentageOfErrorTypeString = Constants.PERCENTAGE_OF_ERROR_MIN_BOUND;
end

% Start with the computation of the initial mesh, the solution u and the
% error.
[node, elem, bdFlag, p, e, t, domainDecomposedGeometryMatrix] = readInitialMeshDataAndBoundaryConditions(initialNumberOfMeshRefinements);
if (modeOfMethod == Constants.ADAPTIVE_FEM) 
    % match a subdomain in each triangle
    t = matchEachTriangleWithASubdomainInTriangleMatrix(t);
end
[A, u, b, areaForAllElements, f] = solvePDE(node, elem, bdFlag);

% ---- first part of figure creation ----
if (modeOfMethod == Constants.ADAPTIVE_FEM)
    figureName = [Constants.ADAPTIVE_FEM_TITLE, Constants.COLON, percentageOfErrorTypeString, Constants.COLON, num2str(percentageOfErrorMinBound)];
else
    figureName = Constants.REGULAR_FEM_TITLE;
end
figure('Name',figureName,'NumberTitle','off')
subplot(2,3,1)
pdegplot(domainDecomposedGeometryMatrix)
title('Initial domain')

subplot(2,3,2)
pdemesh(p,e,t)
title('Initial mesh')

subplot(2,3,5)
pdemesh(p,e,t,u)
title('Initial solution')
% ---- end of first part of figure creation ----

% find the initial error and error per triangle for the initial mesh
[aPosterioriError, errorPerTriangle] = calculateAPosterioriError(node, elem, areaForAllElements, u, f);

% save the data for each computation of the number of nodes and the aPostaerioriError
prelocationNumber = 100;
dataOfNumOfElemAndErrors = zeros(prelocationNumber,2);
numberOfTimesTheProblemCalculated = 1;
dataOfNumOfElemAndErrors(numberOfTimesTheProblemCalculated,:) = [size(node,1), aPosterioriError];

% then based on the error create the new adapted mesh and calculate the u and the error
while (aPosterioriError > minimumBoundaryOfAPosterioriError)
    if (modeOfMethod == Constants.ADAPTIVE_FEM)
        percentageOfError = getPercentageOfError(percentageOfErrorMinBound, aPosterioriError, minimumBoundaryOfAPosterioriError, isPercentageOfErrorAdaptive);
        indicesOfTrianglesThatNeedRefinement = findTrianglesThatNeedRefinement(aPosterioriError,...
            errorPerTriangle, percentageOfError);
        % here each subdomain match a triangle that need refinement
        subdomainsOfTrianglesThatNeedRefinement = indicesOfTrianglesThatNeedRefinement';
        [p,e,t] = refinemesh(domainDecomposedGeometryMatrix,p,e,t,subdomainsOfTrianglesThatNeedRefinement);
        % match a subdomain in each triangle
        t = matchEachTriangleWithASubdomainInTriangleMatrix(t);
    else
        [p,e,t] = refinemesh(domainDecomposedGeometryMatrix,p,e,t);
    end
    
    [node, elem] = extractNodeAndElements(p,t);
    bdFlag = readBoundaryConditionsBasedOnOurDomainRefinement(node,elem);
    [A, u, b, areaForAllElements, f] = solvePDE(node, elem, bdFlag);
    [aPosterioriError, errorPerTriangle] = calculateAPosterioriError(node, elem, areaForAllElements, u, f);
    
    % save the data for each computation of the number of nodes and the aPostaerioriError
    numberOfTimesTheProblemCalculated = numberOfTimesTheProblemCalculated+1;
    dataOfNumOfElemAndErrors(numberOfTimesTheProblemCalculated,:) = [size(node,1), aPosterioriError];
end

if (numberOfTimesTheProblemCalculated < prelocationNumber)
    dataOfNumOfElemAndErrors = dataOfNumOfElemAndErrors(1 : numberOfTimesTheProblemCalculated,:);
end

% I end here the calculation of computation time because after we create more figures
% and folders to save them, I don't want that to account for computation
% time
endTime = posixtime(datetime('now'));
timeOfComputation = endTime - startTime;

% ---- second part of figure creation and saving ----
subplot(2,3,3)
pdemesh(p,e,t)
title('Final mesh')

subplot(2,3,6)
pdemesh(p,e,t,u)
title('Final solution')

subplot(2,3,4)
x = dataOfNumOfElemAndErrors(:,1);
y = dataOfNumOfElemAndErrors(:,2);
loglog(x,y)
grid on
xlabel('number of nodes')
ylabel('aPosterioriError')
title('log-log plot')

% create the folder to save results
folderPath = UtilsClass.createFolderPathPerModeOfMethod(minimumBoundaryOfAPosterioriError, modeOfMethod, isPercentageOfErrorAdaptive);

if(modeOfMethod == Constants.ADAPTIVE_FEM)
    titleLine1 = Constants.ADAPTIVE_FEM_TITLE;
    titleLine2 = [percentageOfErrorTypeString, Constants.COLON, num2str(percentageOfErrorMinBound),...
    Constants.COMMA, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.COLON, num2str(minimumBoundaryOfAPosterioriError)];
    sgtitle({titleLine1, titleLine2})
    filename1 = [folderPath, Constants.ADAPTIVE_FEM_TITLE_WITH_DASH, Constants.DASH, percentageOfErrorTypeString, Constants.DASH, num2str(percentageOfErrorMinBound),...
    Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError), Constants.JPG_TYPE];
    filename2 = [folderPath, Constants.ADAPTIVE_FEM_TITLE_WITH_DASH, Constants.DASH, percentageOfErrorTypeString, Constants.DASH, num2str(percentageOfErrorMinBound),...
    Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError), Constants.FIG_TYPE];
else
    titleLine1 = Constants.REGULAR_FEM_TITLE;
    titleLine2 = [Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.COLON, num2str(minimumBoundaryOfAPosterioriError)];
    sgtitle({titleLine1, titleLine2})
    filename1 = [folderPath, Constants.REGULAR_FEM_TITLE_WITH_DASH, Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError), Constants.JPG_TYPE];
    filename2 = [folderPath, Constants.REGULAR_FEM_TITLE_WITH_DASH, Constants.DASH, Constants.MINIMUM_BOUNDARY_OF_A_POSTERIORI_ERROR, Constants.DASH, num2str(minimumBoundaryOfAPosterioriError), Constants.FIG_TYPE];
end
saveas(gcf, filename1)
saveas(gcf, filename2)
close(gcf)

end

% a function that match a subdomain in each triangle in the triangle Matrix
function triangleMatrix = matchEachTriangleWithASubdomainInTriangleMatrix(triangleMatrix)
numberOfColumns = size(triangleMatrix,2);
numberOfRows = size(triangleMatrix,1);
if(numberOfRows == 4)
    triangleMatrix(4,:) = (1:numberOfColumns);
end
end

% get the percentage of error, if isPercentageOfErrorAdaptive is true it can change per refinement adaptively
function percentageOfError = getPercentageOfError(percentageOfErrorMinBound, aPosterioriError, minimumBoundaryOfAPosterioriError, isPercentageOfErrorAdaptive)
if isPercentageOfErrorAdaptive
    percentageOfError = (aPosterioriError-minimumBoundaryOfAPosterioriError)/aPosterioriError;
    if percentageOfError < percentageOfErrorMinBound
        percentageOfError = percentageOfErrorMinBound;
    end
else
    percentageOfError = percentageOfErrorMinBound;
end
end