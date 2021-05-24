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
parfor i=1:size(obj,1)
    temp=medfilt1(obj(i,:),nums*10,'truncate');
    bl=imerode(temp', ones(nums*50, 1));
    %     plot(neuron.C_raw(i,:));hold on;plot(temp);plot(bl);
    out(i,:)=obj(i,:)-bl';
end

out=reshape(out,[d1,d2,d3]);
end
