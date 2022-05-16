function p=adjust_projections(p)
C=p.(3){1,1};  
Vf=p.(2){1,1};

Cn=max(C,[],3);

for i=1:size(Vf,3)
J(:,:,i) = imhistmatch(Vf(:,:,i),Cn,'Method','polynomial');
x(:,:,i)=mat2gray(max(cat(3,J(:,:,i)*0.7,medfilt2(C(:,:,i),[5 5])),[],3));
end

p.(2){1,1}=mat2gray(J);
p.(5){1,1}=x;




