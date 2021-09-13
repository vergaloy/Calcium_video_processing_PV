function align_sessions_PV(sf,gSig,theFiles)
% align_sessions_PV(10);
if ~exist('gSig','var')
    gSig = 4;
end

if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
end
Vid=cell(1,size(theFiles,1));
Cn=cell(1,size(theFiles,1));

[filepath,name]=fileparts(theFiles{end});
out=strcat(filepath,'\',name,'_Aligned','.h5');
if ~isfile(out)
    for i=1:size(theFiles,2)
        fullFileName = theFiles{i};
        fprintf(1, 'Now reading %s\n', fullFileName);
        Mr=h5read(fullFileName,'/Object');
        F(i,1)=size(Mr,3);
        fprintf(1, 'Detrending %s\n', fullFileName);
        Vf(:,:,i)=vesselness_PV(min(Mr,[],3),0,0.5:0.05:1.5);
        Mr=det_video(Mr,sf);
        [~,~,cn,~]=get_PNR_coor_greedy_PV(Mr,gSig);
        Cn{i}=cn;
        Vid{i}=Mr;      
    end
    
    fprintf(1, 'Calculating  best alignment...\n');
    C=catpad(3,Cn{:}); %Concatenate data
    X=max(cat(4,C,Vf),[],4);
    
    [shifts,~,M,MVf,Scor]=get_shifts_warp(X,0,0,2);
    Mr=apply_shifts_PV(Vid,shifts);
    
    Mr=Mr-min(Mr,[],'all');
    Mr=Mr./max(Mr,[],'all');
    Mr=uint16(Mr.*(2^16));
    
    meanVid={X,M,Vf,MVf};
    
    %% save Aligned video;
    fprintf(1, 'Saving Aligned Video...\n');
    saveash5(Mr,out);
    out_mat=strcat(filepath,'\',name,'_Aligned.mat');
    
    if ~isfile(out_mat)
        save(out_mat,'meanVid','Scor');
    else
        save(out_mat,'meanVid','Scor','-append');
    end
    
    
else
    fprintf(1, 'Video file was already aligned...\n');
end
[filepath,name]=fileparts(out);
out_mat=strcat(filepath,'\',name,'.mat');
get_frame_list(theFiles,out_mat);
get_CnPNR_from_video(gSig,{out},F);

end


function out=det_video(in,sf)
[d1,d2,d3]=size(in);
dt = detrend_PV(sf,reshape(double(in),[d1*d2,d3]));
dt=dt./GetSn(dt);
out=reshape(dt,d1,d2,d3);
end


