function get_CnPNR_from_video(gSig,theFiles)
% get_CnPNR_from_video(4);

if ~exist('theFiles','var')
theFiles = uipickfiles('FilterSpec','*.h5');
end

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Calculating PNR & Cn image for %s\n', fullFileName);
    V=h5read(fullFileName,'/Object');
    [Cn_all,PNR_all,Cn,PNR]=get_PNR_coor_greedy_PV(V,gSig);
    
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'.mat');
    
    if ~isfile(out)
        save(out,'Cn_all','PNR_all','Cn','PNR');
    else
        save(out,'Cn_all','PNR_all','Cn','PNR','-append');
    end
    
    
end