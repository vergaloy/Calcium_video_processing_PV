function convert_inscopix_to_nice_h5()
theFiles = uipickfiles('REFilter','\.hdf5$');

for k=1:length(theFiles)  
    fullFileName = theFiles{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    V=h5read(fullFileName,'/images'); %get Video
    V=permute(V,[2 1 3]);
    [p,f,~]=fileparts(fullFileName);
    saveash5(V,[p,'\',f,'.h5']);
    delete(fullFileName);
end