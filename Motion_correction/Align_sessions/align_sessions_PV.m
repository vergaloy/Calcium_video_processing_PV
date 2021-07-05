function align_sessions_PV(sf,gSig)
% sum

if ~exist('gSig','var')
    gSig = 4;
end

theFiles = uipickfiles('FilterSpec','*.h5');
Vid=cell(1,size(theFiles,1));
Cn=cell(1,size(theFiles,1));

[filepath,name]=fileparts(theFiles{end});
out=strcat(filepath,'\',name,'_Aligned','.h5');
if ~isfile(out)
     
    for i=1:size(theFiles,2)
        fullFileName = theFiles{i};
        fprintf(1, 'Now reading %s\n', fullFileName);
        Mr=h5read(fullFileName,'/Object');
        Cn{i}=mean(Mr,3);
        Vid{i}=Mr;
    end
    
    fprintf(1, 'Calculating  best alignment...\n');
    X=catpad(3,Cn{:}); %Concatenate data
    %% Filter data
    Vf=vesselness_PV(X);
    
    %% perform MC;
    [d1,d2,~] = size(Vf);
    bound1=d1/5;
    bound2=d2/5;
    % exclude boundaries due to high pass filtering effects
    options_r = NoRMCorreSetParms('d1',d1-bound1,'d2',d2-bound2,'bin_width',10,'max_shift',[500,500,500],'iter',1,'correct_bidir',false);
    %% register using filtered data and apply shifts to original data
    tic; [O,shifts,~] = normcorre_batch(Vf(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:),options_r,Vf(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,1)); toc % register filtered data
    %% apply shifts
    premaxM=estimate_mean_motion_flow(Vf,gSig,1,0);
    postmaxM=estimate_mean_motion_flow(O,gSig,0,0);
    fprintf(1, 'Motion estimation before correction: %1.3f\n', premaxM);
    fprintf(1, 'Motion estimation after correction: %1.3f\n', postmaxM);
    
    
    Mr=apply_shifts_PV(Vid,shifts,sf);
    Mr=Mr-min(Mr,[],'all');
    Mr=Mr./max(Mr,[],'all');
    Mr=uint16(Mr.*(2^16));

    %% save Aligned video;
    fprintf(1, 'Saving Aligned Video...\n');
    saveash5(Mr,out);
    out_mat=strcat(filepath,'\',name,'_Aligned.mat');
    
    if ~isfile(out_mat)
        save(out_mat,'O','premaxM','postmaxM');
    else
        save(out_mat,'O','premaxM','postmaxM','-append');
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
upd = textprogressbar(size(Vid,2));
out=[];
k=0;
for i=1:size(Vid,2)
    temp_shift=squeeze(shifts(i).shifts);
    temp=catpad(3,zeros(size(Vid{i},1),size(Vid{i},2)),Vid{i});
    temp=shift_subpixel(double(temp),temp_shift, 'nan');
    temp = temp(:,:,2:end);
    [d1,d2,d3]=size(temp);
    dt = detrend_PV(sf,reshape(temp,[d1*d2,d3]));
    %

    dt=dt-(prctile(dt(:,1:50),5,2)-k);

    k=prctile(dt(:,end-50:end),5,2);
    
    %     temp=reshape(dt,[d1,d2,d3]);
    
    %     if i==1
    %      temp=temp+(2^16-max(temp,[],'all'));
    %      k=mean(temp(:,:,end),'all');
    %     else
    %        k2=mean(temp(:,:,1),'all');
    %        temp=temp+k-k2;
    %        k=mean(temp(:,:,end),'all');
    %     end
    out=[out,dt];
    upd(i);
end

out=reshape(out,d1,d2,[]);

end




