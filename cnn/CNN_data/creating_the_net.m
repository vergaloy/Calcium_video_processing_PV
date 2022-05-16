layers=net.Layers; %% first you need to load the model/ 
layers(21, 1).Classes=categorical([true,false]);


% ix=manually_classify_spatial_fun(neuron);



a=full(neuron.A);

d=[neuron.options.d1,neuron.options.d2];

YTrain=categorical(logical(ix));
XTrain = extract_patch(a,d,[50,50]);


idx = randperm(size(XTrain,4),round(size(XTrain,4)/4));
XValidation = XTrain(:,:,:,idx);
XTrain(:,:,:,idx) = [];
YValidation = YTrain(idx);
YTrain(idx) = [];


[XTrain,YTrain]=balance_data(XTrain,YTrain);
[XValidation,YValidation]=balance_data(XValidation,YValidation);


options = trainingOptions("sgdm", ...
    MaxEpochs=5, ...
    ValidationData={XValidation,YValidation}, ...
    Verbose=false, ...
    Plots="training-progress",...
    InitialLearnRate=0.000001,...
    ValidationFrequency=10,...
    MiniBatchSize=100);

net = trainNetwork(XTrain,YTrain,layers,options);

XTrain = extract_patch(a,d,[50,50]);
Y = predict(net,XTrain);
pred=Y(:,2)>0.5;
Vald=ix;
accuracy = sum(pred == Vald)/numel(Vald)
F1=sum(pred.*Vald)/( sum(pred.*Vald)+0.5*(sum(pred&~Vald)+sum(~pred&Vald) ) ) 



