function [out,pnr,pnr_inv,outP,outL]=estimate_false_positives(neuron);


A=neuron.A;
K = size(A,2);  
dims=[neuron.options.d1  neuron.options.d2];
A = A/spdiags(sqrt(sum(A.^2,1))'+eps,0,K,K);      % normalize to sum 1 for each compoennt
A_com = extract_patch(A,dims,[50,50]);  % extract 50 x 50 patches


C_inv=get_Cinverted(neuron.C_raw,neuron.C,neuron.options.deconv_options);

ste=C_inv;
ste(ste<0.1)=nan;
pnr_inv=prctile(ste,99,2);
% thr=prctile(pnr_inv,95);

ste=neuron.C;
ste(ste<0.5)=nan;
pnr=prctile(ste,99,2);
% outP=pnr<thr;
R=pnr./pnr_inv;
outP=R<3;
% stackedplot(neuron.C_raw(outP,:)');

for i=1:size(A_com,4)
    temp=squeeze(A_com(:,:,:,i));
    T(:,i)=temp(:);
end

D=squareform(pdist(T','cosine'));

mi=mean(D,1);

thr=median(mi)+3*mad(mi,1);
outL=mi'>(thr);
% ou=A_com(:,:,:,outL);
% montage(ou);caxis([0 0.1]);colormap('hot');

% ou2=A_com(:,:,:,~outL);
% figure;montage(ou2);caxis([0 0.1]);colormap('hot');
out=outP | outL;





