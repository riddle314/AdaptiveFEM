% This function reads the boundary conditions for our spesific problem, if
% we want to change the boundary conditions of the problem with an
% understanding of our domain and mesh data here we have to do it
function bdFlag = readBoundaryConditionsBasedOnOurDomainRefinement(node, elem)

NT=size(elem,1);
bdFlag(1:NT,1:3)=0;

for i=1: NT
    
    if(((node(elem(i,1),1)==-1 && node(elem(i,2),1)==-1))||((node(elem(i,1),1)==-1 && node(elem(i,3),1)==-1))||((node(elem(i,2),1)==-1 && node(elem(i,3),1)==-1)))
        bdFlag(i,node(elem(i,:),1)>-1)=1;
    end
    if(((node(elem(i,1),1)==1 && node(elem(i,2),1)==1))||((node(elem(i,1),1)==1 && node(elem(i,3),1)==1))||((node(elem(i,2),1)==1 && node(elem(i,3),1)==1)))
        bdFlag(i,node(elem(i,:),1)<1)=1;
    end
    if(((node(elem(i,1),2)==1 && node(elem(i,2),2)==1))||((node(elem(i,1),2)==1 && node(elem(i,3),2)==1))||((node(elem(i,2),2)==1 && node(elem(i,3),2)==1)))
        bdFlag(i,node(elem(i,:),2)<1)=1;
    end
    
    if(((node(elem(i,1),2)==-1 && node(elem(i,1),1)<=0 && node(elem(i,2),2)==-1 && node(elem(i,2),1)<=0)||(node(elem(i,1),2)==-1 && node(elem(i,1),1)<=0 && node(elem(i,3),2)==-1 && node(elem(i,3),1)<=0)||(node(elem(i,2),2)==-1 && node(elem(i,2),1)<=0 && node(elem(i,3),2)==-1 && node(elem(i,3),1)<=0)))
        bdFlag(i,node(elem(i,:),2)>-1)=1;
    end
    
    if(((node(elem(i,1),2)==0 && node(elem(i,1),1)>=0 && node(elem(i,2),2)==0 && node(elem(i,2),1)>=0)||(node(elem(i,1),2)==0 && node(elem(i,1),1)>=0 && node(elem(i,3),2)==0 && node(elem(i,3),1)>=0)||(node(elem(i,2),2)==0 && node(elem(i,2),1)>=0 && node(elem(i,3),2)==0 && node(elem(i,3),1)>=0)))
        bdFlag(i,node(elem(i,:),2)>0)=1;
    end
    
    if(((node(elem(i,1),1)==0 && node(elem(i,1),2)<=0 && node(elem(i,2),1)==0) && node(elem(i,2),2)<=0)||((node(elem(i,1),1)==0 && node(elem(i,1),2)<=0 && node(elem(i,3),1)==0) && node(elem(i,3),2)<=0 )||((node(elem(i,2),1)==0 && node(elem(i,2),2)<=0 && node(elem(i,3),1)==0) && node(elem(i,3),2)<=0 ))
        bdFlag(i,node(elem(i,:),1)<0)=1;
    end
    
end
end


