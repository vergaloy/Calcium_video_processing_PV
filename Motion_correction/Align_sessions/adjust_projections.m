function p=adjust_projections(p)
C=p.(3){1,1};  
Vf=p.(2){1,1};


for i=1:size(Vf,3)
J(:,:,i) = mat2gray(imhistmatch(Vf(:,:,i),C(:,:,i),'Method','polynomial'));
x(:,:,i)=mat2gray(max(cat(3,J(:,:,i)*0.7,medfilt2(C(:,:,i))),[],3));
end

p.(2){1,1}=mat2gray(J);
p.(5){1,1}=x;




