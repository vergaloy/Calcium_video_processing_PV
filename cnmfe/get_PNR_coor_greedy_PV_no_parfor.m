function [cn_all,pnr_all,cn,pnr]=get_PNR_coor_greedy_PV_no_parfor(Y,F)
max_bin=5000;
F=F';
le=[];
for i=1:length(F)
temp=F(i);
if temp>max_bin
    n=round(temp/max_bin)+1;
   temp=floor(diff(linspace(0,temp,n)));
   temp(end)=temp(end)+(F(i)-sum(temp));
end
le=cat(2,le,temp);
end
le=[0,cumsum(le)];

si=size(Y);
cn_all=zeros(si(1),si(2),size(le,2)-1);
pnr_all=zeros(si(1),si(2),size(le,2)-1);

Y_A=cell(size(le,2)-1,1);
for i=1:size(le,2)-1
Y_A{i}=Y(:,:,le(i)+1:le(i+1));
end

clear Y;

for i=1:size(Y_A,1)
    [cn_all(:,:,i),pnr_all(:,:,i)] = correlation_image_endoscope_PV2(Y_A{i},0);
end

cn=max(cn_all,[],3);
pnr=max(pnr_all,[],3);