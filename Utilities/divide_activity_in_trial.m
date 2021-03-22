function r=divide_activity_in_trial(S,trial_len,Ntrail,plotme)
% r=divide_activity_in_trial(neuron.C_raw(50,1:7200),120,60,1);

if ~exist('plotme','var')
    plotme=0;
end


r=reshape(full(S),[trial_len,Ntrail])';

if plotme==1
    figure
    h=imagesc(r);
    set(h, 'XData', linspace(-10,10,trial_len));xline(0,'r','LineWidth',1);xlim([-10 10]);
    xlabel('Time (s)');
    ylabel('Trail #')
end


% x=linspace(0,Ntrail*2*pi,size(S,2));
% y = sin(x);
% y(y>0)=0;
% y(y<0)=-1;
% y=y*-1;
% B=S(1,y==0);
