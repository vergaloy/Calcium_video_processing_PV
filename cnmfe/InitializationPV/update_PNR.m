function [PNR,Cn,HY_box,Y_box]=update_PNR(Y_box,HY_box,A,C,ind_nhood,PNR,Cn,sz,gSig,Sn,F)

%% Get psf
psf = fspecial('gaussian', ceil(gSig*4+1), gSig);
ind_nonzero = (psf(:)>=max(psf(:,1)));
psf = psf-mean(psf(ind_nonzero));
psf(~ind_nonzero) = 0;
%%

parfor k=1:size(HY_box,2)
    Af=imfilter(reshape(A{k}, sz{k}(1),sz{k}(2)), psf, 'replicate');
    HY_box{k} = HY_box{k} - Af(:)*C(k,:);
    Y_box{k}=Y_box{k} - A{k}(:)*C(k,:);
    [tmp_Cn{k},tmp_PNR{k}]=get_PNR_coor_greedy_PV_no_parfor(reshape(HY_box{k},sz{k}(1),sz{k}(2),[]),F,Sn(ind_nhood{k}));
end
%
for k=1:size(tmp_Cn,2)
    PNR(ind_nhood{k})= tmp_PNR{k};
    Cn(ind_nhood{k})= tmp_Cn{k};
end

