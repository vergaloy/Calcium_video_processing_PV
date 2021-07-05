function scale_to_noise(neuron)
%  We estimate the noise from the remnant between the raw and deconvolved calcium trace.
% we use a moving window of size=num
c=cumsum(neuron.frame_range);
c=[[0;c(1:end-1)]+1,c];

for i=1:size(c,1)
    temp=neuron.C_raw(:,c(i,1):c(i,2)); % 1) we susbtract the deconvolved signal from the raw calcium trace.
    temp=detrend(temp')';
    temp=temp./GetSn(temp);   
    neuron.C_raw(:,c(i,1):c(i,2))=temp;   % 3) we scale the raw signal. 
end 


