function out=vesselness_PV(in);

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
in= medfilt2(in,[6,6]);
Ip = single(in);
thr = prctile(Ip(Ip(:)>0),1) * 0.9;
Ip(Ip<=thr) = thr;
Ip = Ip - min(Ip(:));
Ip = Ip ./ max(Ip(:));    

% compute enhancement for two different tau values
out = vesselness2D(Ip, 0.5:0.5:2.5, [1;1], 1, false);
end