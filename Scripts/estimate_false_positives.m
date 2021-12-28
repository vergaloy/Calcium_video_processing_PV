function [out,outC,outA]=estimate_false_positives(obj)

justdeconv(obj,'foopsi','ar1',-5);
C_inv=get_Cinverted(obj.C_raw,obj.C,obj.options.deconv_options);
R=sum(obj.C.^2,2)./(sum(obj.C.^2,2)+sum(C_inv.^2,2));
outC=R<0.95;

A=full(obj.A);
A=A./max(A,[],1);
K = size(A,2);  
dims=[obj.options.d1  obj.options.d2];
A_com = extract_patch(A,dims,[50,50]);  % extract 50 x 50 patches
A_com=squeeze(A_com);


% stackedplot(neuron.C_raw(outC,:)');

for i=1:size(A_com,3)
    temp=squeeze(A_com(:,:,i));
    T(:,i)=double((temp(:)./max(temp(:))));
end


%  [outA,value] = cnn_classifier(A,dims,'cnn_model.h5',0.05);

 
D=squareform(pdist(T','cosine'));

mi=median(D,1);

thr=median(mi)+3*mad(mi,1);
outA=mi'>(thr);
% ou=A_com(:,:,outA);
% figure;montage(mat2gray(ou));caxis([0 0.7]);colormap('hot');

% ou2=A_com(:,:,~outA);
% figure;montage(mat2gray(ou2));caxis([0 0.7]);colormap('hot');
out=outC | outA;





