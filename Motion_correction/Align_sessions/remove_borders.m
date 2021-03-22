function out=remove_borders(in)
binaryImage=sum(in==0,3)>0;
[s1,s2]=size(binaryImage);
X=ones(s1+2,s2+2);
X(2:s1+1,2:s2+1)=binaryImage;
binaryImage=logical(X);
D = bwdist(binaryImage);
% imshow(D, []);
% Find the max of the EDT:
[r, c] = find(binaryImage == 0);
temp = [mean(r), mean(c)];
rowCenter=round(temp(1));
colCenter=round(temp(2));
% hold on;
% plot(colCenter, rowCenter, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
%%

% Get the boundary of the blob.
boundaries = bwboundaries(~binaryImage);
b = boundaries{1}; % Extract from cell.
x = b(:, 2);
y = b(:, 1);
% Get distances from center to each of the edge pixels.
distances = sqrt((x - colCenter).^2 + (y - rowCenter).^2);
% Find the min distance.
[~, indexOfMin] = min(distances);
% Find x and y of the min
xMin = x(indexOfMin);
yMin = y(indexOfMin);
% plot(xMin, yMin, 'co', 'MarkerSize', 10, 'LineWidth', 2);
% Get the delta x and delta y from center to corner
dx = abs(colCenter - xMin);
dy = abs(rowCenter - yMin);

if (dx==0)
    st=0;
    t=0;
    while (st==0)
    t=t+1;
    temp=binaryImage(rowCenter-dy+1:rowCenter+dy-1,colCenter-t:colCenter+t);
    st=sum(temp(:));
    end
    dx=t-1;
end

if (dy==0)
    st=0;
    t=0;
    while (st==0)
    t=t+1;
    temp=binaryImage(rowCenter-t:rowCenter+t,colCenter-dx+1:colCenter+dx-1);
    st=sum(temp(:));
    end
    dy=t-1;
end
out=in(rowCenter-dy:rowCenter+dy-2,colCenter-dx:colCenter+dx-2,:);
end