function [cn_all,pnr_all,cn,pnr]=get_PNR_coor_greedy_PV(Y,Gsig)

si=size(Y);
le=round(linspace(1,si(3),round(si(3)/1000)+1));
cn_all=zeros(si(1),si(2),size(le,2)-1);
pnr_all=zeros(si(1),si(2),size(le,2)-1);

for i=1:size(le,2)-1
    [cn_all(:,:,i),pnr_all(:,:,i)] = correlation_image_endoscope_PV2(Y(:,:,le(i):le(i+1)),Gsig);
end

cn=max(cn_all,[],3);
pnr=max(pnr_all,[],3);