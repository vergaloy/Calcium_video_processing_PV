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

if ~exist('inF','var')
warning('..._CnPNR.mat file does not exist!')
warning('Run ''get_CnPNR_from_video(gSig)'' ')
return
else
[path,file]=fileparts(inF); 
file2=[path,'\',file,'.mat'];
end
m=load(file2);


if ~isfield(m,'Mask')
    m.Mask=ones(size(m.Cn,1),size(m.Cn,2));
    save(file2,'-struct',m,'-append');
end



estimate_Corr_PNR(m.Cn,m.PNR,Gsig,min_corr,min_pnr,m.Mask);




