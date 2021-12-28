function [out]=detrend_PV(nums,obj)
obj=double(obj);
parfor i=1:size(obj,1)
    temp=medfilt1(obj(i,:),nums*10,'truncate');
    bl=imerode(temp', ones(nums*50, 1))';
%     plot(neuron.C_raw(i,:));hold on;plot(temp);plot(bl);
    out(i,:)=obj(i,:)-bl;  
end

    