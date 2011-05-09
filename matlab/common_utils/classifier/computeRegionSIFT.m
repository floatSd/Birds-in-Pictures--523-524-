function siftDescriptors = computeRegionSIFT(I, regionMap, regid, gridUnit)
%{
Returns the SIFT descriptor(s) for an irregular region by imposing a grid
pattern over the region and computing the SIFT descriptor of each cell in
the grid that has a substantial portion belonging to that region.

If none of the grid units cover the region substantially, then a SIFT
descriptor is found for each of the grid units that can fit in that region.
%}

if (nargin < 4)
    gridUnit = 10;
end;
%% PART 1 : Initialize variables
siftDescriptors = {};            % Number of elements unknown

%% PART 2 : Get a bounding box for the region from the image
[w h startRow startCol] = findRegionBoundingBox(regionMap, regid);
regSize = numel(find(regionMap == regid));

if (regSize == 0)
    disp(sprintf('computeRegionSIFT: Serious error in computing SIFT descriptor for region %d',regid));
end;

% Extract the box containing the region
box = uint8(zeros(h,w,3));
box(1:h,1:w,1) = I(startRow:startRow+h-1,startCol:startCol+w-1,1);
box(1:h,1:w,2) = I(startRow:startRow+h-1,startCol:startCol+w-1,2);
box(1:h,1:w,3) = I(startRow:startRow+h-1,startCol:startCol+w-1,3);

origbox = rgb2gray(box);        % For debugging
graybox = single(origbox);

% disp(length(h));
% disp(length(w));
% disp(regSize);

if (h < gridUnit || w < gridUnit)
    [f siftDescriptors{1}] = vl_sift(graybox);       % Assumption: Its area is gridUnit * gridUnit
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
            
            % Is the number of pixels occupied by the region more than 90%?
            if (numel(find(gridCellRegionMap == regid)) > 0.90*gridUnit*gridUnit)
                
                % Get a SIFT descriptor for the cell
                gridCell = graybox(1+(i-1)*gridUnit:i*gridUnit,...
                        1+(j-1)*gridUnit:j*gridUnit);
                [f d] = vl_sift(gridCell);
                
                if ~isempty(d)
                    % Increment the counter
                    countCells = countCells + 1;
                    siftDescriptors{countCells} = d;
                end;
            end;
        end;
    end;
    
    % If all the above computation resulted in 0 descriptors, ignore the
    % 75% threshold and try again
    if (countCells == 0)
        countCells = 0;
        for i=1:hCells              % Rows
            for j=1:wCells          % Cols
                gridCell = graybox(1+(i-1)*gridUnit:i*gridUnit,...
                        1+(j-1)*gridUnit:j*gridUnit);
                [f d] = vl_sift(gridCell);

                if ~isempty(d)
                    countCells = countCells + 1;
                    siftDescriptors{countCells} = d;
                end;
            end;
        end;
    end;
end;

% disp(sprintf('Returning %d descriptors for region %d',length(siftDescriptors),regid));