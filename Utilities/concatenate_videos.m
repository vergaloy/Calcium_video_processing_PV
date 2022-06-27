function concatenate_videos(theFiles)

if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
end

Vout=[];

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_conc','.h5');
    V=h5read(fullFileName,'/Object');
    Vout=cat(3,Vout,V);
end
saveash5(Vout,out);
end



