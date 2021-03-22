function get_CnPNR_from_video(gSig)
% get_CnPNR_from_video(4);
theFiles = uipickfiles('FilterSpec','*.h5');
for k=1:length(theFiles)
    clearvars -except filePattern theFiles k gSig
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    V=h5read(fullFileName,'/Object');
    [Cn_all,PNR_all,Cn,PNR]=get_PNR_coor_greedy_PV(V,gSig);
    
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_CnPNR','.mat');  
    save(out,'Cn_all','PNR_all','Cn','PNR');
end