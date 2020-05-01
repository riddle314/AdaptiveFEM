% Generate Mesh Data [p, e, t] where: p is Point Matrix, e is Edge Matrix, t is Triangle Matrix
% with function input a Decomposed Geometry Matrix of the domain and the number of Mesh
% data refinements
function [p, e, t] = generateMeshData(domainDecomposedGeometryMatrix, numberOfMeshRefinements)
[p,e,t] = initmesh(domainDecomposedGeometryMatrix,'hmax',inf);
for i = 2 : numberOfMeshRefinements
    [p,e,t] = refinemesh(domainDecomposedGeometryMatrix,p,e,t);
end
end