function T=extract_parameters(obj)
% T=extract_parameters(neuron);

 K = size(obj.C, 1);
for m=1:K
    temp = ar2exp(obj.P.kernel_pars(m)); % Decay
    taud(m,1) = temp(1); 
end



sparA = full(sqrt(sum(obj.A.^2, 1))./sum(abs(obj.A), 1))';  % sparsity_spatial

sparC = sqrt(sum(obj.C_raw.^2, 2))./sum(abs(obj.C_raw), 2); % sparsity temporal

[circularity,~,cn,Areaest] = get_contoursPV(obj);


    ste=obj.C;
    ste(ste==0)=nan;
    pnr=prctile(ste,99,2);


M=mean(obj.S,2);

X=[sparA,sparC,circularity,pnr,cn,Areaest,M,taud];

C=num2cell(X,[size(X,1) size(X,2)]);
T = cell2table(C,'VariableNames',{'sparA','sparC','circularity','pnr','cn','Areaest','Mean activity','Tau'});
