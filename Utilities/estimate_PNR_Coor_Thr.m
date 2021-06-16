function estimate_PNR_Coor_Thr(Gsig,inF,min_corr,min_pnr)

% estimate_PNR_Coor_Thr(4)
if ~exist('Gsig','var')
Gsig=4;
end

if ~exist('min_corr','var')
min_corr=0.8;
end

if ~exist('min_pnr','var')
min_pnr=7;
end

if ~exist('inF','var');
warning('..._CnPNR.mat file does not exist!')
warning('Run ''get_CnPNR_from_video(gSig)'' ')
return
else
[path,file]=fileparts(inF); 
file2=['\',file,'_CnPNR.mat'];
end
m=load(strcat(path,file2),'Cn','PNR');

Mask_path=strcat(path,'\',file,'_mask.mat');
if exist(Mask_path, 'file')>0
    l=load(Mask_path);
    mask=full(l.Mask);
else
    mask=ones(size(m.Cn,1),size(m.Cn,2));
end



estimate_Corr_PNR(m.Cn,m.PNR,Gsig,min_corr,min_pnr,mask);




