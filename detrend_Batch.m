function detrend_Batch(sf,gSig,theFiles)
if ~exist('gSig','var')
    gSig = 3;
end

if ~exist('theFiles','var')
theFiles = uipickfiles('FilterSpec','*.h5');
end

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_det','.h5');
    
    if ~isfile(out)
        V=h5read(fullFileName,'/Object');
        Mr=detrend2(sf,V);
        Mr=Mr-min(Mr,[],'all');
        Mr=Mr./max(Mr,[],'all');
        Mr=uint16(Mr.*(2^16));
        for i=1:size(Mr,3)
        Mr(:,:,i)= medfilt2(Mr(:,:,i));
        end
        %% save MC video as .h5
   
        saveash5(Mr,out);
        [filepath,name]=fileparts(out);
        out_mat=strcat(filepath,'\',name,'.mat');
        get_frame_list(theFiles(k),out_mat);
        get_CnPNR_from_video(gSig,{out},size(V,3));
        
       
    end
end

end

function out=detrend2(nums,obj)
[d1,d2,d3]=size(obj);
obj=double(reshape(obj,[d1*d2,d3]));
out=detrend_PV(nums,obj);
out=out./GetSn(out);
out=reshape(out,[d1,d2,d3]);
end



