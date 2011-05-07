% Initialization and preprocessing routine
% Author: Nikhil Patwardhan

function [flags,regionMap,smallRegionIDs,dI,I,height,width] = ...
    initSegmenter(filename, maxImgWidth)

initSmallRegions = 6000;

I = imread(filename);
if (size(I,2) > maxImgWidth)
    % Resize width to maxImgWidth
    I = imresize(I, double(maxImgWidth/size(I,2)));
end;
dI = im2double(I);

% Calculate image dimensions
[height,width,z] = size(dI);

% Track which pixels have been allocated to regionMap
flags = zeros(height,width);

% All regionMap' pixel maps : uses a 'Labeled Image' approach...
% as described in the book by Linda Shapiro
regionMap = uint16(zeros(height,width));

% Identifies a list of "small" regionMap in this image
% Each region has a unique identifier (integer)
smallRegionIDs = uint16(zeros(initSmallRegions,1));

disp('Done preprocessing and initializing...');