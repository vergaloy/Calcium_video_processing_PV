function M=get_motion(temp)
% M=get_motion(Yf);

temp=filter_image(temp,0);
% m=mean(temp,3);
% temp(temp<prctile(m(:),30))=prctile(m(:),30);

M(1:size(temp,3))=1; 
img1=mean(temp,3);
upd = textprogressbar(size(temp,3),'updatestep',500);
for i=1:size(temp,3)
%     img1=temp(:,:,i-df);
    img2=temp(:,:,i);
    M(i)=corr(img1(:),img2(:));
    upd(i)
end
M=1-M;
M=M-medfilt1(M,100);

end


function out=filter_image(in,k)
[y,x,~]=size(in);
in=in(round(y*k)+1:round(y*(1-k)),round(x*k)+1:round(x*(1-k)),:);

h1 = fspecial('disk',12);
h2 = fspecial('disk',4);

out=zeros(size(in,1),size(in,2),size(in,3));
ppm = ParforProgressbar(size(in,3),'showWorkerProgress', true);
parfor i=1:size(in,3)
    temp=double(in(:,:,i));
    temp=temp-imfilter(temp,h1,'replicate');
    temp=imfilter(temp,h2,'replicate');
    m=nanmean(temp,'all');
    temp=((temp-m)*-1)+m;
   temp=mat2gray(temp);
   temp(temp<0.5)=0.5;
    out(:,:,i)=mat2gray(temp);
    ppm.increment();
end
delete(ppm);
end



