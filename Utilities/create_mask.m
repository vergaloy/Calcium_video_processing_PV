function out=create_mask()
[file,path] = uigetfile('*.mat');
m=load(strcat(path,file));
[filepath,name]=fileparts(strcat(path,file));
out=strcat(filepath,'\',name);

out=strcat(out(1:end-5),'mask','.mat');
Mask_video_app(m,out);
end