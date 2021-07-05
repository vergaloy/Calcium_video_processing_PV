function [out,outC,outA]=estimate_false_positives(neuron)

A=neuron.A;
K = size(A,2);  
dims=[neuron.options.d1  neuron.options.d2];
A = A/spdiags(sqrt(sum(A.^2,1))'+eps,0,K,K);      % normalize to sum 1 for each compoennt
A_com = extract_patch(A,dims,[50,50]);  % extract 50 x 50 patches


C_inv=get_Cinverted(neuron.C_raw,neuron.C,neuron.options.deconv_options);

R=mean(neuron.C,2)./(mean(neuron.C,2)+mean(C_inv,2));
outC=R<0.95;



% stackedplot(neuron.C_raw(outP,:)');

for i=1:size(A_com,4)
    temp=squeeze(A_com(:,:,:,i));
    T(:,i)=temp(:);
end

D=squareform(pdist(T','cosine'));

mi=mean(D,1);

thr=median(mi)+3*mad(mi,1);
outA=mi'>(thr);
% ou=A_com(:,:,:,outL);
% montage(ou);caxis([0 0.1]);colormap('hot');

% ou2=A_com(:,:,:,~outL);
% figure;montage(ou2);caxis([0 0.1]);colormap('hot');
out=outC | outA;





