% Mesh Data Structure and boundary conditions for specific problem
function [node, elem, bdFlag]= readMeshDataAndBoundaryConditionsExample1()
%Add mesh data
node = [-1.0 -1.0; -0.5 -1.0; 0 -1.0; 0 -0.5; 0 0; 0.5 0; 1.0 0; 1.0 0.5; 1.0 1.0; 0.5 1.0; 0 1.0; -0.5 1.0; -1.0 1.0; -1.0 0.5; -1.0 0; -1.0 -0.5; -0.5 -0.5; -0.5 0; -0.5 0.5; 0 0.5; 0.5 0.5];
e1 = [2 16 3 17 17 15 4 18 19 15 20 18 12 14 11 19 6 20 7 21 21 11 8 10];
e2 = [16 2 17 3 15 17 18 4 15 19 18 20 14 12 19 11 20 6 21 7 11 21 10 8];
e3 = [1 17 2 4 16 18 17 5 18 14 5 19 19 13 20 12 5 21 6 8 20 10 21 9];

elem = [e1' e2' e3'];

% Add data for Dirichlet boundary conditions
Nt=size(elem,1);
bdFlag = zeros(Nt,3);

bdFlag(1,elem(1,:)==2)=1;
bdFlag(1,elem(1,:)==16)=1;
bdFlag(3,(elem(3,:)==17))=1;
bdFlag(4,(elem(4,:)==17))=1;
bdFlag(8,(elem(8,:)==18))=1;
bdFlag(17,(elem(17,:)==20))=1;
bdFlag(19,(elem(19,:)==21))=1;
bdFlag(20,(elem(20,:)==21))=1;
bdFlag(24,(elem(24,:)==10))=1;
bdFlag(24,(elem(24,:)==8))=1;
bdFlag(22,(elem(22,:)==21))=1;
bdFlag(16,(elem(16,:)==19))=1;
bdFlag(14,(elem(14,:)==14))=1;
bdFlag(14,(elem(14,:)==12))=1;
bdFlag(10,(elem(10,:)==19))=1;
bdFlag(5,(elem(5,:)==17))=1;
end

%another example
%node = [1 0 ; 1 1; 0 1; -1 1; -1 0; -1 -1; 0 -1; 0 0];
%elem = [1 2 8; 3 8 2; 8 3 5; 4 5 3; 7 8 6; 5 6 8];
%[N d] = size(node);
%[NT, d1]= size(elem);
% Boundary Conditions
% bdflag = [0 1 1; 0 1 0; 0 0 0; 0 1 2; 0 1 1; 0 0 2];