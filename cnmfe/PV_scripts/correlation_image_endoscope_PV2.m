function [Cn, PNR] = correlation_image_endoscope_PV2(Y,gSig)
%% compute correlation image of endoscopic data. it has to spatially filter the data first
%% Input:
%   Y:  d X T matrx, imaging data
%   options: struct data of paramters/options
%       d1:     number of rows
%       d2:     number of columns
%       gSiz:   maximum size of a neuron
%       nb:     number of background
%       min_corr: minimum threshold of correlation for segementing neurons
%  K:  scalar, the rank of the random matrix for projection

%% Output:
%       Cn:  d1*d2, correlation image
%       PNR: d1*d2, peak to noise ratio
%% Author: Pengcheng Zhou, Carnegie Mellon University. zhoupc1988@gmail.com

%% use correlation to initialize NMF
%% parameters
d1 = size(Y,1);        % image height
d2 = size(Y,2);        % image width

sig = 3;    % thresholding noise by sig*std()

if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end;  % convert the 3D movie to a matrix
Y(isnan(Y)) = 0;    % remove nan values
% Y = detrend_data(Y, 2, 'spline'); Dont detrend!!

%% preprocessing data
% create a spatial filter for removing background
if gSig>0
        psf = fspecial('gaussian', ceil(gSig*4+1), gSig);
        ind_nonzero = (psf(:)>=max(psf(:,1)));
        psf = psf-mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
else
    psf = [];
end

% filter the data
if ~isempty(psf)
    Y = imfilter(reshape(Y, d1,d2,[]), psf, 'replicate');
end

Y = reshape(Y, d1*d2, []);
% HY_med = median(HY, 2);
% HY_max = max(HY, [], 2)-HY_med;    % maximum projection
Y = bsxfun(@minus, Y, median(Y, 2));
Y_max = max(Y, [], 2);
Ysig = GetSn(Y);
PNR = reshape(double(Y_max)./Ysig, d1, d2);

Y(bsxfun(@lt, Y, Ysig*sig)) = 0;

% compute loal correlation
Cn = correlation_image(Y, 8, d1,d2);

