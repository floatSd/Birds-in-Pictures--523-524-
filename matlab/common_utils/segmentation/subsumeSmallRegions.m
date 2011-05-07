% Subsumes small regionMap from the segmentation output
% Author: Nikhil Patwardhan

function [regionMap] = ...
    subsumeSmallRegions(regionMap, smallRegionIDs, ...
                        nSmallRegions, windowBorder, height, width)
disp(sprintf('Subsuming %d small regionMap...',nSmallRegions));

for i=1:nSmallRegions                 % For all small regionMap
    regid = smallRegionIDs(i,1);      % Get the region's identifier
    
    [window] = getWindow(regionMap, regid, windowBorder, height, width);
    
    % Get all other regids in the window
    otherRegions = double(window(find(window ~= regid)));
    
    if numel(otherRegions) ~= 0    
        % Find the most frequently occuring one
        freq = mode(otherRegions);
        
        % Make all pixels of regid belong to the most frequent one
        regionMap(find(regionMap == regid)) = freq;
    end;
end;