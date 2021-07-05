function out=blobness_PV(in,gSig)

out=zeros(size(in,1),size(in,2),size(in,3));
ppm = ParforProgressbar(size(in,3),'showWorkerProgress', true);
parfor i=1:size(in,3)
    temp=double(in(:,:,i));
    temp=apply_blobness_filter(temp,gSig);
    out(:,:,i)=temp;
    ppm.increment();
end
delete(ppm);
end

function out=apply_blobness_filter(in,gSig)
in= medfilt2(in);
Ip = single(in);
thr = prctile(Ip(Ip(:)>0),1) * 0.9;
Ip(Ip<=thr) = thr;
Ip = Ip - min(Ip(:));
Ip = Ip ./ max(Ip(:));    

% compute enhancement for two different tau values
out = blobness2D(Ip, (gSig-0.5:0.5:gSig+0.5), [1;1], 1, true);
end