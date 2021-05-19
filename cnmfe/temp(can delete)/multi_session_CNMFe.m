function multi_session_CNMFe(in,PNR_th,Coor_th,gSig,sf)
%% choose data
neuron = Sources2D();
if exist('in','var')
    nam=in;
else
    nam = [];% get_fullname('./data_1p.tif');          % this demo data is very small, here we just use it as an example
end
neuron.select_multiple_files({nam});  %if nam is [], then select data interactively

%% parameters
% -------------------------    COMPUTATION    -------------------------  %
pars_envs = struct('memory_size_to_use', 256, ...   % GB, memory space you allow to use in MATLAB
    'memory_size_per_patch', 32, ...   % GB, space for loading data within one patch
    'patch_dims', [64, 64],'batch_frames', 1);    %GB, patch size

% -------------------------      SPATIAL      -------------------------  %
% pixel, gaussian width of a gaussian kernel for filtering the data. usualy 1/3 of neuron diameter
gSiz = gSig*3;          % pixel, neuron diameter
ssub = 1;           % spatial downsampling factor
with_dendrites = true;   % with dendrites or not
if with_dendrites
    % determine the search locations by dilating the current neuron shapes
    updateA_search_method = 'dilate';  %#ok<UNRCH>
    updateA_bSiz = 5;
    updateA_dist = neuron.options.dist;
else
    % determine the search locations by selecting a round area
    updateA_search_method = 'ellipse'; %#ok<UNRCH>
    updateA_dist = 5;
    updateA_bSiz = neuron.options.dist;
end
spatial_constraints = struct('connected', true, 'circular', false);  % you can include following constraints: 'circular'
spatial_algorithm = 'hals_thresh';

% -------------------------      TEMPORAL     -------------------------  %
Fs = sf;             % frame rate
tsub = 1;           % temporal downsampling factor
deconv_flag = true;     % run deconvolution or not
deconv_options = struct('type', 'ar1', ... % model of the calcium traces. {'ar1', 'ar2'}
    'method', 'foopsi', ... % method for running deconvolution {'foopsi', 'constrained', 'thresholded'}
    'smin', -5, ...         % minimum spike size. When the value is negative, the actual threshold is abs(smin)*noise level
    'optimize_pars', true, ...  % optimize AR coefficients
    'optimize_b', true, ...% optimize the baseline);
    'max_tau', 100);    % maximum decay time (unit: frame);

nk = 3;             % detrending the slow fluctuation. usually 1 is fine (no detrending)
% when changed, try some integers smaller than total_frame/(Fs*30)
detrend_method = 'spline';  % compute the local minimum as an estimation of trend.

% -------------------------     BACKGROUND    -------------------------  %
bg_model = 'ring';  % model of the background {'ring', 'svd'(default), 'nmf'}
nb = 1;             % number of background sources for each patch (only be used in SVD and NMF model)
bg_neuron_factor = 1.4;
ring_radius = round(bg_neuron_factor * gSiz);   % when the ring model used, it is the radius of the ring used in the background model.
%otherwise, it's just the width of the overlapping area
num_neighbors = []; % number of neighbors for each neuron
bg_ssub = 1;        % downsample background for a faster speed

% -------------------------      MERGING      -------------------------  %
show_merge = false;  % if true, manually verify the merging step
merge_thr = 0.65;     % thresholds for merging neurons; [spatial overlap ratio, temporal correlation of calcium traces, spike correlation]
method_dist = 'max';   % method for computing neuron distances {'mean', 'max'}
dmin = 5;       % minimum distances between two neurons. it is used together with merge_thr
merge_thr_spatial = [0.8, 0.4, -inf];  % merge components with highly correlated spatial shapes (corr=0.8) and small temporal correlations (corr=0.1)

% -------------------------  INITIALIZATION   -------------------------  %
K = [];             % maximum number of neurons per patch. when K=[], take as many as possible.
min_corr = Coor_th;     % minimum local correlation for a seeding pixel
min_pnr = PNR_th;       % minimum peak-to-noise ratio for a seeding pixel
min_pixel = (gSig^2)/2;      % minimum number of nonzero pixels for each neuron
bd = 0;             % number of rows/columns to be ignored in the boundary (mainly for motion corrected data)
save_initialization = false;    % save the initialization procedure as a video.
use_parallel = true;    % use parallel computation for parallel computing
center_psf = true;  % set the value as true when the background fluctuation is large (usually 1p data)
% set the value as false when the background fluctuation is small (2p)


% -------------------------    UPDATE ALL    -------------------------  %
neuron.updateParams('gSig', gSig, ...       % -------- spatial --------
    'gSiz', gSiz, ...
    'ring_radius', ring_radius, ...
    'ssub', ssub, ...
    'search_method', updateA_search_method, ...
    'bSiz', updateA_bSiz, ...
    'dist', updateA_bSiz, ...
    'spatial_constraints', spatial_constraints, ...
    'spatial_algorithm', spatial_algorithm, ...
    'tsub', tsub, ...                       % -------- temporal --------
    'deconv_flag', deconv_flag, ...
    'deconv_options', deconv_options, ...
    'nk', nk, ...
    'detrend_method', detrend_method, ...
    'background_model', bg_model, ...       % -------- background --------
    'nb', nb, ...
    'ring_radius', ring_radius, ...
    'num_neighbors', num_neighbors, ...
    'bg_ssub', bg_ssub, ...
    'merge_thr', merge_thr, ...             % -------- merging ---------
    'dmin', dmin, ...
    'method_dist', method_dist, ...
    'min_corr', min_corr, ...               % ----- initialization -----
    'min_pnr', min_pnr, ...
    'min_pixel', min_pixel, ...
    'bd', bd, ...
    'center_psf', center_psf);
neuron.Fs = Fs;
[filepath,name]=fileparts(in);
load([filepath,'\',name,'_frames.mat'],'F');
neuron.frame_range=F; 
%% distribute data and be ready to run source extraction
neuron.getReady_batch(pars_envs);

%% initialize neurons in batch mode
neuron.initComponents_batch(K, save_initialization, 1);
%% udpate spatial components for all batches
neuron.update_spatial_batch(use_parallel);

%% udpate temporal components for all bataches
neuron.update_temporal_batch(use_parallel);
%% update background
neuron.update_background_batch(use_parallel);
neuron.update_temporal_batch(use_parallel);
standarize_C_raw(neuron)
%% get the correlation image and PNR image for all neurons
neuron.correlation_pnr_batch();
[neuron.PNR_all,neuron.Cn_all]=create_PNR_batch(neuron);
%% concatenate temporal components of each batch
concatenate_shifted_batch(neuron);
neuron.P=neuron.batches{1, 1}.neuron.P;
% neuron.frame_range=[1,size(neuron.C_raw,2)];
justdeconv(neuron,'foopsi','ar1',5);


% neuron=justdeconv(neuron,'foopsi','ar2'); % you can change this to foopsi
% fix_Baseline(round(40*neuron.Fs),neuron)%% PV this may not be necessary, but can be useful to correct for slow fluctuation in the calcium traces when recordings are very long
% %sometimes it decrease the amount of false-positives spikes.
% 
% 
% scale_to_noise(neuron,500); %this is to fix the differences in the basline noise level across batches.
% neuron=justdeconv(neuron,'foopsi','ar2');

neuron.merge_neurons_dist_corr(0);
neuron.merge_high_corr(0, [0.6, -1, -inf]);



neuron.orderROIs('snr');
%% save workspace
neuron.P.log_folder=strcat(neuron.P.folder_analysis,filesep);
neuron.P=neuron.batches{1, 1}.neuron.P;
get_frame_ranges(neuron);

neuron.save_workspace_batch();  %save batch data
fclose('all');
neuron.batches=0;  %kill batch data, it is not necessary to laod it again

neuron.P.log_folder=strcat(neuron.P.folder_analysis,filesep);
cnmfe_path = neuron.save_workspace();

end

%% USEFULL COMMANDS

%%  To manually inspect spatial and temporal components of each neuron
%   neuron.orderROIs('snr');   % order neurons in different ways {'snr', 'decay_time', 'mean', 'circularity','sparsity_spatial','sparsity_temporal','pnr'}
%   neuron.viewNeurons([], neuron.C_raw);

%% To save results in a new path run these lines a choose the new folder:
%   neuron.P.log_file=strcat(uigetdir,filesep,'log_',date,'.txt');
%   neuron.P.log_folder=strcat(uigetdir,'\'); %update the folder
%   cnmfe_path = neuron.save_workspace();
%% To visualize neurons contours:
%   neuron.Coor=[]
%   neuron.show_contours(0.9, [], neuron.PNR, 0)  %PNR
%   neuron.show_contours(0.6, [], neuron.Cn, 0)   %CORR
%   neuron.show_contours(0.6, [], neuron.PNR.*neuron.Cn, 0); %PNR*CORR
%% normalized spatial components
% A=neuron.A;A=full(A./max(A,[],1)); A=reshape(max(A,[],2),[size(neuron.Cn,1),size(neuron.Cn,2)]);
% neuron.show_contours(0.6, [], A, 0);
%% To visualize the PNR and CORR in each batch
%   implay(cat(2,mat2gray(neuron.PNR_all),mat2gray(neuron.Cn_all)),5);

%% to visualize all temporal traces
%   strips(neuron.C_raw');
%   stackedplot(neuron.C_raw');

%% Manually merge very close neurons
% neuron.merge_high_corr(1, [0.2, -1, -inf]);



