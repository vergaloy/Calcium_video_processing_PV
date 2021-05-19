N=size(neuron.C_raw,1);
M=size(neuron.Cn,1);
K=size(neuron.Cn,2);
session=zeros([M,K,N]);

for i=1:N
 t=reshape(neuron.A(:, i),M,K);   
 t=full(t);
 session(:,:,i)=t;
end
session = permute(session,[3 1 2]);
newStr = reverse(neuron.file);
newStr = string(extractBetween(newStr,".","\"));
newStr = reverse(newStr);
path=pwd+"\session_"+newStr+"_"+date+".mat";
save(path,"session")
