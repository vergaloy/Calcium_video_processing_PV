function Decompress_inscopix(outpath,ds_f)

if ~exist('outpath','var')
outpath = [];
end

if ~exist('ds_f','var')
ds_f = 4;
end

theFiles = uipickfiles('FilterSpec','*.isxd');

for k=1:length(theFiles)  
    clearvars -except filePattern theFiles k myFolder ds_f
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    ISXD2h5(fullFileName,ds_f,outpath)
end