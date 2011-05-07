function [siftDescriptor] = computeRegionSIFT(I, regionMap, regid)
%% Returns the SIFT descriptor(s) for an irregular region by imposing a grid
% pattern over the region and computing the SIFT descriptor of each cell in
% the grid that has a substantial portion belonging to that region.

% siftSizes specifies the area in sq. px. that corresponds to each cell in
% the siftDescriptor{} array

%% PART 1 : Initialize variables
gridUnit = 100;                  % Grid dimension in pixels
siftDescriptor = {};            % Number of elements unknown

%% PART 2 : Get a bounding box for the region from the image
[w h startRow startCol] = findRegionBoundingBox(regionMap, regid);
regSize = numel(find(regionMap == regid));

% Extract the box containing the region
box = uint8(zeros(h,w,3));
box(1:h,1:w,1) = I(startRow:startRow+h-1,startCol:startCol+w-1,1);
box(1:h,1:w,2) = I(startRow:startRow+h-1,startCol:startCol+w-1,2);
box(1:h,1:w,3) = I(startRow:startRow+h-1,startCol:startCol+w-1,3);

%% If the region is too small, find the SIFT descriptor of the whole box,
% Else, compute a SIFT descriptor for every grid cell that has a
% substantial portion belonging to the region.

graybox = single(rgb2gray(box));

% disp(length(h));
% disp(length(w));
% disp(regSize);

if (h < gridUnit || w < gridUnit)
    [f siftDescriptor{1}] = vl_sift(graybox);
else
    countCells = 0;
    hCells = uint16(floor(h/gridUnit));
    wCells = uint16(floor(w/gridUnit));
    for i=1:hCells              % Rows
        for j=1:wCells          % Cols
            % Get a region map for that cell
            gridCellStartRow = (i-1)*gridUnit + startRow;
            gridCellEndRow = gridCellStartRow + gridUnit - 1;
            gridCellStartCol = (j-1)*gridUnit + startCol;
            gridCellEndCol = gridCellStartCol + gridUnit - 1;
            gridCellRegionMap = ...
                regionMap(gridCellStartRow:gridCellEndRow,gridCellStartCol:gridCellEndCol);
            
            % Is the number of pixels occupied by the region more than 15%?
            if (numel(find(gridCellRegionMap == regid)) > 0.15*gridUnit*gridUnit)
                
                % Get a SIFT descriptor for the cell
                gridCell = graybox(1+(i-1)*gridUnit:i*gridUnit,...
                        1+(j-1)*gridUnit:j*gridUnit);
                [f d] = vl_sift(gridCell);
                
                if ~isempty(d)
                    % Increment the counter
                    countCells = countCells + 1;
                    siftDescriptor{countCells} = d;
                end;
            end;
        end;
    end;
    
    if (countCells == 0)
        [f siftDescriptor{1}] = vl_sift(graybox);
    end;
end;