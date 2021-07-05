function M=get_motion(in)
% M=get_motion(v);

%  Vf=vesselness_PV(in);
Vf=in;

[d1,d2,~] = size(Vf);bound1=d1/5;bound2=d2/5;

%% Calculate Regid motion

Vf=Vf(bound1/2+1:end-bound1/2,bound2/2+1:end-bound2/2,:);


med= movmedian(Vf,300,3,'omitnan'); 

M(1:size(Vf,3))=1; 
upd = textprogressbar(size(Vf,3),'updatestep',500);
for i=1:size(Vf,3)
     img1=med(:,:,i);
    img2=Vf(:,:,i);
    M(i)=get_cosine(img1(:),img2(:));
    upd(i)
end


end





