% Solve the differential equation Du=f in A (domain) with the following properties:
% u=g_D for A_D (Dirichlet Boundary condition),
% Vu*n=g_N for A_N (Neumann Boundary condition),
% where dA=(A_D)U(A_N) (boundary)
% node, elem, bdflag are the mesh data and boundary conditions
function [A, u, b, areaForAllElements, functionf] = solvePDE(node, elem, bdFlag)
  [Dirichlet, Neumann] = findDirichletAndNeumannEdges(elem, bdFlag);
  [A , areaForAllElements] = assemblingsparse(node,elem);
  [b, u, freeNode] = findRightHandSide(node, elem, areaForAllElements, A, @f, Dirichlet, Neumann, @g_D, @g_N);
  u(freeNode) = A(freeNode,freeNode)\b(freeNode);
  functionf = @f;
end

% f=1 and g_D = 0 functions

function fvalue = f(x)
  % x is vector with cordinates in R^2
  fvalue = ones(size(x(:,1)));
end

function g_Dvalue = g_D(x)
   % x is vector with cordinates in R^2
  g_Dvalue = zeros(size(x(:,1)));
end

% For this problem the border A_N is empty(this problem hasn't Neumann boundary conditions)
% but we define g_N as zero function because we need it as input
function g_Nvalue = g_N(x)
   % x is vector with cordinates in R^2
  g_Nvalue = zeros(size(x(:,1)));
end





