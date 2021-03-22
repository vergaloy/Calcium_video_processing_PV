function align_sessions_PV()

myFolder=uigetdir;
filePattern = fullfile(myFolder, '*mc.h5');
theFiles = dir(filePattern);
Vid=cell(1,size(theFiles,1));
Cn=cell(1,size(theFiles,1));

for i=1:size(theFiles,1)
    baseFileName = theFiles(i).name;
    fullFileName = fullfile(myFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    temp=h5read(fullFileName,'/Object');
    Vid{i}=temp;
    Cn{i}=mean(temp,3);
end
[filepath,name]=fileparts(fullFileName);
out=strcat(filepath,'\',name,'_Aligned','.h5');


if ~isfile(out)   
    fprintf(1, 'Calculating  best alignment...\n');  
    X=catpad(3,Cn{:}); %Concatenate data
    %% Filter data
    Vf=vesselness_PV(X);
    
    %% perform MC;
    [d1,d2,~] = size(Vf);
    bound=d1/5;
    % exclude boundaries due to high pass filtering effects
    options_r = NoRMCorreSetParms('d1',d1-bound,'d2',d2-bound,'bin_width',200,'max_shift',20,'iter',1,'correct_bidir',false);
    %% register using filtered data and apply shifts to original data
    tic; [~,shifts,~] = normcorre_batch(Vf(bound/2+1:end-bound/2,bound/2+1:end-bound/2,:),options_r); toc % register filtered data
    %% apply shifts
    Mr=apply_shifts_PV(Vid,shifts);
    Mr=uint16(catpad(3,Mr{:}));
    %% remove black borders
    Mr=remove_borders(Mr);
%     Ca_video_viewer(V); 
    %% save Aligned video;
    fprintf(1, 'Saving Aligned Video...\n');  
    saveash5(Mr,out);
else
fprintf(1, 'Video file was already aligned...\n');    
end


end


function out=apply_shifts_PV(Vid,shifts)
fprintf(1, 'Applying shifts to video...\n');
upd = textprogressbar(size(Vid,2));
out=cell(1,size(Vid,2));
for i=1:size(Vid,2)
    temp_shift=squeeze(shifts(i).shifts);
    temp=catpad(3,zeros(size(Vid{i},1),size(Vid{i},2)),Vid{i});
    temp=shift_subpixel(double(temp),temp_shift, 'nan');
    out{i} = uint16(temp(:,:,2:end));
    upd(i);
end
end



