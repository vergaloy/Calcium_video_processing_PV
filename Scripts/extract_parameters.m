function X=extract_parameters(obj,ind)
% X=extract_parameters(neuron,ind);

 K = size(obj.C, 1);
for m=1:K
    temp = ar2exp(obj.P.kernel_pars(m)); % Decay
    taud(m,1) = temp(1); 
end

M = full(mean(obj.C,2)'.*sum(obj.A))';  % mean

sparA = full(sqrt(sum(obj.A.^2, 1))./sum(abs(obj.A), 1))';  % sparsity_spatial

sparC = sqrt(sum(obj.C_raw.^2, 2))./sum(abs(obj.C_raw), 2); % sparsity temporal

[circularity,~,cn,Areaest] = get_contoursPV(obj);


    ste=obj.C;
    ste(ste==0)=nan;
    pnr=prctile(ste,99,2);




X=[sparA,sparC,circularity,pnr,cn,Areaest,ind'];

% X=[taud,M,circularity,Areaest];
% 
% X=[sparA,circularity,Areaest];
% 
% kill=isnan(sum(X,2));
% 
% X(isnan(X))=-1;
% 
% X=zscore(X);
% D=squareform(pdist(X));
% 
% mi=mean(D,1);
% thr=median(mi)/0.6745;
mi=circularity;
mi=abs(circularity-median(circularity));
% outL=mi>(thr*3);
% 
% [mu,S,RD,chi_crt]=DetectMultVarOutliers(circularity);
% 
% outL=RD>chi_crt(1);
% 
% % obj.viewNeurons(find(outL), obj.C_raw);
% % obj.viewNeurons(379, obj.C_raw);