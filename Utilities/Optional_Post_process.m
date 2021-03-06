scale_to_noise(neuron);
% neuron.C_raw=fix_Baseline(round(neuron.Fs),neuron);  DONT RUN, this code
% introduce errors when thresholded ar2 model is udes.
neuron.merge_high_corr(1, [0.5, 0, -inf]);
% merge_high_corr_PV(neuron, 1, [0.5,0.1,-inf]);
justdeconv(neuron,'foopsi','ar1',5);

[ids,outP,outL]=estimate_false_positives(neuron);
neuron.viewNeurons(find(ids), neuron.C_raw);
%  neuron.viewNeurons([], neuron.C_raw);

 A=neuron.A;
 K = size(A,2);  
 dims=[neuron.options.d1  neuron.options.d2];
 A = A/spdiags(sqrt(sum(A.^2,1))'+eps,0,K,K);      % normalize to sum 1 for each compoennt
 A_com = extract_patch(A,dims,[50,50]);  % extract 50 x 50 patches
 montage(ou);caxis([0 0.1]);colormap('hot');

neuron.merge_high_corr(1, [0.8, -1, -inf]);

neuron.merge_high_corr(1, [0, 0.5, -inf]);  % temporal
% neuron.delete(ids);

% merge_high_corr_PV(neuron, 1, [0.5,0.1,-inf]);
justdeconv(neuron,'thresholded','ar2',5);
neuron.save_workspace();