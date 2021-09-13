function out=apply_shifts_PV(Vid,shifts)
fprintf(1, 'Applying shifts to video...\n');
out=[];
for i=1:size(Vid,2)
    
    fprintf(1, 'Applying shifts to session #%1f out of %1f...\n', i,size(Vid,2));
    temp=Vid{i};
    t_shift=shifts(:,:,:,i);
    parfor s=1:size(temp,3)
        temp(:,:,s)=imwarp(temp(:,:,s),t_shift);
    end    
    out=cat(3,out,temp);
end

end
