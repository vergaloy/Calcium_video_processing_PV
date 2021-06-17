function out=create_mask()
[file,path] = uigetfile('*.mat');
m=load(strcat(path,file));
[filepath,name]=fileparts(strcat(path,file));
out=strcat(filepath,'\',name);
out=strcat(out,'.mat');
Mask_video_app(m,out);
end