% For the problem Du=f, find the right hand side b of the numerical problem Ax=b, 
% by taking account the function f and the boundary conditions first the Dirichlet 
% and then the Neumann if there are any.
function [b, u, freeNode] = findRightHandSide(node, elem, areaForAllElements, A, f, Dirichlet, Neumann, g_D, g_N)
  %N is the number of nodes
  N = size(node(:,1),1);
  % Compute the b matrix only using the f function
  mid1 = (node(elem(:,2),:)+node(elem(:,3),:))/2;
  mid2 = (node(elem(:,3),:)+node(elem(:,1),:))/2;
  mid3 = (node(elem(:,1),:)+node(elem(:,2),:))/2;
  bt1 = areaForAllElements.*(f(mid2)+f(mid3))/6; % integral for triangle is (1/3*area.*(φ(mid1)*f(mid1)+φ(mid2)*f(mid2)+φ(mid3)*f(mid3)))
  bt2 = areaForAllElements.*(f(mid3)+f(mid1))/6;
  bt3 = areaForAllElements.*(f(mid1)+f(mid2))/6;
  b = accumarray(elem(:),[bt1;bt2;bt3],[N 1]);
  % ----- Take account the boundary conditions -----
   
  % First Dirichlet boundary conditions
  isBdNode = false(N,1);
  isBdNode(Dirichlet) = true;
  bdNode = find(isBdNode);
  freeNode = find(~isBdNode);
  u = zeros(N,1);
  u(bdNode) = g_D(node(bdNode,:));
  b = b-A*u;
   
  % Then if there are any the Neumann boundary conditions
  if(~isempty(Neumann))
      % We want for each node i to find the integral Sφi(x)g_N(x)dx on the boundary A_N
      % also Sφi(x)g_N(x)dx = Sφj(x)g_N(x)dx if we take the integrals on the same edge [i,j] betwwen two nodes i and j
      Nve = node(Neumann(:,1),:)-node(Neumann(:,2),:);
      edgeLength = sqrt(sum(Nve.^2,2));
      mid = (node(Neumann(:,1),:)+node(Neumann(:,2),:))/2;
      % Nve, edgeLength, mid are arrays of size M x 1 where M = size(Neumann,1) which is the number of Neumann edges, 
      % also the i index on that arrays is in the same order with Neumann(i,1) or Neumann(i,2) which are nodes.
      % ----------
      % We use accumarray([Neumann(:), ones(2*size(Neumann,1), 1)], repmat(edgeLength.*g_N(mid)/2,2,1),[N,1]) which gives you an N x 1 array,
      % with the element at index i to be the Neumman integral approximation based on middle point quadtrature at node i ( Sφi(x)g_N(x)dx ) on all Neumann boundary A_N, 
      % which is actualy the integral on 2 edges with the middle node to be the node i for example [i-1, i, i+1], 
      % this is because φi(x) is 0 on every other x that belongs to different edges other than [i-1, i, i+1].
      % The repmat(edgeLength.*g_N(mid)/2,2,1) gives you an 2*M x 1 array.
      b = b + accumarray([Neumann(:), ones(2*size(Neumann,1), 1)], repmat(edgeLength.*g_N(mid)/2,2,1),[N,1]);
  end
end