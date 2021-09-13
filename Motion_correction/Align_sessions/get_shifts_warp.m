function [shifts,Vf,Mr,MVf,Scor]=get_shifts_warp(X,dis,vessel,smo)
X=mat2gray(X);
if vessel
Vf=vesselness_PV(X,0,0.15:0.05:1.5);
Vf=vesselness_PV(1-Vf,0,0.15:0.05:0.8);
else
Vf=X;
end
if ~exist('smo','var') 
    app = get_smooth_factor(Vf);  % create the parameter window
    while app.done == 0  % polling
        pause(0.05);
    end
    smo = app.smt;  % get the values set in the parameter window
    delete(app);   
end

if ~exist('dis','var')
    dis=1;
end

% for i=1:size(X,3)
% Vf(:,:,i)=adapthisteq(Vf(:,:,i),'Distribution','exponential');
% end
%  
%  for i=2:size(X,3)
%    Vf(:,:,i) = imhistmatch(Vf(:,:,i),Vf(:,:,i-1),'method','polynomial');
%  end

shifts=registerImages_PV(Vf,smo);
shifts=shifts-mean(shifts,4);
Mr=X;
MVf=Vf;
for i=1:size(Vf,3)
    Mr(:,:,i)=imwarp(X(:,:,i),shifts(:,:,:,i),'FillValues',nan);
    MVf(:,:,i)=imwarp(Vf(:,:,i),shifts(:,:,:,i),'FillValues',nan);
end
Mr=remove_borders(Mr);
MVf=remove_borders( MVf);

Mr=mat2gray(Mr);

pre=estimate_min_correlation(Vf,1,0);
post=estimate_min_correlation(MVf,1,0);
Scor=[pre,post];
if dis==1
fprintf(1, 'Min correlation between sessions before Alignment: %1.3f\n',  pre);
fprintf(1, 'Min correlation between sessions after Alignment: %1.3f\n', post);
end
