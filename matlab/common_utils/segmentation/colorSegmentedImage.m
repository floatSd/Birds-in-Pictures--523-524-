% Colors the regionMap using R, G, B tints
% Author: Nikhil Patwardhan

function [colorSegmentsImage] = ...
    colorSegmentedImage(regionMap, nRegions, height, width)

CHAR_HEIGHT = 12;
CHAR_WIDTH = 8;

colorSegmentsImage = zeros(height,width,3,'uint8'); % Initialize an empty image

tints1 = rand(nRegions,1);          % Get a uniform distribution of random numbers
tints = 0.10 + tints1.*0.90;        % Ensure that all tints fall in the range: 0.10 to 1.00

cc = 1;                             % Loop through colors

regids = unique(regionMap);         % Region IDs

for i=1:nRegions
    [v1,v2] = find(regionMap == regids(i));
    
    % Loop through R, G, B channels and assign a tint
    vc = mod(cc,3)+1;
    for p=1:numel(v1)
        colorSegmentsImage(v1(p),v2(p),vc) = 255 * tints(i,1);
    end;
    cc = cc + 1;
    
    str = int2str(regids(i));       % Text to be printed
    len = length(str);              % Number of characters to be printed
    textPatchWidth = len * CHAR_WIDTH;
    
    % End row and col for text patch, measured from leftmost pixel in
    % region
    endRowTextPatch = min(v1(1) + CHAR_HEIGHT, height);
    endColTextPatch = min(v2(1) + textPatchWidth, width);
    
    % Ensure that the region is big enough to accomodate text
    isBigEnough = (numel(find(regionMap == regids(i))) > CHAR_HEIGHT * textPatchWidth);
    
    % Ensure that text will not overflow the image
    isHighEnough = (endRowTextPatch - v1(1) + 1 > CHAR_HEIGHT);
    isWideEnough = (endColTextPatch - v2(1) + 1 > textPatchWidth);
    
    if (isBigEnough && isHighEnough && isWideEnough)
        % Extract patch of region on which to write (near top-left corner)
        textPatch = colorSegmentsImage(v1(1):endRowTextPatch,v2(1):endColTextPatch,:);
        % Text color = white
        textPatch=rendertext(textPatch,str,[255 255 255],[1, 1],'bnd','left');
        % Assign color
        colorSegmentsImage(v1(1):endRowTextPatch,v2(1):endColTextPatch,:) = textPatch;
    end;
end;