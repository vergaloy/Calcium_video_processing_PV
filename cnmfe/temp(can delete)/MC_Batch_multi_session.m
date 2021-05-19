function MC_Batch_multi_session()

theFiles = uipickfiles('FilterSpec','*.h5');

for k=1:length(theFiles)  
    clearvars -except filePattern theFiles k myFolder
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
% output file:
 [filepath,name]=fileparts(fullFileName);
  out=strcat(filepath,'\',name,'_mc','.h5');
    
    if ~isfile(out)  
    V=h5read(fullFileName,'/Object');
    [Mr,~]=motion_correct_PV(V);
    %% save MC video as .h5   
    saveash5(Mr,out);   
    end
end