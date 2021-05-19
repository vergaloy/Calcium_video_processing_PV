function out=fix_Baseline(nums,neuron)
for i=1:size(neuron.C_raw,1)
    temp=medfilt1(neuron.C_raw(i,:),nums*10,'truncate');
    bl=imerode(temp', ones(nums*50, 1));
%     plot(neuron.C_raw(i,:));hold on;plot(temp);plot(bl);
    out(i,:)=neuron.C_raw(i,:)-bl';  
end
    