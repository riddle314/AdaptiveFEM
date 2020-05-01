
function [Dirichlet, Neumann] = findDirichletAndNeumannEdges (elem, bdFlag)
% Compute the Neumann and Dirichlet boundary conditions
totalEdge = [elem(:, [2,3]); elem(:, [3,1]); elem(:, [1,2])];
Dirichlet = totalEdge(bdFlag(:)==1,:);
Neumann = totalEdge(bdFlag(:)==2, :);
end
