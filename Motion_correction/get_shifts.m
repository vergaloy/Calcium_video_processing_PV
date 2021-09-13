function [shifts,Vf,Mr,MVf,Scor]=get_shifts(X)

Vf=vesselness_PV(X);

[s1,s2,~] = size(Vf);bound1=s1/5;bound2=s2/5;

%% Calculate Regid motion
options_r = NoRMCorreSetParms('d1',s1-bound1,'d2',s2-bound2,'bin_width',2,'max_shift',[500,500,500],'iter',1,'correct_bidir',false,'shifts_method','fft');
[MVf,shifts0,~] = normcorre_batch(Vf(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:),options_r);
Or=MVf;
[D1,D2,~] = size(MVf);

for i=1:5
    siz=30-(i-1)*2;
    options_nr = NoRMCorreSetParms('d1',D1,'d2',D2,'bin_width',3, ...
        'grid_size',[siz,siz],'mot_uf',4,'correct_bidir',false,'init_batch',1, ...
        'overlap_pre',round(siz/5)+1,'overlap_post',round(siz/5)+1,'shifts_method','linear','iter',1);
    tic; [MVf,shifts_nr{i},~] = normcorre_batch(MVf,options_nr); toc % register filtered data
end
shifts=cell(1,size(shifts_nr,2)+1);
shifts{1}=shifts0;
shifts(1,2:end)=shifts_nr;


%% Addup shifts
Out=shifts{1, end};
for ses=1:size(Out,1)
    
    temp_0=shifts{1, size(shifts,2)}(ses).shifts;
    [d1,d2,~,~]=size(temp_0);
    temp=zeros(d1,d2,1,2);
    for i=1:size(shifts,2)-1
        temp2=shifts{1, i}(ses).shifts;
        temp=temp+cat(4,imresize(temp2(:,:,1,1),[d1 d2],'nearest'),imresize(temp2(:,:,1,2),[d1 d2],'nearest'));
    end
    temp=temp_0+temp;
    
    Out(ses).shifts=temp;
    
    %% get shifts up
    
    temp_0=shifts{1, size(shifts,2)}(ses).shifts_up  ;
    [d1,d2,~,~]=size(temp_0);
    temp=zeros(d1,d2,1,2);
    for i=1:size(shifts,2)-1
        temp2=shifts{1, i}(ses).shifts_up;
        temp=temp+cat(4,imresize(temp2(:,:,1,1),[d1 d2],'nearest'),imresize(temp2(:,:,1,2),[d1 d2],'nearest'));
    end
    temp=temp_0+temp;
    Out(ses).shifts_up=temp;
    
    %% get diff
    
    temp_0=shifts{1, size(shifts,2)}(ses).diff  ;
    [d1,d2]=size(temp_0);
    temp=zeros(d1,d2);
    for i=1:size(shifts,2)-1
        temp2=squeeze(shifts{1, i}(ses).diff);
        temp=temp+imresize(temp2,[d1 d2],'nearest');
    end
    temp=temp_0+temp;
    Out(ses).diff=temp;
end
shifts=Out;
%% standarize realtive to session 1
s=shifts(1).shifts;
su=shifts(1).shifts_up;
di=shifts(1).diff;

for i=1:size(shifts,1)
shifts(i).shifts=shifts(i).shifts-s;
shifts(i).shifts_up=shifts(i).shifts_up-su;
shifts(i).diff=shifts(i).diff-di;
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
options_nr.shifts_method='cubic';
options_nr.d1=s1;
options_nr.d2=s2;  

Mr = apply_shifts(X,shifts,options_nr,bound1/2,bound2/2);
Mr=Mr-min(Mr,[],'all');Mr=Mr./max(Mr,[],'all');
end