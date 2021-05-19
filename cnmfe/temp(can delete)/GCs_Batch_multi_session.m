function GCs_Batch_multi_session(parin)

for i=1:size(parin,1)
    try
    temp=parin{i,1:5};
    multi_session_CNMFe(temp{:});
    catch
        m=parin{i,1};
        m=m{1,1};
        [~,m,~] = fileparts(m);
        fprintf(['fail to process ',m,'\n'])
    end
    clearvars -except parin i
end