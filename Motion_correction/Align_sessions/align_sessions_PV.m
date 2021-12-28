function align_sessions_PV(sf,gSig,theFiles)
% align_sessions_PV(10);
if ~exist('gSig','var')
    gSig = 2.5;
end

if ~exist('theFiles','var')
    theFiles = uipickfiles('FilterSpec','*.h5');
end

[filepath,name]=fileparts(theFiles{end});
out=strcat(filepath,'\',name,'_Aligned','.h5');
if ~isfile(out)
    %% load all video files
    [Vid,P1,F]=load_data(theFiles,sf,gSig);
    %%
    fprintf(1, 'Aligning video by translation ...\n');
    [Vid,P2]=apply_translations(Vid,P1);
    %%
    fprintf(1, 'Calculating non-rigid aligments...\n');
    [shifts,P3,Scor]=get_shifts_alignment(P2);
    P=table(P1,P2,P3,'VariableNames',{'Original','Translations','Trans + Non-Rigid'});

    %% Apply Shifts
    Mr=apply_shifts_PV(Vid,shifts);   
    Mr=remove_borders(Mr);
    % Convert to original resolution
    if isa(Vid{1},'uint8')
        Mr=v2uint8(Mr);
    else
        Mr=v2uint16(Mr);
    end
    
    %% save Aligned video;
    fprintf(1, 'Saving Aligned Video...\n');
    saveash5(Mr,out);
    out_mat=strcat(filepath,'\',name,'_Aligned.mat');
    Cn=max(P3.Coor{1,1},[],3);
    PNR=max(P3.PNR{1,1},[],3);
    if ~isfile(out_mat)
        save(out_mat,'P','Scor','Cn','PNR','F');
    else
        save(out_mat,'P','Scor','Cn','PNR','F','-append');
    end    
    
else
    fprintf(1, 'Video file was already aligned...\n');
end
% [filepath,name]=fileparts(out);
% out_mat=strcat(filepath,'\',name,'.mat');
% % get_frame_list(theFiles,out_mat);
% % get_CnPNR_from_video(gSig,{out},F);

end
%%
%%=============================================
% Functions
%%=============================================
%%

function dt=det_video(in,sf)
[d1,d2,d3]=size(in);
dt = detrend_PV(sf,reshape(in,[d1*d2,d3]));
dt=dt./GetSn(dt);
dt=reshape(dt,d1,d2,d3);

end
%%
%%=============================================
function [Vid,P,F]=load_data(theFiles,sf,gSig)
upd = textprogressbar(size(theFiles,2),'startmsg','Loading files into memory');
for i=1:size(theFiles,2)
    fullFileName = theFiles{i};
    Vid{i}=h5read(fullFileName,'/Object');
    F(i)=size(Vid{i},3);
    [~,Mask(:,:,i)]=remove_borders(Vid{i},0);
    upd(i);
end

[~,Mask]=remove_borders(Mask,0);

f1=max(sum(Mask,1));
f2=max(sum(Mask,2));

upd = textprogressbar(size(Vid,2)*2,'startmsg','Calculating projections');
k=0;
for i=1:size(Vid,2)
    temp=Vid{i};
    temp=reshape(temp,size(temp,1)*size(temp,2),[]);
    temp(~Mask(:),:)=[];
    temp=reshape(temp,f1,f2,[]);
    M(:,:,i)=min(temp,[],3);
    Vf(:,:,i)=adapthisteq(vesselness_PV(M(:,:,i),0,0.5:0.05:1.5),'Distribution','exponential');
    temp=det_video(temp,sf);
    k=k+1;
    upd(k);
    [~,Cn(:,:,i),pnr(:,:,i)]=get_PNR_coor_greedy_PV(temp,gSig);
    Vid{i}=temp;
    k=k+1;
    upd(k);
end
Vf=mat2gray(Vf);
M=mat2gray(M);
X=mat2gray(max(cat(4,Vf,double(Cn)),[],4));
P={M,Vf,Cn,pnr,X};
P = array2table(P,'VariableNames',{'Mean','Vessel','Coor','PNR','Vess+Coor'});
end

function [Vid,P2]=apply_translations(Vid,P)

    [P2,T,Mask]=sessions_translate(P);
    Mask=1-Mask;
    Mask(Mask==1)=nan;
    for i=1:length(Vid)
          Vid{i}=remove_borders(imtranslate(Vid{i},T(i,:))+Mask);  
    end
    
end



