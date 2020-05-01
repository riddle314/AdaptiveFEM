% find global stiffness matrix for Du=f problem with Laplace differential operator D
function [A , AreaForAllElements] = assemblingsparse(node,elem)
  N = size(node,1); 
  NT = size(elem,1);
  i = zeros(9*NT,1);
  j = zeros(9*NT,1);
  s = zeros(9*NT,1);
  index=0;
  AreaForAllElements =zeros(NT,1);
  for t= 1:NT
    [At, areaOfElement] = localstiffness(node(elem(t,:),:));
    AreaForAllElements(t,1) = areaOfElement;
    for ti = 1:3
      for tj = 1:3
        index = index + 1;
        i(index) = elem(t,ti);
        j(index) = elem(t,tj);
        s(index) = At(ti,tj);
      end
    end
  end
  A = sparse(i,j,s,N,N);
end

%find local stiffness matrix
function [At,area] = localstiffness(p)
  At=zeros(3,3);
  B =[p(1,:)-p(3,:); p(2,:)-p(3,:)];
  G =[[1,0]', [0,1]',[-1,-1]'];
  area = 0.5*abs(det(B));
  for i = 1:3
    for j =1:3
      At(i,j)=area*((B\G(:,i))'*(B\G(:,j)));
    end
  end
end
