function [cn_all,cn,pnr]=get_PNR_coor_greedy_PV(Y,gSig,F)
if ~exist('F','var')
    F=size(Y,3);
end

Y=single(Y);
[d1,d2,~]=size(Y);

%% preprocessing data
% create a spatial filter for removing background
if gSig>0
        psf = fspecial('gaussian', ceil(gSig*4+1), gSig);
        ind_nonzero = (psf(:)>=max(psf(:,1)));
        psf = psf-mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
else
    psf = [];
end

% filter the data
if ~isempty(psf)
    Y = imfilter(reshape(Y, d1,d2,[]), psf, 'replicate');
end

%% Remove median

Y=reshape(Y,d1*d2,[]);

if size(F,1)>1
    t=0;
    for i=1:size(F,1)
        Y(:,t+1:t+F(i)) = Y(:,t+1:t+F(i))-median(Y(:,t+1:t+F(i)),2);
        t=F(i);
    end   
else
    Y = bsxfun(@minus, Y, median(Y, 2));
end
%% Caculate PNR
Y_max = max(Y, [], 2);
Ysig = GetSn(Y);
pnr = reshape(double(Y_max)./Ysig, d1, d2);
Y(bsxfun(@lt, Y, Ysig*3)) = 0;

%% Distribute data to calculate Cn in batch mode
max_bin=3000;
F=F';
le=[];
for i=1:length(F)
temp=F(i);
if temp>max_bin
    n=round(temp/max_bin)+1;
   temp=floor(diff(linspace(0,temp,n)));
   temp(end)=temp(end)+(F(i)-sum(temp));
end
le=cat(2,le,temp);
end
le=[0,cumsum(le)];

cn_all=zeros(d1,d2,size(le,2)-1,'single');


Y_A=cell(size(le,2)-1,1);
for i=1:size(le,2)-1
Y_A{i}=Y(:,le(i)+1:le(i+1));
end

clear Y;
%% Caclulate Cn
parfor i=1:size(Y_A,1)
    cn_all(:,:,i) = correlation_image(Y_A{i}, 8, d1,d2);
end

cn=max(cn_all,[],3);


