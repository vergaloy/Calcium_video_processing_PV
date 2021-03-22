function justdeconv(neuron,deconv_method,type)
%neuron=justdeconv(neuron,'thresholded','ar2');

%'foopsi', 'constrained', 'thresholded'
neuron.options.deconv_options.method =deconv_method;
neuron.options.deconv_options.type =type;
neuron.options.deconv_options.smin=0;
neuron.options.smin=0;
neuron.C_raw(~isfinite(neuron.C_raw))=0;
deconvTemporal(neuron, 1);



  % neuron.orderROIs('pnr');   % order neurons in different ways {'snr', 'decay_time', 'mean', 'circularity'}
   % neuron.viewNeurons([], neuron.C_raw);