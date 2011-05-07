function [box] = getRegionWithBlackBackground(regionMap, I, regid, h, w, startRow, startCol)
box = uint8(zeros(h,w,3));              % Create an empty image
[xx yy] = find(regionMap == regid);     % Get the locations of the region

% Get a box with the region against a black background
regSize = numel(find(regionMap == regid));
for i=1:regSize
    r = xx(i);                      % X-co-ordinate of region pixel
    c = yy(i);                      % Y-co-ordinate of region pixel
    
    box(r-startRow+1, c-startCol+1,1) = I(r,c,1);
    box(r-startRow+1, c-startCol+1,2) = I(r,c,2);
    box(r-startRow+1, c-startCol+1,3) = I(r,c,3);
end;