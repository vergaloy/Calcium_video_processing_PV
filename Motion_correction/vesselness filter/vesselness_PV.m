function out=vesselness_PV(in,use_parallel,sz)

if ~exist('sz','var')
    sz=1.5:0.5:3;
end


if ~exist('use_parallel','var')
    use_parallel=1;
end

out=zeros(size(in,1),size(in,2),size(in,3));

if use_parallel
    ppm = ParforProgressbar(size(in,3),'showWorkerProgress', true);
    parfor i=1:size(in,3)
        temp=double(in(:,:,i));
        temp=apply_vesselness_filter(temp,sz);
        out(:,:,i)=temp;
        ppm.increment();
    end
    delete(ppm);
else
    for i=1:size(in,3)
        temp=double(in(:,:,i));
        temp=apply_vesselness_filter(temp,sz);
        out(:,:,i)=temp;
    end
end

end

function out=apply_vesselness_filter(in,sz)
in= medfilt2(in);
Ip=mat2gray(in);
% Ip = single(in);
% thr = prctile(Ip(Ip(:)>0),1) * 0.9;
% Ip(Ip<=thr) = thr;
% Ip = Ip - min(Ip(:));
% Ip = Ip ./ max(Ip(:));    
% 
% % compute enhancement for two different tau values
 out = vesselness2D(Ip, sz, [1;1], 1, false);
% out = vesselness2D(Ip, 0.05:0.05:1.5, [1;1], 1, false);
end