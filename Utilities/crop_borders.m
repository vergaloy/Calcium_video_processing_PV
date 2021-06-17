function out=crop_borders()
[file,path] = uigetfile('*.h5');
[filepath,name]=fileparts(strcat(path,file));
in=strcat(filepath,'\',name,'.mat');
try
    m=load(in);
    [filepath,name]=fileparts(strcat(path,file));
    out=strcat(filepath,'\',name,'_crop','.h5');
    Y=h5read(strcat(path,file),'/Object');
    Crop_video_app(m,Y,out,in);
catch
    fprintf(1, 'PNR and Cn image does not exist...\n');
    fprintf(1, 'Run get_CnPNR_from_video(gSig) first.\n');
end
end