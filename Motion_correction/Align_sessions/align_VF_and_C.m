function [vf2,c2,D]=align_VF_and_C(vf1,c1,vf2,c2,opt)
%% Parameters
if ~exist('opt','var')
opt = struct('niter',5, 'sigma_fluid',1,...
    'sigma_diffusion',10, 'sigma_i',0.1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);
end
nlevel=3;

%% Multiresolution
it=0;
for k=nlevel:-1:1
    it=it+1;
    % downsample
    scale = 2^-(k-1);
    if k>1
       F=vf1;
       M=vf2;
    else
       F=c1;
       M=c2;
        
    end
    Fl = imresize(F,scale);
    Ml = imresize(M,scale);
    
    % register
    [~,~,~,vxl,vyl] = register_in(Fl,Ml,opt);
    % upsample
    vx = imresize(vxl/scale,size(M));
    vy = imresize(vyl/scale,size(M));
    [sx(:,:,:,it),sy(:,:,:,it)] = expfield(vx,vy);
    vf2     = uint8(iminterpolate(double(vf2),sx(:,:,:,it),sy(:,:,:,it)));
    c2     = uint8(iminterpolate(double(c2),sx(:,:,:,it),sy(:,:,:,it)));
end
sx=sum(sx,4);
sy=sum(sy,4);


D=cat(4,sy,sx);

end

function [vx,vy] = expfield(vx, vy)
    % Find n, scaling parameter
    normv2 = vx.^2 + vy.^2;
    m = sqrt(double(max(normv2(:))));
    n = ceil(log2(m/0.5)); % n big enough so max(v * 2^-n) < 0.5 pixel)
    n = max(n,0);          % avoid null values
    
    % Scale it (so it's close to 0)
    vx = vx * 2^-n;
    vy = vy * 2^-n;
    % square it n times
    for i=1:n
        [vx,vy] = compose(vx,vy, vx,vy);
    end
end

function [vx,vy] = compose(ax,ay,bx,by)
    [x,y] = ndgrid(0:(size(ax,1)-1), 0:(size(ax,2)-1)); % coordinate image
    x_prime = x + ax; % updated x values
    y_prime = y + ay; % updated y values
    
    % Interpolate vector field b at position brought by vector field a
    bxp = interpn(x,y,bx,x_prime,y_prime,'linear',0); % interpolated bx values at x+a(x)
    byp = interpn(x,y,by,x_prime,y_prime,'linear',0); % interpolated bx values at x+a(x)
    % Compose
    vx = ax + bxp;
    vy = ay + byp;
    
end

function I = iminterpolate(I,sx,sy)
    % Find update points on moving image
    [x,y] = ndgrid(0:(size(I,1)-1), 0:(size(I,2)-1)); % coordinate image
    x_prime = x + sx; % updated x values (1st dim, rows)
    y_prime = y + sy; % updated y values (2nd dim, cols)
    
    % Interpolate updated image
    I = interpn(x,y,I,x_prime,y_prime,'linear',0); % moving image intensities at updated points
    
end