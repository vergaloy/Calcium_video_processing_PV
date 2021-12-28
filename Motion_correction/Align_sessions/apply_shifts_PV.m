function out=apply_shifts_PV(Vid,shifts,show_bar)
if ~exist('show_bar','var')
    show_bar=1;
end

Six=[];
for i=1:size(Vid,2)
    Six=cat(2,Six,ones(1,size(Vid{i},3))*i);
end

out=cat(3,Vid{:});
if (show_bar)
    ppm = ParforProgressbar(size(out,3),'progressBarUpdatePeriod',1.5,'title', 'Applying shifts to video');
    parfor i=1:size(out,3)
        out(:,:,i)=imwarp(out(:,:,i),shifts(:,:,:,Six(i)),'FillValues',nan);
        ppm.increment();
    end
    delete(ppm);
else   
    parfor i=1:size(out,3)
        out(:,:,i)=imwarp(out(:,:,i),shifts(:,:,:,Six(i)),'FillValues',nan);
    end   
end

end
