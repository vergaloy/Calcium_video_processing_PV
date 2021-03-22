function Decompress_inscopix()
ds_f=4;% downsampling factor;


theFiles = uipickfiles('FilterSpec','*.isxd');

for k=1:length(theFiles)  
    clearvars -except filePattern theFiles k myFolder ds_f
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    ISXD2h5(fullFileName,ds_f)
end