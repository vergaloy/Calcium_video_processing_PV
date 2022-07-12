function [med,F,T]=get_histogram()
% if ~exist('order','var')
%     order=1;
% end

theFiles = uipickfiles('FilterSpec','*.h5');
for k=1:length(theFiles)
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    da=string(name(1:end-12));
    T(k)=datenum(datetime(da,'InputFormat','yyyy-MM-dd-HH-mm-ss'));
    out=strcat(filepath,'\',name,'_mc','.h5');
    if ~isfile(out)
        V=h5read(fullFileName,'/Object');
        [d1,d2,d3]=size(V);
        F(k)=d3;
        %         X=double(reshape(V,d1*d2,d3));
        %          I=min(X,[],2)<10;
        %          X(I,:)=[];
        %         M=mean(X(:,1:30),2);
        %         X=X-M;
        %          med{k}=prctile(X,10,1);
        med{k}=squeeze(mean(mean(V(d1/2-24:d1/2+25,d2/2-24:d2/2+25,:),1),2));
    end
end
T=T-T(1);
T=T*86400;