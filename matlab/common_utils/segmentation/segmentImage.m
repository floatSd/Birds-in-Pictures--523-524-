% Segments an entire image
% Author: Nikhil Patwardhan
function [smallRegionIDs, nSmallRegions, regionMap] = ...
    segmentImage(dI,flags,rgThreshold,regionMap,smallRegionIDs,smallRegionSize)
disp('Segmenting the image...');

i = 1;                                  % Counts all regionMap
nSmallRegions = 0;                      % Counts small regionMap

[x,y] = nextSeed(flags,1);              % Get next seed for starting a region
                          
% Completely segment the image until nextSeed returns -1
while (x ~= -1 && y ~= -1)
    J = regiongrowing(dI,flags,x,y,rgThreshold);        % Get one region starting at (x,y)

    if (sum(sum(J)) < smallRegionSize)              % Small region
        smallRegionIDs(nSmallRegions+1,1) = i;      % OPTIMIZATION REQD: Grows dynamically after quota is consumed
        nSmallRegions = nSmallRegions+1;            % Increment the small region counter
    end;

    regionMap = regionMap + uint16(J).*i;   % Add the region mask (J) to the 'regionMap' matrix.
    i = i+1;

    flags = flags + J;                  % Update flags so that the same region is not segmented again
    [x,y] = nextSeed(flags,x);          % Get next seed for region
                                        % OPTIMIZED : Considers previous
                                        % seed location before beginning a new
                                        % search
end;
nRegions = i-1;
disp(sprintf('Found %d regionMap in total.',nRegions));


function J = regiongrowing(I,map,x,y,reg_maxdist)
% This function performs "region growing" in an image from a specified
% seedpoint (x,y)
%
% Returns ONE region
%
% J = regiongrowing(I,x,y,t) 
% 
% I : input image 
% J : logical output image of region
% x,y : the position of the seedpoint (if not given uses function getpts)
% t : maximum intensity distance (defaults to 0.2)
%
% The region is iteratively grown by comparing all unallocated neighbouring pixels to the region. 
% The difference between a pixel's intensity value and the region's mean, 
% is used as a measure of similarity. The pixel with the smallest difference 
% measured this way is allocated to the respective region. 
% This process stops when the intensity difference between region mean and
% new pixel become larger than a certain treshold (t)
%
% Example:
%
% I = im2double(imread('medtest.png'));
% x=198; y=359;
% J = regiongrowing(I,x,y,0.2); 
% figure, imshow(I+J);
%
% Author: D. Kroon, University of Twente
% Modified by Nikhil Patwardhan, Stony Brook University

% neg_list has the following structure:
% [x y R G B]
% reg_mean has the following structure:
% [R G B]

[r,c,z] = size(I);
J = zeros(r,c);                                                     % Output 

% DOUBLE 3 Dimension vector for 3 channels: R,G,B
reg_mean = [double(I(x,y,1)) double(I(x,y,2)) double(I(x,y,3))];    % The mean of the segmented region
reg_size = 1;                                                       % Number of pixels in the region

% Free memory to store neighbours of the (segmented) region
neg_free = 4000;
neg_pos=0;
neg_list = double(zeros(neg_free,5));

pixdist=double(0);                                                  % Distance of the region's newest pixel to the region mean
neigb=[-1 0; 1 0; 0 -1;0 1];                                        % Neighbor locations (footprint)

% Start regiogrowing until distance between region and possible new pixels become
% higher than a certain treshold
while (pixdist<reg_maxdist&&reg_size<numel(I(:,:,1)))

    % Add new neighbors pixels
    for j=1:4,
        % Calculate the neighbour coordinate
        xn = x +neigb(j,1);
        yn = y +neigb(j,2);
        
        % Check if neighbour is inside or outside the image
        ins=(xn>=1)&&(yn>=1)&&(xn<=r)&&(yn<=c);
        
        % Add neighbor if inside and not already part of the segmented area
        if (ins&&(J(xn,yn)==0) && map(xn,yn)==0)
            neg_pos = neg_pos+1;
            neg_list(neg_pos,:) = [xn yn double(I(xn,yn,1)) double(I(xn,yn,2)) double(I(xn,yn,3))];
            % disp(sprintf('Added %d %d',xn,yn));
            J(xn,yn)=1;
        end
    end

    % Add a new block of free memory
    if (neg_pos+10>neg_free)
        disp(sprintf('Allocating more memory'));
        neg_free=neg_free+3000;
        neg_list((neg_pos+1):neg_free,:)=0;
    end
    
    % Add the pixel that is closest to the region's current mean value
    index = 1;
    pixdist = sqrt((neg_list(index,3)-reg_mean(1))^2 + (neg_list(index,4)-reg_mean(2))^2 + (neg_list(index,5)-reg_mean(3))^2);
    
    for t=2:neg_pos
        temp = sqrt((neg_list(t,3)-reg_mean(1))^2 + (neg_list(t,4)-reg_mean(2))^2 + (neg_list(t,5)-reg_mean(3))^2);
        if (temp < pixdist)
            pixdist = temp;
            index = t;
        end;
    end;
    
    J(x,y)=2;
    reg_size=reg_size+1;
    map(x,y)=1;
    
    % Calculate the new mean of the region
    reg_mean(1) = (reg_mean(1)*reg_size + neg_list(index,3))/(reg_size+1);
    reg_mean(2) = (reg_mean(2)*reg_size + neg_list(index,4))/(reg_size+1);
    reg_mean(3) = (reg_mean(3)*reg_size + neg_list(index,5))/(reg_size+1);
    
    % Save the x and y coordinates of the pixel (for the neighbour add proccess)
    x = neg_list(index,1); y = neg_list(index,2);
    
    % Remove the pixel from the neighbour (check) list
    if (neg_pos ~= 0)
        neg_list(index,:)=neg_list(neg_pos,:);
        neg_pos=neg_pos-1;
    else
        pixdist = 100;
    end;
end

clear('neg_list');
% Return the segmented area as logical matrix
J=J>1;


function [x,y]=nextSeed(flags, seedEstimateRow)
% Check for erroneous input
if seedEstimateRow < 1
    seedEstimateRow = 1;
end;

% flags is a 2D matrix with 1s and 0s
% function returns the next 0 in this matrix
[m,n] = size(flags);
x = -1;
y = -1;
for i=seedEstimateRow:m
    for j=1:n
        if (flags(i,j)==0)
            x = i;
            y = j;
            return;
        end;
    end;
end;