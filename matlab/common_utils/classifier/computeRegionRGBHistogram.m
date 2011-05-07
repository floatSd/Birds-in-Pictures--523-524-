% This function computes the RGB counts for a region, then divides each
% count by the size of the region to normalize the calculation.
function [hist] = computeRegionRGBHistogram(I, regionMap, regid, nBins)

[w h startRow startCol] = findRegionBoundingBox(regionMap, regid);

[box] = getRegionWithBlackBackground(regionMap, I, regid, h, w, startRow, startCol);

regSize = numel(find(regionMap == regid));
rHist = double(imhist(box(:,:,1), nBins)) / double(regSize);
gHist = double(imhist(box(:,:,2), nBins)) / double(regSize);
bHist = double(imhist(box(:,:,3), nBins)) / double(regSize);

hist = [rHist;gHist;bHist];