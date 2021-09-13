function align_sessions_Nr_PV(sf,gSig,theFiles)
% align_sessions_Nr_PV(10);
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
%      Mot=[];
    for i=1:size(theFiles,2)
        fullFileName = theFiles{i};
        fprintf(1, 'Now reading %s\n', fullFileName);
        Mr=h5read(fullFileName,'/Object');
%         Mot=[Mot,get_motion(Mr)];
        Cn{i}=mat2gray(min(Mr,[],3));
        Vid{i}=Mr;
    end
    
    fprintf(1, 'Calculating  best alignment...\n');
    X=catpad(3,Cn{:}); %Concatenate data
    %% Filter data 
    [shifts,Vf,M,MVf,Scor]=get_shifts_warp(X);
%     S=squeeze(shifts(:,:,:,2));imagesc(S(:,:,1))
    Mr=apply_shifts_PV(Vid,shifts,sf);
    for i=1:size(Mr,3)
        Mr(:,:,i)= medfilt2(Mr(:,:,i));
    end
    
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
get_CnPNR_from_video(gSig,{out});


end


function out=apply_shifts_PV(Vid,shifts,sf)
fprintf(1, 'Applying shifts to video...\n');
out=[];
for i=1:size(Vid,2)
    
    fprintf(1, 'Applying shifts to session #%1f out of %1f...\n', i,size(Vid,2));
    temp=Vid{i};
    [d1,d2,d3]=size(temp);
    t_shift=shifts(:,:,:,i);
    parfor s=1:size(temp,3)
    temp(:,:,s)=imwarp(temp(:,:,s),t_shift);
    end
    
    fprintf(1, 'Detrending...\n');
    dt = detrend_PV(sf,reshape(double(temp),[d1*d2,d3]));
%     dt=dt-(prctile(dt(:,1:50),5,2)-k);
%     k=prctile(dt(:,end-50:end),5,2);
    dt=dt./GetSn(dt);
    out=[out,dt];
end

out=reshape(out,d1,d2,[]);
end

 
 
 
