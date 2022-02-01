function [A,C_raw,C,S,Ymean,Cn_update] = int_temp(neuron)

Y = neuron.load_patch_data();
Ymean={double(median(Y,3))};

%%
d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
gSiz=gSig*4;

if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
Y(isnan(Y)) = 0;    % remove nan values
T = size(Y, 2);

if isempty(neuron.options.F)
    F=T;
else
    F=neuron.options.F;
end

%% preprocessing data
% create a spatial filter for removing background
if gSig>0
    if neuron.options.center_psf
        psf = fspecial('gaussian', ceil(gSiz+1), gSig);
        ind_nonzero = (psf(:)>=max(psf(:,1)));
        psf = psf-mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
    else
        psf = fspecial('gaussian', round(gSiz), gSig);
    end
else
    psf = [];
end

% filter the data
if isempty(psf)
    % no filtering
    HY = Y;
else
    HY = imfilter(reshape(single(Y), d1,d2,[]), psf, 'replicate');
end

HY = reshape(HY, d1*d2, []);

%% PV Remove media in each session
if size(F,1)>1
    t=0;
    for i=1:size(F,1)
        HY(:,t+1:t+F(i)) = HY(:,t+1:t+F(i))-median(HY(:,t+1:t+F(i)),2);
        t=F(i);
    end
else
    HY = bsxfun(@minus, HY, median(HY, 2));
end
if size(HY,2)>10000
Sn=GetSn_fast(HY,1000,10,d1,d2);
else
 Sn=GetSn(HY);   
end
%% Get PNR and CN PV
if ~isempty(neuron.Cn)
    Cn=neuron.Cn;
    PNR=neuron.PNR;
else
    [~,Cn,PNR]=get_PNR_coor_greedy_PV(HY,gSig);
end
%%
% screen seeding pixels as center of the neuron

if ~isempty(neuron.Mask)
    Mask=neuron.Mask;
end
%% Intialize variables
A=[];
C=[];
C_raw=[];
S=[];
seed=get_seeds(Cn,PNR,gSig,neuron.options.min_corr,neuron.options.min_pnr,Mask);
imshow(Cn);drawnow;
Cn_update(:,:,1)=Cn;
while true

seed=get_far_neighbors(seed,d1,d2,gSiz*1.5,Cn,PNR);
Mask(seed)=0;


[Y_box,HY_box,ind_nhood,center,sz]=get_mini_videos(Y,HY,seed,d1,d2,gSiz);
if length(Y_box)==0
   break 
end
[a,c_raw]=estimate_components(Y_box,HY_box,center,sz,neuron.options.spatial_constraints);
[c,s]=deconv_PV(c_raw,neuron.options.deconv_options);

[PNR,Cn,HY_box,Y_box]=update_PNR(Y_box,HY_box,a,c,ind_nhood,PNR,Cn,sz,gSig,Sn,F);

a=expand_A(a,ind_nhood,d1*d2);

[Y,HY]=update_video(Y,HY,Y_box,HY_box,ind_nhood);
A=cat(2,A,a);
C=cat(1,C,c);
C_raw=cat(1,C_raw,c_raw);
S=cat(1,S,s);
imshow(Cn);drawnow;
Cn_update=cat(3,Cn_update,Cn);
%% update seeds
seed=get_seeds(Cn,PNR,gSig,neuron.options.min_corr,neuron.options.min_pnr,Mask);
if isempty(seed)
    break
end

end
