function Cn=remove_noise_Cn(Cn)

S=Cn(:);
S(S<=0)=[];
N=round(numel(S)/size(Cn,3)/100);
[h,e]=histcounts(S(:),N);
X=e(1:end-1)';
Y=h'./sum(h);
coefficients=fit_two_Gaussians_PV(X,Y,0);
thr=coefficients(2)+sqrt(coefficients(3))*2;
Cn(Cn(:)<thr)=0;
%%