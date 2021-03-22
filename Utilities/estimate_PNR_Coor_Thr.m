function estimate_PNR_Coor_Thr(Gsig,inF,min_corr,min_pnr)

% estimate_PNR_Coor_Thr(4)
if ~exist('Gsig','var')
Gsig=4;
end

if ~exist('min_corr','var')
min_corr=0.7;
end

if ~exist('min_pnr','var')
min_pnr=7;
end

if ~exist('inF','var');
[file,path] = uigetfile('*.mat');
else
[path,file]=fileparts(inF); 
file=['\',file,'_CnPNR.mat'];
end
m=load(strcat(path,file),'Cn','PNR');


estimate_Corr_PNR(m.Cn,m.PNR,Gsig,min_corr,min_pnr);




