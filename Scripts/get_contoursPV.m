function [circularity,pnr,cn,Areaest,mask] = get_contoursPV(obj);
% [circularity,pnr,cn,Areaest] = get_contoursPV(neuron);


A=obj.A;
d1=size(obj.Cn,1);
d2=size(obj.Cn,2);
PNR=obj.PNR;
CN=obj.Cn;


num_neuron = size(A,2);
thr=0.6;
for m=1:num_neuron    
    A_temp = A(:,m);
    [temp,ind] = sort(A_temp(:).^2,'ascend');
    temp =  cumsum(temp);
    ff = find(temp > (1-thr)*temp(end),1,'first');
    thr_a = A_temp(ind(ff));
    A_temp=full(reshape(A_temp,[d1 d2]));
    mask(:,:,m) = bwlabel(medfilt2(A_temp>full(thr_a)));
    pnr(m,1)=mean(PNR(logical( mask(:,:,m)))); 
    cn(m,1)=mean(CN(logical( mask(:,:,m)))); 
    try
    [circularity(m,1),Areaest(m,1)]=get_circularity( mask(:,:,m));    
    catch
    circularity(m)=0;
    Areaest(m)=nan;
    end
     
end
end


function [circularity,Areaest]=get_circularity(mask)
Areaest = sum(mask(:));
perimpix = abs(conv2(mask,[1 -1],'same')) | abs(conv2(mask,[1;-1],'same'));
[Ip,Jp] = find(perimpix);
edgelist = convhull(Ip,Jp);
polyperim = sum(sqrt(diff(Ip(edgelist)).^2 + diff(Jp(edgelist)).^2));
circularity=4*pi*Areaest/polyperim^2;
end
