function [Shifts,P,Scor]=get_shifts_alignment(P)

opt = struct('niter',300, 'sigma_fluid',2,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',1,'stop_criterium',0.002);

Vf=v2uint8(cell2mat(P{1,2}));
C=v2uint8(cell2mat(P{1,3}));
X=v2uint8(cell2mat(P{1,5}));
% [D,ans] = imregdemons(Vf(:,:,i),Vf(:,:,i-1));
parfor i=2:size(Vf,3)
    M1=cat(3,X(:,:,i-1),Vf(:,:,i-1),Vf(:,:,i-1));
    M2=cat(3,X(:,:,i),Vf(:,:,i),Vf(:,:,i));    
    [~,~,Shifts(:,:,:,i)]=MR_Log_demon(M1,M2,opt);
end
Shifts=cumsum(Shifts,4);
Shifts=Shifts-mean(Shifts,4);
for k=1:size(P,2)
    temp=cell2mat(P{1,k});
    parfor i=1:size(Vf,3)
        temp(:,:,i)=imwarp(temp(:,:,i),Shifts(:,:,:,i),'FillValues',nan);
    end
    temp=remove_borders(temp);
    P{1,k}={temp};
end

pre=estimate_min_correlation(X,1,0);
post=estimate_min_correlation(cell2mat(P{1,5}),1,0);
Scor=[pre,post];
end


