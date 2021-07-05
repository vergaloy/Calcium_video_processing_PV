function out=vesselness_PV2(in);

out=zeros(size(in,1),size(in,2),size(in,3));
ppm = ParforProgressbar(size(in,3),'showWorkerProgress', true);
parfor i=1:size(in,3)
    temp=double(in(:,:,i));
    temp=apply_vesselness_filter(temp);
    out(:,:,i)=temp;
    ppm.increment();
end
delete(ppm);
end

function out=apply_vesselness_filter(in);
Ip = single(in);
% thr = prctile(Ip(Ip(:)>0),1) * 0.9;
% Ip(Ip<=thr) = thr;
Ip = Ip - min(Ip(:));
Ip = Ip ./ max(Ip(:));    

% compute enhancement for two different tau values
out = vesselness2D(Ip, 0.01:0.01:0.5, [1;1], 1, false);
end