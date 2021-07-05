function align_sessions_Nr_PV(sf,gSig)
% align_sessions_Nr_PV(6);
if ~exist('gSig','var')
    gSig = 4;
end

theFiles = uipickfiles('FilterSpec','*.h5');
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
        Cn{i}=median(Mr,3);
        Vid{i}=Mr;
    end
    
    fprintf(1, 'Calculating  best alignment...\n');
    X=catpad(3,Cn{:}); %Concatenate data
    %% Filter data
    [shifts,Vf,M,MVf,Scor]=get_shifts(X);
    
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


function [shifts,Vf,Mr,MVf,Scor]=get_shifts(X)
% exclude boundaries due to high pass filtering effects
Vf=vesselness_PV(X);

[d1,d2,~] = size(Vf);bound1=d1/5;bound2=d2/5;

%% Calculate Regid motion
options_r = NoRMCorreSetParms('d1',d1-bound1,'d2',d2-bound2,'bin_width',2,'max_shift',[500,500,500],'iter',1,'correct_bidir',true,'shifts_method','fft');
[Or,shifts0,~] = normcorre_batch(Vf(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:),options_r); 

%% Calculate Non-rigid motion
[D1,D2,~] = size(Or);
Or=cat(3,Or(:,:,1),Or,Or(:,:,end));

options_nr = NoRMCorreSetParms('d1',D1,'d2',D2,'bin_width',3, ...
    'grid_size',[25,25],'mot_uf',4,'correct_bidir',true,'init_batch',1, ...
    'overlap_pre',5,'overlap_post',5,'max_shift',20,'shifts_method','fft','iter',3);
tic; [MVf,shifts1,~] = normcorre_batch(Or,options_nr); toc % register filtered data
Or(:,:,[1,size(Or,3)])=[];
MVf(:,:,[1,size(MVf,3)])=[];
shifts1(1)=[];
shifts1(end)=[];



%% Calculate total shifts

shifts=shifts1;
for i=1:size(shifts1,1)
shifts(i).shifts=shifts1(i).shifts+shifts0(i).shifts;    
shifts(i).shifts_up=shifts1(i).shifts_up+shifts0(i).shifts_up;
shifts(i).diff=shifts1(i).diff+shifts0(i).diff;
end

%% apply shifts
preRm=estimate_min_correlation(Vf,1,0);
postRm=estimate_min_correlation(Or,0,0);
postNRm=estimate_min_correlation(MVf,0,0);
% preRm=estimate_min_correlation(Vf,1,1);
% postRm=estimate_min_correlation(Or,0,1);
% postNRm=estimate_min_correlation(MVf,0,1);
fprintf(1, 'Min correlation between sessions before rigid motion correction: %1.3f\n',  preRm);
fprintf(1, 'Min correlation between sessions after rigid motion correction: %1.3f\n', postRm);
fprintf(1, 'Min correlation between sessions after Non-rigid correction: %1.3f\n', postNRm);
Scor=[preRm,postRm,postNRm];

options_nr = NoRMCorreSetParms('d1',d1,'d2',d2,'bin_width',3, ...
    'grid_size',[20,20],'mot_uf',4,'correct_bidir',true,'init_batch',1, ...
    'overlap_pre',5,'overlap_post',5,'max_shift',20,'shifts_method','cubic');

Mr = apply_shifts(X,shifts,options_nr,bound1/2,bound2/2);
Mr=Mr-min(Mr,[],'all');Mr=Mr./max(Mr,[],'all');

end

function out=apply_shifts_PV(Vid,shifts,sf)
fprintf(1, 'Applying shifts to video...\n');
[D1,D2,~] = size(Vid{1});
options_nr = NoRMCorreSetParms('d1',D1,'d2',D2,'bin_width',2, ...
    'grid_size',[20,20],'mot_uf',4,'correct_bidir',true,'init_batch',1, ...
    'overlap_pre',5,'overlap_post',5,'max_shift',20,'shifts_method','cubic');

out=[];
k=0;
for i=1:size(Vid,2)
    
    fprintf(1, 'Applying shifts to session #%1f out of %1f...\n', i,size(Vid,2));
    temp=Vid{i};
     [d1,d2,d3] = size(temp);bound1=d1/5;bound2=d2/5;
     
     temp_shift=shifts(i);
     for j=2:d3
         temp_shift(j,1)=temp_shift(1);
     end
     temp = apply_shifts(temp,temp_shift,options_nr,bound1/2,bound2/2); 
    fprintf(1, 'Detrending...\n');
    dt = detrend_PV(sf,reshape(double(temp),[d1*d2,d3]));
    dt=dt-(prctile(dt(:,1:50),5,2)-k);
    k=prctile(dt(:,end-50:end),5,2);
    out=[out,dt];
end

out=reshape(out,d1,d2,[]);

end

 
 
 
