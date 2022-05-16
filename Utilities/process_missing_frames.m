function process_missing_frames()

theFiles = uipickfiles('FilterSpec','*.h5');
for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_fix','.h5');
    
    V=h5read(fullFileName,'/Object');
    
    drop=squeeze(sum(sum(V,1),2))==0;
    F_out{1,k}=drop;
    
%     if sum(drop)>0
%         fprintf(1, 'Dropped frames detected in %s\n', fullFileName);
%         V(:,:,drop)=[];
%         saveash5(V,out);
%     else
%         fprintf(1, 'No dropped frames detected in %s\n', fullFileName);
%     end
end

[filepath,name]=fileparts(theFiles{end});
% cellfun(@(x) sum(x)>0,F_out);
out_mat=strcat(filepath,'\',name,'_Aligned.mat');
if ~isfile(out_mat)
    save(out_mat,'F_out');
else
    save(out_mat,'F_out','-append');
end

end
