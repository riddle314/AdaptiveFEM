% Find the indeces for the triangles that need mesh refinement based on the
% aPosterioriError, errorPerTriangle and the percentageOfError that defines
% our error boundary
function indecesOfTrianglesThatNeedRefinement = findTrianglesThatNeedRefinement(aPosterioriError, errorPerTriangle, percentageOfError)
[x,idx] = sort(errorPerTriangle(:,1), 'descend');
sortedErrorAndIndexInfoPerTriangle = [idx , x];

boundary = (percentageOfError*aPosterioriError)^2;
errorSum = 0;
lastIndex = 1;
numberOfRows = size(sortedErrorAndIndexInfoPerTriangle(:,1),1);
for i = 1 : numberOfRows
    errorSum =  errorSum + sortedErrorAndIndexInfoPerTriangle(i,2);
    if errorSum >= boundary
        lastIndex = i;
        break;
    end
end
% there is an edge case when the number of triangles that need refinement
% are only one, then the refinemesh function of Matlab we use later can not refine
% them, and returns the same mesh. In that case as a workround I add another
% triangle to the indecesOfTrianglesThatNeedRefinement, that with the next largest error.
if (lastIndex == 1 && numberOfRows>1)
    lastIndex = lastIndex+1;
end
indecesOfTrianglesThatNeedRefinement  = sortedErrorAndIndexInfoPerTriangle(1:lastIndex,1);
end