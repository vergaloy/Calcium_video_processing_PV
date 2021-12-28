function [tform,O]=MC_R(in)
win=500;
G = squeeze(num2cell(in,[1 2]));
T=G{1};

parfor i=1:win
temp= imregcorr(G{i},T,'translation','window',1);
tform(i,:)=[temp.T(3,1),temp.T(3,2)];
O(:,:,i) = imwarp(G{i},temp);
end

T=median(O(:,:,1:win),3);


x=round(linspace(1,size(G,1),size(G,1)/win));
x(1)=0;

for k=1:size(x,2)-1
    parfor i=x(k)+1:x(k+1)
        temp= imregcorr(G{i},T,'translation','window',1);
        tform(i,:)=[temp.T(3,1),temp.T(3,2)];
        O(:,:,i) = imwarp(G{i},temp);
    end
    T=median(O(:,:,x(k)+1:x(k+1)),3);
end