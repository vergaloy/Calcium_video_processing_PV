function intialization_PV(Y,options)
% intialization_PV(v,options);
Y=double(Y);
HY=filter_data(Y,options);

end


function HY=filter_data(Y,options);
%% NEED TO BE MODIFIED
frame_range=[3000;6000];
%%
gSig=options.gSig  ;
if gSig>0
    if options.center_psf
        psf = fspecial('gaussian', ceil(gSig*4+1), gSig);
        ind_nonzero = (psf(:)>=max(psf(:,1)));
        psf = psf-mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
    else
        psf = fspecial('gaussian', round(gSiz), gSig);
    end
else
    psf = [];
end

% filter the data
if isempty(psf)
    % no filtering
    HY = Y;
else
    HY = imfilter(reshape(Y, options.d1,options.d2,[]), psf, 'replicate');
end

HY = reshape(HY, options.d1*options.d2, []);
HY = bsxfun(@minus, HY, median(HY, 2));
t=0;
for i=1:size(frame_range,1)
    HY(:,t+1:frame_range(i))=HY(:,t+1:frame_range(i))-median(HY(:,t+1:frame_range(i)),2);
    t=frame_range(i);
end   

end