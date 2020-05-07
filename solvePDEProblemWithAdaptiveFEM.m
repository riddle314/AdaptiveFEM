% Solve the PDE with an adaptive Finite Element Method.
% Start with the computation of the initial mesh, the solution u and the
% error.
startTime = posixtime(datetime('now'));
numberOfMeshRefinements = 2;
[node, elem, bdFlag, p, e, t, domainDecomposedGeometryMatrix] = readInitialMeshDataAndBoundaryConditions(numberOfMeshRefinements);
% match a subdomain in each triangle
t = matchEachTriangleWithASubdomainInTriangleMatrix(t);
[A, u, b, areaForAllElements, f] = solvePDE(node, elem, bdFlag);

subplot(2,3,1), pdegplot(domainDecomposedGeometryMatrix)
subplot(2,3,2),pdemesh(p,e,t)
subplot(2,3,5), pdemesh(p,e,t,u)

% find the initial error and error per triangle for the initial mesh
[aPosterioriError, errorPerTriangle] = calculateAPosterioriError(node, elem, areaForAllElements, u, f);
aPosterioriError

% minimumBoundaryOfAPosterioriError is the minimum error we want to achieve
minimumBoundaryOfAPosterioriError = 0.8;

% percentageOfError is the percentage of the general error (aPosterioriError)
% for which we will try to find the triangles with the biggest errors (errorPerTriangle)
% that form it and we will refine them in order to shrink the general error
% (aPosterioriError)
percentageOfError = 0.2;

% then based on the error create the new adapted mesh and calculate the u and the error
while(aPosterioriError > minimumBoundaryOfAPosterioriError)
    indecesOfTrianglesThatNeedRefinement = findTrianglesThatNeedRefinement(aPosterioriError,...
        errorPerTriangle, percentageOfError);
    % here each subdomain match a triangle that need refinement
    subdomainsOfTrianglesThatNeedRefinement = indecesOfTrianglesThatNeedRefinement';
    [p,e,t] = refinemesh(domainDecomposedGeometryMatrix,p,e,t,subdomainsOfTrianglesThatNeedRefinement);
    % match a subdomain in each triangle 
    t = matchEachTriangleWithASubdomainInTriangleMatrix(t);
    [node, elem] = extractNodeAndElements(p,t);
    bdFlag = readBoundaryConditionsBasedOnOurDomainRefinement(node,elem);
    [A, u, b, areaForAllElements, f] = solvePDE(node, elem, bdFlag);
    [aPosterioriError, errorPerTriangle] = calculateAPosterioriError(node, elem, areaForAllElements, u, f);
    aPosterioriError
end
subplot(2,3,3), pdemesh(p,e,t)
subplot(2,3,6), pdemesh(p,e,t,u)
endTime = posixtime(datetime('now'));
timeOfComputation = endTime - startTime

% a function that match a subdomain in each triangle in the triangle Matrix 
function triangleMatrix = matchEachTriangleWithASubdomainInTriangleMatrix(triangleMatrix)
numberOfColumns = size(triangleMatrix,2);
numberOfRows = size(triangleMatrix,1);
if(numberOfRows == 4)
    triangleMatrix(4,:) = (1:numberOfColumns);
end
end



