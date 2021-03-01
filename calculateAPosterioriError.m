% Calculate the a posteriori error and a vector with the respective error
% per triangle
function [aPosterioriError, errorPerTriangle] = calculateAPosterioriError(node, elem, areaForAllElements, u, f)
errorPerTriangle = calculateErrorPerTriangle(node, elem, areaForAllElements, u, f);
aPosterioriError = sqrt(sum(errorPerTriangle));
end

function et = calculateErrorPerTriangle(node, elem, areaForAllElements, u, f)
edgeVector1 = node(elem(:,2),:)-node(elem(:,3),:);
edgeVector2 = node(elem(:,3),:)-node(elem(:,1),:);
edgeVector3 = node(elem(:,1),:)-node(elem(:,2),:);

edgeLenghtVector1=sqrt(sum(edgeVector1.^2,2));
edgeLenghtVector2=sqrt(sum(edgeVector2.^2,2));
edgeLenghtVector3=sqrt(sum(edgeVector3.^2,2));

% find the legths of the edges in each triangle
edgeLengthsPerTriangle = [edgeLenghtVector1, edgeLenghtVector2, edgeLenghtVector3];
% find the max legth of edges in each triangle
maxEdgeLengthPerTriangle = max(edgeLengthsPerTriangle, [], 2);

Nt = size(elem,1);

mid1 = (node(elem(:,2),:)+node(elem(:,3),:))/2;
mid2 = (node(elem(:,3),:)+node(elem(:,1),:))/2;
mid3 = (node(elem(:,1),:)+node(elem(:,2),:))/2;
% a NT x 1 matrix with the squares of L2 integrals of f per triangle
integralOfF = 1/3*areaForAllElements.*(f(mid1).^2 + f(mid2).^2 + f(mid3).^2);

partA = (maxEdgeLengthPerTriangle.^2).* integralOfF;

jumpOfGradsOnEdges = calculateMatrixOfJumpsPerEdge(node, elem, u);

partB =zeros(Nt, 1);
for i = 1 : Nt
    partB(i) = (edgeLengthsPerTriangle(i,1)^2).*jumpOfGradsOnEdges(elem(i,2), elem(i,3))...
        + (edgeLengthsPerTriangle(i,2)^2).*jumpOfGradsOnEdges(elem(i,3), elem(i,1))...
        + (edgeLengthsPerTriangle(i,3)^2).*jumpOfGradsOnEdges(elem(i,1), elem(i,2));
end

et = partA + partB;
end

%Calculate N x N matrix with the sort of integrals of [Vu]_e for each edge, this matrix
%will be sparse and each (i,j) is an edge and jumpOfGradsOnEdges(i,j) give
%us the value on that edge.
function jumpOfGradsOnEdges = calculateMatrixOfJumpsPerEdge(node, elem, u)
N = size(node,1);
NT = size(elem,1);
i = zeros(3*NT,1);
j = zeros(3*NT,1);
s = zeros(3*NT,1);
index= 1;
for x = 1: NT
    i(index) = elem(x,1);
    j(index) = elem(x,2);
    s(index) = calculate(elem(x,:), node, u, i(index), j(index));
    index= index+1;
    i(index) = elem(x,2);
    j(index) = elem(x,3);
    s(index) = calculate(elem(x,:), node, u, i(index), j(index));
    index= index+1;
    i(index) = elem(x,3);
    j(index) = elem(x,1);
    s(index) = calculate(elem(x,:), node, u, i(index), j(index));
    index= index+1;
end
jumpA = sparse(i, j, s, N, N);
jumpB = jumpA.';
jumpOfGradsOnEdges = (jumpA + jumpB).^2;
end

% This calculate a number and takes as input the following:
% an element( the specific triangle (i,j,z) )
% the node matrix
% the solution matrix u
% the nodes' number for the specific edge (edgeNode1, edgeNode2)
function result = calculate(element, node, u, edgeNode1, edgeNode2)
%lengthOfEdge = sqrt(sum((node(edgeNode1)-node(edgeNode2)).^2,2));
middlePoint = (node(edgeNode1,:)+node(edgeNode2,:))./2;

% find a matrix 3 x 3 where each row give us three points in 3D space (x,y,z) on the plane the
% linear function phi create's. Each point has as (x,y) the respective node.
pointsOfPlanePerFunctionPhi = cell(3,3);
for i = 1 :3
    for j= 1 :3
        if i==j
            pointsOfPlanePerFunctionPhi{i,j} = [node(element(j),1), node(element(j),2), 1];
        else
            pointsOfPlanePerFunctionPhi{i,j} = [node(element(j),1), node(element(j),2), 0];
        end
    end
end

C = zeros(3);
for i = 1: 3
    A = pointsOfPlanePerFunctionPhi{i,2}-pointsOfPlanePerFunctionPhi{i,1};
    B = pointsOfPlanePerFunctionPhi{i,3}-pointsOfPlanePerFunctionPhi{i,1};
    C(i,:) = cross(A,B);
end

gradOfFunctionPhi = [-(C(:,1)./C(:,3)), -(C(:,2)./C(:,3))];

node1Point = node(edgeNode1,:);
node2Point = node(edgeNode2,:);
node3Point = zeros(1,2);
for i =1:3
    if (element(i) ~= edgeNode1) && (element(i) ~= edgeNode2)
        node3Point = node(element(i),:);
    end
end
n = calculateVerticalVector(node1Point,node2Point,middlePoint,node3Point);


result = sum(u(element).*(gradOfFunctionPhi*(n')));
end

% node1 (x1,y1) and node2 (x2,y2) are the points of the edge where we are looking for the vertical vector n
% middlePoint is the middle point between the edge [node1, node2]
% node3 (x3,y3) is the third node of the triagle across the edge [node1, node2]
function n = calculateVerticalVector(node1Point, node2Point, middlePoint, node3Point)
x1 = node1Point(1);
y1 = node1Point(2);
x2 = node2Point(1);
y2 = node2Point(2);
x3 = node3Point(1);
y3 = node3Point(2);
m1 = middlePoint(1); %(x1+x2)/2
m2 = middlePoint(2); %(y1+y2)/2

if x2-x1~=0
    part1 = (y2-y1)/(x2-x1);
    part2 = 1/sqrt(1+(part1)^2);
    part3 = part1*m2+m1;
    
    yA = part2 + m2;
    yB = -part2 + m2;
    xA = - part1*yA + part3;
    xB = - part1*yB + part3;
else
    yA = m2;
    yB = yA;
    xA = m1 +1;
    xB = m1 -1;
end

Q = [xA,yA];
P = [xB,yB];
G = [x3,y3];
M = [m1,m2];
GQ = G-Q;
GP = G-P;

%lengthGQ = sqrt(sum(GQ.^2));
lengthGQ = norm(GQ);

%lengthGP = sqrt(sum(GP.^2));
lengthGP = norm(GP);

if lengthGQ > lengthGP
    n = Q-M;
else
    n = P-M;
end
end

% a slow way to solve this that doens't work with errors, this is not used
% node1 (x1,y1) and node2 (x2,y2) are the points of the edge where we are looking for the vertical vector n
% middlePoint is the middle point between the edge [node1, node2]
% node3 (x3,y3) is the third node of the triagle across the edge [node1, node2]
function n = calculateVerticalVector1(node1Point, node2Point, middlePoint, node3Point)
x1 = node1Point(1);
y1 = node1Point(2);
x2 = node2Point(1);
y2 = node2Point(2);
x3 = node3Point(1);
y3 = node3Point(2);
m1 = middlePoint(1);
m2 = middlePoint(2);
syms x y
eqn1 = [x-m1,y-m2]*[x2-x1 ; y2-y1]==0;

A = [x1,y1];
B = [x2,y2];
G = [x3,y3];
P = [x,y];
AB = B-A;
AP = P-A;
BG = G-B;
BP = P-B;
AG = G-A;
areaAGB = 1/2*abs(det([AB;AG]));
areaAPB = 1/2*abs(det([AB;AP]));
areaBPG = 1/2*abs(det([BG;BP]));
areaAPG = 1/2*abs(det([AG;AP]));
eqn2 = areaAPB + areaBPG + areaAPG == areaAGB;
sol = solve([eqn1, eqn2], [x, y]);
n = [sol.x, sol.y];
n = (1/sqrt(sum(n.^2)))*n;
end
