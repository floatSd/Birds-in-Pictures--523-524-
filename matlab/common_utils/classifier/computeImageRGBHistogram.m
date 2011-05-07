% This function computes the RGB counts for an RGB image, then divides each
% count by the size of the region to normalize the calculation.
function [hist] = computeImageRGBHistogram(I,nBins)

[h w z] = size(I);
imSize = h * w;

rHist = double(imhist(I(:,:,1), nBins)) / double(imSize);
gHist = double(imhist(I(:,:,2), nBins)) / double(imSize);
bHist = double(imhist(I(:,:,3), nBins)) / double(imSize);

hist = [rHist;gHist;bHist];