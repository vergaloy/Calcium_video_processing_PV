function [Mr,VF]=motion_correct_NonRigid_PV(V)

VF=vesselness_PV(V);

[d1,d2,~] = size(VF);
bound1=d1/10;
bound2=d2/10;
% exclude boundaries due to high pass filtering effects
options_r = NoRMCorreSetParms('d1',d1-bound1,'d2',d2-bound2,'bin_width',200,'max_shift',[500,500,500],'iter',1,'correct_bidir',false,'shifts_method','fft');

%% register using the high pass filtered data and apply shifts to original data
tic; [Or,shifts0,~] = normcorre_batch(VF(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:),options_r); toc % register filtered data


[D1,D2,~] = size(Or);
options_nr = NoRMCorreSetParms('d1',D1,'d2',D2,'bin_width',200, ...
    'grid_size',[20,20],'mot_uf',4,'correct_bidir',false, ...
    'overlap_pre',5,'overlap_post',5,'max_shift',[5,5,5],'shifts_method','cubic');
% tic; [test,shifts1,~] = normcorre_batch(Or,options_nr); toc % register filtered data
tic; [~,shifts1,~] = normcorre_batch(Or,options_nr); toc % register filtered data


%% Calculate total shifts
shifts=shifts1;
for i=1:size(shifts1,1)
    shifts(i).shifts=shifts1(i).shifts+shifts0(i).shifts;
    shifts(i).shifts_up=shifts1(i).shifts_up+shifts0(i).shifts_up;
    shifts(i).diff=shifts1(i).diff+shifts0(i).diff;
end

options_nr = NoRMCorreSetParms('d1',d1,'d2',d2,'bin_width',200, ...
    'grid_size',[20,20],'mot_uf',4,'correct_bidir',false, ...
    'overlap_pre',5,'overlap_post',5,'max_shift',[500,500,500],'shifts_method','cubic');
% exclude boundaries due to high pass filtering effects


tic; Mr = apply_shifts(V,shifts,options_nr,bound1/2,bound2/2); toc % apply shifts to full dataset
% Mr=double(Mr);Mr=Mr-min(Mr,[],'all');Mr=Mr./max(Mr,[],'all');

