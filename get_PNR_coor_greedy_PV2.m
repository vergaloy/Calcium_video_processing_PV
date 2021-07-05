function [cn_all,pnr_all,cn,pnr]=get_PNR_coor_greedy_PV2(Y,Gsig)
bin=100;
si=size(Y);
le=round(linspace(1,si(3),round(si(3)/bin)+1));
cn_all=zeros(si(1),si(2),size(le,2)-1);
pnr_all=zeros(si(1),si(2),size(le,2)-1);


Y_A=cell(size(le,2)-1,1);
for i=1:size(le,2)-1
Y_A{i}=Y(:,:,le(i):le(i+1));
end

clear Y;

parfor i=1:size(Y_A,1)
    [cn_all(:,:,i),pnr_all(:,:,i)] = correlation_image_endoscope_PV2(Y_A{i},Gsig);
end

se = fspecial('disk',4);
for i=1:size(cn_all,3)
tCn(:,:,i) = imfilter(cn_all(:,:,i),se,'replicate');
tPNR(:,:,i) = imfilter(pnr_all(:,:,i),se,'replicate');
end



cn=max(tCn,[],3);
pnr=max(tPNR,[],3);