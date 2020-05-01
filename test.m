
node1Point=[0,0];
node2Point = [1,0];
node3Point = [0,1];
middlePoint = [1/2,0];

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
sol = solve([eqn1, eqn2], [x, y])
n = [sol.x, sol.y]