% neuron.C_raw=fix_Baseline(round(neuron.Fs),neuron);
y=y./GetSn(y);
b=b./GetSn(b);

strips(b');hold on;strips(y');
y = highpass(neuron.C_raw',0.001,neuron.Fs)';

neuron.Df=GetSn(neuron.C_raw);
neuron.C_raw=neuron.C_raw./neuron.Df;

justdeconv(neuron,'thresholded','ar2',5);
justdeconv(neuron,'foopsi','ar1',5);
% scale_to_noise(neuron,40*neuron.Fs);

[ids,pnr,pnr_inv,outP,outL]=estimate_false_positives(neuron);
neuron.viewNeurons(find(ids), neuron.C_raw);

 A=neuron.A;
 K = size(A,2);  
 dims=[neuron.options.d1  neuron.options.d2];
 A = A/spdiags(sqrt(sum(A.^2,1))'+eps,0,K,K);      % normalize to sum 1 for each compoennt
 A_com = extract_patch(A,dims,[50,50]);  % extract 50 x 50 patches

 ou=A_com(:,:,:,~outL);
%
 montage(ou);caxis([0 0.1]);colormap('hot');
neuron.merge_high_corr(1, [0.5, 0, -inf]);
neuron.merge_high_corr(1, [0.8, -1, -inf]);

neuron.merge_high_corr(1, [0, 0.5, -inf]);  % temporal
% neuron.delete(ids);
neuron.save_workspace();