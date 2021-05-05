function ng=crispness(obj,bnd);
if ~exist('bnd','var'); bnd = 0; end
if isscalar(bnd); bnd = bnd*ones(6,1); end
M=mean(obj,3);
mean_Y = M(bnd(1)+1:end-bnd(2),bnd(3)+1:end-bnd(4));
[gx,gy] = gradient(mean_Y);
ng = norm(sqrt(gx.^2+gy.^2),'fro');
end