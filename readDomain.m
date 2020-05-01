% This is a specific function which give us data that describes our specific domain for our problem
% If we want to change the domain of our problem here we can do
function domainDecomposedGeometryMatrix = readDomain()

% The [gd , ns , sf] below are the three elements of geometry:
% gd : Geometry Data
% ns : Names for the Basic Shapes
% sf : Set Formula
% You can either extract it from pdepoly or create it in command line based on the rules 
% here: https://www.mathworks.com/help/pde/ug/create-geometry-at-the-command-line.html

gd =[
     2
     8
    -1
     0
     0
     1
     1
     0
    -1
    -1
    -1
    -1
     0
     0
     1
     1
     1
     0];
ns = ('P1')';
sf ='P1';

domainDecomposedGeometryMatrix = decsg(gd,sf,ns);



