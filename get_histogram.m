function med=get_histogram()
% if ~exist('order','var')
%     order=1;
% end

theFiles = uipickfiles('FilterSpec','*.h5');

for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    out=strcat(filepath,'\',name,'_mc','.h5');
    if ~isfile(out)
        V=h5read(fullFileName,'/Object');
        med(:,:,k)=median(V,3);
    end
end

D=reshape(med,size(med,1)*size(med,2),[]);

figure;hold on;
for i=1:size(D,2)
     histogram(D(:,i))  
% [h,d]=histcounts(D(:,i));
% plot(d(2:end),h);
end
legend
