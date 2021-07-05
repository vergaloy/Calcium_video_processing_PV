function out=median_filt_video(in);

out=zeros(size(in),'like',in);
parfor i=1:size(in,3)
   a=medfilt2(in(:,:,i)); 
    J = medfilt2(a,[40 40]);
    out(:,:,i)=a-J;   
end

