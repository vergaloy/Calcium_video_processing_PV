function r=get_PSTH(obj)
% r=get_PSTH(neuron.S);
for i=1:size(obj,1) 
    r(i,:)=mean(divide_activity_in_trial(obj(i,1:6000),1200,5),1);   
end

% [~,I]=sort(mean(r(:,1:600),2)-mean(r(:,601:1200),2),'descend');
% imagesc(r(I,:))