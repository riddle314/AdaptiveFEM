% Solve the PDE with an adaptive or regular Finite Element Method.
%
% Take as parameters 4 values:
% - initialNumberOfMeshRefinements (a integer number) the initial number of
% mesh refinements
% - minimumBoundaryOfAPosterioriError (a double number) is the minimum error we want to achieve
% - modeOfMethod if is 1 run as ADAPTIVE FEM else for any other input run as REGULAR FEM
% - percentageOfError (a double number) is the percentage of the general error (aPosterioriError)
% for which we will try to find the triangles with the biggest errors (errorPerTriangle)
% that form it and we will refine them in order to shrink the general error (aPosterioriError)
%
% returns 5 variables:
% - dataOfNumOfElemAndErrors the data for each computation of the number of nodes and the aPostaerioriError,
% the last element of that matrix has the final number of triangles of the mesh and the final aPostaerioriError
% - p, e, t the mesh data where: p is Point Matrix, e is Edge Matrix, t is Triangle Matrix
% - u the values of our solution per node / point we have
function [dataOfNumOfElemAndErrors, p, e, t, u] = solvePDEProblemWithFEM(initialNumberOfMeshRefinements, minimumBoundaryOfAPosterioriError, modeOfMethod, percentageOfError)
startTime = posixtime(datetime('now'));
ADAPTIVE_FEM = 1;
REGULAR_FEM = 2;

% check the input arguments and give default values if we don't give input
% for some values
if nargin < 3
    if nargin ==0
        initialNumberOfMeshRefinements = 1;
        minimumBoundaryOfAPosterioriError = 0.5;
    elseif nargin == 1
        minimumBoundaryOfAPosterioriError = 0.5;
    end
    modeOfMethod = REGULAR_FEM;
else
    if modeOfMethod ~= ADAPTIVE_FEM
        modeOfMethod = REGULAR_FEM;
    end
    if(nargin == 3)
        percentageOfError = 0.5;
    end
end

% Start with the computation of the initial mesh, the solution u and the
% error.
[node, elem, bdFlag, p, e, t, domainDecomposedGeometryMatrix] = readInitialMeshDataAndBoundaryConditions(initialNumberOfMeshRefinements);
if (modeOfMethod == ADAPTIVE_FEM)
    % match a subdomain in each triangle
    t = matchEachTriangleWithASubdomainInTriangleMatrix(t);
end
[A, u, b, areaForAllElements, f] = solvePDE(node, elem, bdFlag);

% ---- first part of figure creation ----
if(modeOfMethod == ADAPTIVE_FEM)
    figureName = ['Adaptive FEM: percentageOfError =', num2str(percentageOfError)];
else
    figureName = 'Regular FEM';
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
while(aPosterioriError > minimumBoundaryOfAPosterioriError)
    if (modeOfMethod == ADAPTIVE_FEM)
        indecesOfTrianglesThatNeedRefinement = findTrianglesThatNeedRefinement(aPosterioriError,...
            errorPerTriangle, percentageOfError);
        % here each subdomain match a triangle that need refinement
        subdomainsOfTrianglesThatNeedRefinement = indecesOfTrianglesThatNeedRefinement';
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

% ---- second part of figure creation and saving----
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

if(modeOfMethod == ADAPTIVE_FEM)
    titleLine1 = 'Adaptive FEM';
    titleLine2 = ['percentageOfError: ', num2str(percentageOfError),...
    ', minimumBoundaryOfAPosterioriError: ', num2str(minimumBoundaryOfAPosterioriError)];
    sgtitle({titleLine1,titleLine2})
    filename = ['Adaptive_FEM_percentageOfError_', num2str(percentageOfError),...
     '_minimumBoundaryOfAPosterioriError_', num2str(minimumBoundaryOfAPosterioriError),'.jpg'];
else
    titleLine1 = 'Regular FEM';
    titleLine2 = ['minimumBoundaryOfAPosterioriError: ', num2str(minimumBoundaryOfAPosterioriError)];
    sgtitle({titleLine1,titleLine2})
    filename = ['Regular_FEM_minimumBoundaryOfAPosterioriError_', num2str(minimumBoundaryOfAPosterioriError),'.jpg'];
end
saveas(gcf, filename)
% ---- end of second part of figure creation and saving----

endTime = posixtime(datetime('now'));
timeOfComputation = endTime - startTime
end

% a function that match a subdomain in each triangle in the triangle Matrix
function triangleMatrix = matchEachTriangleWithASubdomainInTriangleMatrix(triangleMatrix)
numberOfColumns = size(triangleMatrix,2);
numberOfRows = size(triangleMatrix,1);
if(numberOfRows == 4)
    triangleMatrix(4,:) = (1:numberOfColumns);
end
end



