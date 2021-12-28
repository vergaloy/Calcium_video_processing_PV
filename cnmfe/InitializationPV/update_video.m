function [Y,HY]=update_video(Y,HY,Y_box,HY_box,ind_nhood)

for i=1:size(Y_box,2)
    Y(ind_nhood{i},:)=Y_box{i};
    HY(ind_nhood{i},:)=HY_box{i};
end