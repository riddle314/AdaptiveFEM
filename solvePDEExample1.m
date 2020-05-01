%solve the PDE for the triangulation given for the problem
[node, elem, bdFlag]=readMeshDataAndBoundaryConditionsExample1();
[A, u, b, areaForAllElements, f] = solvePDE(node, elem, bdFlag);
u
