function maxM=estimate_mean_motion_flow(O,gSig,bounds,plotme)

%  maxM=estimate_mean_motion_flow(O,4,1);
%  maxM=estimate_mean_motion_flow(O3,4,1);
B=gSig*5;

if (rem(B, 2) == 0)
    B=B+1;
end

hbm = vision.BlockMatcher('ReferenceFrameSource',...
    'Input port','BlockSize',[B B]);
hbm.OutputValue = 'Horizontal and vertical components in complex form';



[d1,d2,~] = size(O);

if (bounds==1)
bound1=d1/5;
bound2=d2/5;
else
 bound1=0; 
 bound2=0;
end


Ob=O(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:);


b=nchoosek(1:size(Ob,3),2);
M=zeros(size(Ob,3),size(Ob,3));

for i=1:size(b,1)
    motion= hbm(Ob(:,:,b(i,1)),Ob(:,:,b(i,2)));     
    M(b(i,1),b(i,2))=mean(sqrt((real(motion(:)).^2)+(imag(motion(:)).^2)));
end

maxM=max(M,[],'all');

if (plotme==1)
[~,I] = max(M(:));
[x,y]=ind2sub(size(M),I);
img1=Ob(:,:,x);
img2=Ob(:,:,y);
motion=hbm(img1,img2);
img12 = imfuse(img1,img2);
[X,Y] = meshgrid(1:B:size(img1,2),1:B:size(img1,1));
figure;imshow(img12)
hold on
quiver(X(:)+B,Y(:)+B,real(motion(:)),imag(motion(:)),0,'LineWidth',1.5)
hold off
end

