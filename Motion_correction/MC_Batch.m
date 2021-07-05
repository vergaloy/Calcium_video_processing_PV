function MC_Batch()

theFiles = uipickfiles('FilterSpec','*.h5');

for k=1:length(theFiles)  
    clearvars -except filePattern theFiles k myFolder
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
% output file:
 [filepath,name]=fileparts(fullFileName);
  out=strcat(filepath,'\',name,'_mc','.h5');
  out_mat=strcat(filepath,'\',name,'_mc_M','.mat');
    
    if ~isfile(out)  
    V=h5read(fullFileName,'/Object');
    [Mr,Vf]=motion_correct_PV(V);
    
    M=get_motion(Vf);
    
    if ~isfile(out_mat)
        save(out_mat,'M');
    else
        save(out_mat,'M','-append');
    end
    
    %% save MC video as .h5   
    saveash5(Mr,out);   
    end
end