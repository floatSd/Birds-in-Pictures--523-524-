% This function finds the dimensions of a rectangle that would just fit the
% region in the image
function [w h top_left_row top_left_col] = findRegionBoundingBox(regionMap, regid)

[xx yy] = find(regionMap == regid);

top_left_row = min(xx);
top_left_col = min(yy);
bottom_right_row = max(xx);
bottom_right_col = max(yy);

w = bottom_right_col - top_left_col + 1;
h = bottom_right_row - top_left_row + 1;