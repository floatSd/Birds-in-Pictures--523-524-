function [hist] = computeRegionRGBHistogram(I, regionMap, regid, nBins)
%% This function computes a normalized RGB histogram for a region

[w h startRow startCol] = findRegionBoundingBox(regionMap, regid);

[box] = getRegionWithBlackBackground(regionMap, I, regid, h, w, startRow, startCol);

rHist = double(imhist(box(:,:,1), nBins));
gHist = double(imhist(box(:,:,2), nBins));
bHist = double(imhist(box(:,:,3), nBins));

hist = [rHist;gHist;bHist];

% Normalize so that the sum of all elements becomes 1
hist = hist/norm(hist,1);