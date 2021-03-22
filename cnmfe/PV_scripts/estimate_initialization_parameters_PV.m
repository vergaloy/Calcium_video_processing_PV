function [Cn,PNR]=estimate_initialization_parameters_PV(tmp_range,g_size)
%[Cn,PNR]=estimate_initialization_parameters_PV([1 1000],0);

[file,path] = uigetfile('*.h5');
in=h5info(strcat(path,file));
si=in.Datasets.Dataspace.Size;
if isempty(tmp_range)
    tmp_range=[1,si(3)];
end
if isempty(tmp_range)
    g_size=0;
end



Y=h5read(strcat(path,file),'/Object',[1 1 tmp_range(1)],[si(1) si(2) tmp_range(2)-tmp_range(1)+1]);
% Y=h5read(strcat(path,file),'/Object');
cd(path)
if (g_size==0)
    r=6;
    parfor i=1:r
        [Cn(:,:,i), PNR(:,:,i)] = correlation_image_endoscope_PV2(Y,(2+i));
    end
    
    
    
    
    figure
    hold on
    set(gcf, 'Position',  [200, 100, 1500, 800])
    for i=1:r
        subplot(2,3,i);
        imagesc(PNR(:,:,i));
        title(strcat('gSig=',num2str(i+2)))
        caxis([2 prctile(PNR(:,:,i),99.9,'all')])
    end
    % export_fig(strcat(file,'.pdf'), '-append');
    
    
    
    figure
    hold on
    set(gcf, 'Position',  [200, 100, 1500, 800])
    for i=1:r
        subplot(2,3,i);
        imagesc(Cn(:,:,i));
        title(strcat('gSig=',num2str(i+2)))
    end
    % export_fig(strcat(file,'.pdf'), '-append');
    
    figure
    hold
    set(gcf, 'Position',  [200, 100, 1500, 800])
    for i=1:r
        subplot(2,3,i);
        imagesc(PNR(:,:,i).*Cn(:,:,i));
        title(strcat('gSig=',num2str(i+2)))
        caxis([2 prctile(PNR(:,:,i),99.9,'all')])
    end
    
    % export_fig(strcat(file,'.pdf'), '-append');
    
else
    [Cn,PNR] = correlation_image_endoscope_PV2(Y,g_size);
    subplot(1,3,1);
    imagesc(PNR);
    subplot(1,3,2);
    imagesc(Cn);
    subplot(1,3,3);
    imagesc(Cn.*PNR);
    
end