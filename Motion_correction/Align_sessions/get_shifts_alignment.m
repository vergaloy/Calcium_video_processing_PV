function [Shifts,P,Scor]=get_shifts_alignment(P)
Vf=v2uint8(cell2mat(P{1,2}));
X=v2uint8(cell2mat(P{1,5}));
[d1,d2,d3]=size(Vf);
Shifts=zeros(d1,d2,2,1);
% [D,ans] = imregdemons(Vf(:,:,i),Vf(:,:,i-1));
parfor i=1:d3
    M1=cat(3,X(:,:,i),X(:,:,i),Vf(:,:,i),Vf(:,:,i));
    elem=1:d3;
%     elem(i)=[];
    t_shifts(:,:,:,i)=get_shift_in(M1,Vf,X,elem);
end

for k=1:size(P,2)
    temp=cell2mat(P{1,k});
    parfor i=1:size(Vf,3)
        temp(:,:,i)=imwarp(temp(:,:,i),t_shifts(:,:,:,i),'FillValues',nan);
    end

    P{1,k}={temp};
end
Shifts=Shifts+t_shifts;


for k=1:size(P,2)
    P.(k){1,1}=remove_borders(P.(k){1,1});
end
%%%%%%%%%


pre=estimate_min_correlation(X,1,0);
post=estimate_min_correlation(cell2mat(P{1,5}),1,0);
Scor=[pre,post];
end

function out=get_shift_in(M1,Vf,X,elem)

opt = struct('niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);
[d1,d2,~]=size(Vf);

t_shifts=zeros(d1,d2,2,length(elem));
for k=1:length(elem)
    M2=cat(3,X(:,:,elem(k)),X(:,:,elem(k)),Vf(:,:,elem(k)),Vf(:,:,elem(k)));
    [t1,t2,t_shifts(:,:,:,k)]=MR_Log_demon(M1,M2,opt);
    [~,temp] = ssim(t1(:,:,1),t2(:,:,1),'Exponents',[0 0 1]);
    M=mat2gray(max(cat(3,t1(:,:,1),t2(:,:,1)),[],3));
    temp(temp<0)=0;
    W(:,:,k)=temp.*M;
end
for i=1:size(W,3)
    W(:,:,i) = imgaussian(W(:,:,i),opt.sigma_diffusion);  % smooth weights.
end 

W=W./sum(W,3);
for i=1:size(W,3)
    W(:,:,i) = regionfill(W(:,:,i),isnan(W(:,:,i)));
end 
W=reshape(W,[d1,d2,1,length(elem)]);
W=cat(3,W,W);
out=sum(-t_shifts.*W,4,'omitnan');

end

function I = imgaussian(I,sigma)
    if sigma==0; return; end; % no smoothing
    
    % Create Gaussian kernel
    radius = ceil(3*sigma);
    [x,y]  = ndgrid(-radius:radius,-radius:radius); % kernel coordinates
    h      = exp(-(x.^2 + y.^2)/(2*sigma^2));
    h      = h / sum(h(:));
    
    % Filter image
    I = imfilter(I,h);
end
