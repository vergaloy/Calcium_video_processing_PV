function detrend_Batch(sf)

theFiles = uipickfiles('FilterSpec','*.h5');

for k=1:length(theFiles)
    clearvars -except theFiles sf k
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
        %% save MC video as .h5
        saveash5(Mr,out);
    end
end

end

function out=detrend2(nums,obj)
[d1,d2,d3]=size(obj);
obj=double(reshape(obj,[d1*d2,d3]));
out=detrend_PV(nums,obj);

out=reshape(out,[d1,d2,d3]);
end



