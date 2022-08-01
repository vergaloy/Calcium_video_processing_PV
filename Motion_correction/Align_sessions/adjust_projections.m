function p=adjust_projections(p)
C=p.(3){1,1};  
Vf=p.(2){1,1};


for i=1:size(Vf,3)
C(:,:,i)=adjust_C(C(:,:,i));
% J(:,:,i) = mat2gray(imhistmatch(Vf(:,:,i),C(:,:,i),'Method','polynomial'));
J(:,:,i)=Vf(:,:,i);
x(:,:,i)=mat2gray(max(cat(3,J(:,:,i),medfilt2(C(:,:,i))),[],3));
end

% p.(2){1,1}=J;
p.(5){1,1}=x;

end



function Cn=adjust_C(Cn)

N=round(numel(Cn)/size(Cn,3)/100);
[Y,X]=histcounts(Cn(:),N);
X=X(1:end-1);
Y=Y./sum(Y);
Y=movmedian(Y,60);

[~,I]=max(Y(1:round(N/2)));
 Cn=Cn-X(I);
 Cn=Cn.^2;
end





