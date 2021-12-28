function out=get_far_neighbors(seed,d1,d2,gSiz)
if length(seed)~=1
    di=sqrt(gSiz^2*2);
    [r_peak, c_peak] = ind2sub([d1,d2],seed);
    coor=[r_peak, c_peak];
    L=linkage(pdist(coor),'average');
    Z=find_leaves_in_node(L);
    clus=get_clusters(L(:,3)<2,Z);
    kill = cellfun(@(x) x(2:end),clus,'UniformOutput',false);
    kill = sort(cat(2,kill{:}));
    % dendrogram(L,0);
    
    coor(kill,:)=[];
    seed(kill)=[];
    M=squareform(pdist(coor));
    M=M<di;
    D=M-diag(ones(1,size(M,1)));
    ix=1:size(D,1);
    while true
        if sum(D,'all')==0
            break
        end
        [~,I]=max(sum(D,2));
        ix(I)=[];
        D(I,:)=[];D(:,I)=[];
    end
    out=seed(ix);
    
else
    out=seed;
end
end

function out=find_leaves_in_node(Z)
M=size(Z,1)+1;
out = num2cell(Z(:,1:2),2);
for i=1:size(Z,1)
    temp=out{i, 1};
    while (ismember(1,temp>M))
        f=find(temp>M,1);
        k=temp(f);
        temp(f)=[];
        temp=[temp,out{k-M, 1}];
    end
    out{i, 1}=temp;
end
end

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