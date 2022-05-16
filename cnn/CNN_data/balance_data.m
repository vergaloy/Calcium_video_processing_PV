function [XTrain,YTrain]=balance_data(XTrain,YTrain)

unos=sum(YTrain=='true');
ceros=sum(YTrain=='false');

dif=abs(unos-ceros);
if dif>0
    if unos-ceros>0       
       XTrain=cat(4,XTrain,datasample(XTrain(:,:,:,YTrain=='false'),dif,4));
       YTrain=[YTrain;categorical(false(dif,1))];
    else
        XTrain=cat(4,XTrain,datasample(XTrain(:,:,:,YTrain=='true'),dif,4));
        YTrain=[YTrain;categorical(true(dif,1))];
    end
end