% fix_Baseline(round(40*neuron.Fs),neuron)

neuron.Df=GetSn(neuron.C_raw);
neuron.C_raw=neuron.C_raw./neuron.Df;

justdeconv(neuron,'thresholded','ar2');
% scale_to_noise(neuron,40*neuron.Fs);
neuron.merge_high_corr(1, [0.7, -1, -inf]);
[ids,pnr,pnr_inv,outP,outL]=estimate_false_positives(neuron);
neuron.viewNeurons(find(ids), neuron.C_raw);

% neuron.delete(ids);
neuron.save_workspace();