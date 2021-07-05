function [merged_ROIs, newIDs, obj_bk]  = merge_high_corr_PV(obj, show_merge, merge_thr)

% merge_high_corr_PV(neuron, 1, [0.5,0.1,-inf])
%% PV
% This code was modified in 3 aspects:
% 1) Merging is based on cosine similarity rather than correlation (it is better for sparse and zero-inflated data)
% 2) Merging is done based on the raw calcium trace
% 3) Merging is done with hierarchical clustering using 'complete' linkage. The original CNMF-E implementation merges all connected components,
% % even if some of the components inside a cluster do not satisfy the merging conditions. The original CNMF-E implementation is 
% from the hierarchical clustering persepective equivalent to a "single" merging method. Here we use the "complete" linkage instead.


%% variables & parameters
fprintf('-------------MERGE HIGHLY CORRELATED NEURONS----------\n\n');

A_ = obj.A;          % spatial components
if isempty(obj.C_raw)
    obj.C_raw = obj.C;
end
C_raw_ = obj.C_raw;

if ~exist('show_merge', 'var') || isempty(show_merge)
    show_merge = false;
end
if show_merge
    cols = [0, 0, 1; 0, 1, 0; 0, 1, 1; 1, 0, 0; 1, 0, 1; 1, 1, 0; 1, 1, 1];
    h_fig = figure('position', [1,1, 1200, 600]);
    stop_show = false;
end
if ~exist('merge_thr', 'var') || isempty(merge_thr) || numel(merge_thr)~=3
    merge_thr = obj.options.merge_thr;
end
if length(merge_thr)==1
    merge_thr = [0, merge_thr, 0];
end
A_thr = merge_thr(1);
C_thr = merge_thr(2);
deconv_options_0 = obj.options.deconv_options;

%% find neuron pairs to merge
% compute spatial correlation

%% using merging criterion to detect paired neurons

Z=linkage(full(A_)','complete','cosine');
L=find_leaves_in_node(Z);
[clus,~]=get_clusters(Z(:,3)<(1-A_thr),L);

parfor i=1:size(clus,1)
t=clus{i};
Zt=linkage(C_raw_(t,:),'complete','cosine');
Lt=find_leaves_in_node(Zt);
[Ct,~]=get_clusters(Zt(:,3)<(1-C_thr),Lt);
temp=cellfun(@(x) t(x),Ct,'UniformOutput',false);
Ca{i,1}=temp;
end

M = cat(1,Ca{:});
N=cell2mat(cellfun(@(x) length(x),M,'UniformOutput',false));
%% write log file
% folders and files for saving the results
log_file =  obj.P.log_file;
flog = fopen(log_file, 'a');
log_data = matfile(obj.P.log_data, 'Writable', true); %#ok<NASGU>

try
    fprintf(flog, '[%s]\b', get_minute());
    fprintf(flog, 'Start Merging neurons based on temporal correlations:\n ');
    fprintf(flog, '\tThresholds:\n');
    fprintf(flog, '\t\tTemporal correlation of C: %.3f\n', C_thr);
    fprintf(flog, '\t\tSpatial overlaps: %.3f\n', A_thr);
    
    if isempty(M)
        fprintf('All pairs of neurons are below the merging criterion!\n\n');
        fprintf(flog, '\tAll pairs of neurons are below the merging criterion!\n\n ');
        fclose(flog);
        try
            close(h_fig);
        end
        return;
    else
        fprintf('%d neurons will be merged into %d new neurons\n\n', sum(N), length(N));
        fprintf(flog, '\t%d neurons will be merged into %d new neurons.\n', sum(N), length(N));
        if show_merge
            fprintf(flog, '\tYou chose to manually verify each merge.\n');
        end
    end
catch
    
end
%% start merging
obj_bk = obj.copy();
n2merge=size(M,1);
nr=size(C_raw_,1);

ind_del = false(nr, 1 );    % indicator of deleting corresponding neurons
merged_ROIs = cell(n2merge,1);
newIDs = zeros(nr, 1);      % indices of the new neurons
k_merged = 0;
k_neurons = 0;
m=1;
while m <= n2merge
    IDs = M{m};   % IDs of neurons within this cluster
    
    % manually verify the merge
    if show_merge && (~stop_show)
        figure(h_fig);
        [tmp_img, col, ~] = obj_bk.overlapA(IDs, 0.1);
        subplot(221);
        imagesc(tmp_img);
        axis equal off tight;
        subplot(222);
        imagesc(tmp_img);
        axis equal off tight;
        [tmp_r, tmp_c, ~] = find(sum(tmp_img, 3)>0);
        xlim([min(tmp_c)-10, max(tmp_c)+10]);
        ylim([min(tmp_r)-10, max(tmp_r)+10]);
        axis off;
        subplot(2,2,3:4); cla;
        aa = sum(obj_bk.A(:, IDs),1);
        tmp_C = obj_bk.C_raw(IDs, :);
        %         tmp_C = bsxfun(@times, tmp_C, 1./max(tmp_C, [], 1));
        for mm=1:size(tmp_C, 1)
            hold on;
            plot(tmp_C(mm,:)*aa(mm), 'color', cols(col(mm), :),  'linewidth', 2);
        end
        title(num2str(reshape(IDs, 1, []))); 
        pause(0.1);
        temp = input('keep this merge? (y(default)/n(cancel)/back(b)/merge&delete(md)/end showing(e): ', 's');
        
        if strcmpi(temp, 'n')
            m = m+1;
            continue;
        elseif strcmpi(temp, 'b')
            m = m-1;
            continue;
        elseif strcmpi(temp, 'e')
            stop_show = true;
        elseif strcmpi(temp, 'md')
            ind_del(IDs) = true;
            m = m+1;
            continue;
        end
    end
    k_merged = k_merged+1;
    k_neurons = k_neurons+length(IDs);
    merged_ROIs{k_merged} = IDs;
    
    % determine searching area
    active_pixel = (sum(A_(:,IDs), 2)>0);
    
    % update spatial/temporal components of the merged neuron
    data = A_(active_pixel, IDs)*C_raw_(IDs, :);
    ci = C_raw_(IDs(1), :);
    for miter=1:10
        ai = data*ci'/(ci*ci');
        ci = ai'*data/(ai'*ai);
    end
    
    obj.A(active_pixel, IDs(1)) = ai;
    obj.C_raw(IDs(1), :) = ci;
    %     [obj.C(IDs(1), :), obj.S(IDs(1), :), tmp_kernel] = deconvCa(ci, obj.kernel, 3, true, false);
    try
        [obj.C(IDs(1), :), obj.S(IDs(1),:), deconv_options] = deconvolveCa(ci, deconv_options_0);
        obj.P.kernel_pars(IDs(1), :) = deconv_options.pars(1);  %% PV fix.
        newIDs(IDs(1)) = IDs(1);
        % remove merged elements
        ind_del(IDs(2:end)) = true;
    catch
        ind_del(IDs) = true;
    end
    m = m+1;
end

newIDs(ind_del) = [];
newIDs = find(newIDs);
merged_ROIs = merged_ROIs(1:k_merged);
%% write to the log file
if isempty(newIDs)
    fprintf('\tYou manually eliminate all merges\n');
    fprintf(flog,'[%s]\bYou have manually eliminate all merges\n', get_minute());
    return;
elseif length(newIDs)==n2merge
    fprintf(flog, '[%s]\bYou approved all merges.\n', get_minute());
else
    fprintf('After manual verification, %d neurons have ben merged into %d new neurons\n\n', k_neurons, k_merged);
    fprintf(flog, '[%s]\bAfter manual verification, %d neurons have ben merged into %d new neurons\n\n', get_minute(), k_neurons, k_merged);
end

merge_results = cell(length(newIDs),1);
for m=1:length(newIDs)
    ind_before = merged_ROIs{m};
    ids_merged = obj_bk.ids(ind_before);
    ind_after = ind_before(1);
    ids_new = obj.ids(ind_after);
    fprintf(flog, '\t\t');
    for k=1:length(ids_merged)
        fprintf(flog, '%d, ', ids_merged(k));
    end
    fprintf(flog, '---> %d\n', ids_new);
    merge_records.before = obj_bk.obj2struct(ind_before);
    merge_records.after = obj.obj2struct(ind_after);
    merge_results{m} = merge_records;
end
% folders and files for saving the results
tmp_str = get_date();
tmp_str=strrep(tmp_str, '-', '_');
eval(sprintf('log_data.merge_%s = merge_results;', tmp_str));
fprintf(flog, '\tThe spatial and temporal components of the merged neurons were saved as intermediate_results.merge_%s\n', tmp_str);
fprintf(flog, '\tNow the old neurons will be deleted and the merged new ones will replace them.\n\n');
fclose(flog);

% remove merged neurons and update obj
obj.delete(ind_del);
try
    close(h_fig);
end