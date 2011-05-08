% Function to find the top 'n' regionMap w.r.t. region size
function [regids, allRegionSizes] = findTopNRegions(regionMap, numRegions, n)

allRegids = unique(regionMap);
allRegionSizes = zeros(numRegions,2);       % Store the size in square pixels of all regionMap

% Find the sizes of all regionMap
for i=1:numRegions
    allRegionSizes(i,1) = allRegids(i);
    allRegionSizes(i,2) = numel(find(regionMap == allRegids(i)));
end;

allRegionSizes = sortrows(allRegionSizes,2);

regids = zeros(n,1);
% Pick the last n entries
for i=numRegions:-1:numRegions-n+1
    regids(1+numRegions-i) = allRegionSizes(i,1);
end;