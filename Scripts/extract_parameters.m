function T=extract_parameters(obj)
% T=extract_parameters(neuron);

 K = size(obj.C, 1);
for m=1:K
    temp = ar2exp(obj.P.kernel_pars(m)); % Decay
    taud(m,1) = temp(1); 
end



sparA = full(sqrt(sum(obj.A.^2, 1))./sum(abs(obj.A), 1))';  % sparsity_spatial

sparC = sqrt(sum(obj.S.^2, 2))./sum(abs(obj.S), 2); % sparsity temporal

[circularity,PNR,cn,Areaest] = get_contoursPV(obj);


    ste=obj.C;
    ste(ste==0)=nan;
    pnr=prctile(ste,99,2);


M=mean(obj.S,2);

X=[sparA,sparC,pnr,circularity,PNR,cn,Areaest,M,taud];

C=num2cell(X);
T = cell2table(C,'VariableNames',{'sparA','sparC','Temporal PNR','circularity','Spatial PNR','cn','Areaest','Mean activity','Tau'});
