function ix=cnn_spatial_PV(neuron,auto)

load('model_PV.mat');

 A=full(neuron.A);
 K = size(A,2);  
 dims=[neuron.options.d1  neuron.options.d2];
 A = A/spdiags(sqrt(sum(A.^2,1))'+eps,0,K,K);      % normalize to sum 1 for each compoennt
 A_com = extract_patch(A,dims,[50,50]);  % extract 50 x 50 patches

 testpreds = predict(net,A_com);
 
 ix=testpreds(:,1)>0.5;
 
 if auto
 delete(neuron,find(ix))
 end