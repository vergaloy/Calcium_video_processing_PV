function [cn_all,pnr_all,cn,pnr]=get_PNR_coor_shift_batch(nam,Gsig)
in=h5info(nam);
si=in.Datasets.Dataspace.Size;

le=linspace(1,si(3),round(si(3)/1000)+1);

cn_all=zeros(si(1),si(2),size(le,2)-1);
pnr_all=zeros(si(1),si(2),size(le,2)-1);

parfor i=1:size(le,2)-1
    tmp_range=[le(i),le(i+1)];   
    Y=h5read(nam,'/Object',[1 1 tmp_range(1)],[si(1) si(2) tmp_range(2)-tmp_range(1)+1]);    
    [cn_all(:,:,i),pnr_all(:,:,i)] = correlation_image_endoscope_PV2(Y,Gsig);
end

cn=max(cn_all,[],3);
pnr=max(pnr_all,[],3);