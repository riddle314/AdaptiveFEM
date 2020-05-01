% Extract the node and elem vectors from p and t
function [node,elem] = extractNodeAndElements(p,t)
node=p';
temp=t';
elem=temp(:,1:3);
end

