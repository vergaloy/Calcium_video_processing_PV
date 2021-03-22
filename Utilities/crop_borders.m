function out=crop_borders()
[file,path] = uigetfile('*.h5');
Y=h5read(strcat(path,file),'/Object');
[filepath,name]=fileparts(strcat(path,file));
in=strcat(filepath,'\',name,'_CnPNR','.mat');
m=load(in);
[filepath,name]=fileparts(strcat(path,file));
out=strcat(filepath,'\',name,'_crop','.h5');
Crop_video_app(m,Y,out,in);
end