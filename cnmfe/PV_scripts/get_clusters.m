function [clus,C]=get_clusters(S,L)
C=zeros(1,size(L,1));
for i=length(S):-1:1
    if (S(i))
        for k=1:size(L,1)
            if (ismember(L{k},L{i}))
                if (k~=i)
                    L{k}=[];
                    C(k)=i;
                end
                C(k)=i;
            end
        end
    else
        L{i}=[];
    end
end
clus=L;
clus=clus(~cellfun('isempty',clus));
u=unique(C);
u(u==0)=[];
for i=1:length(u)
    C(u(i)==C)=i;
end
end
