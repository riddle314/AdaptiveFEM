%Here we read the mesh data and boundary conditions based on a
%initial refinement
function [node, elem, bdFlag, p , e, t, domainDecomposedGeometryMatrix] = readInitialMeshDataAndBoundaryConditions(numberOfMeshRefinements)

domainDecomposedGeometryMatrix = readDomain();

[p, e, t] = generateMeshData(domainDecomposedGeometryMatrix, numberOfMeshRefinements);

[node, elem] = extractNodeAndElements(p,t);
bdFlag = readBoundaryConditionsBasedOnOurDomainRefinement(node,elem);
end


