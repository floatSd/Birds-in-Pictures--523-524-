% Finding birds in images
% 
% Steps followed:
%   1. Initialize variables
%   2. Segment the image
%   3. Clean up the segments by subsuming smaller regionMap
%   4. Output a PNG image with colored segments and labels for some of the
%   region IDs
%   5. Attempt to recognize each one of the regionMap (using a trained
%   classifier - linear SVM)
%   6. Output the results with separate color coded regionMap overlayed over
%   the original image
% 
% Author: Nikhil Patwardhan

clear; clc;

% Define constants
rgThreshold = 0.10;                         % Threshold for region growing
maxImgWidth = 400;                          % Resize if more than this
smallRegionSizeSqPx = 65;                   % In square pixels
windowBorder = 5;                           % Around a region when subsuming
imageDirectory = '../../datafiles/tests/';     % Source Directory
nColorBins = 32;                            % Per channel for histogram
nSIFTClusters = 50;                         % Clusters from SIFT features
gridUnit = 40;
probThreshold = 0.2;

categoryNames = {'grass','buildings','mud','roads','snow','water',...
                 'sky','leaves','bark','sand','other','bird'};

chosenCategories=[1 2 4 5 6 7 12];             % You may not be interested in computing for all the categories
nCategories = length(chosenCategories);     % Number of Categories

% Add the necessary paths
addpath('../common_utils/');
addpath('../common_utils/classifier/');
addpath('../common_utils/region/');
addpath('../common_utils/segmentation/');
addpath('../common_utils/vlfeat-0.9.9/toolbox/mex/mexa64/');
addpath('../common_utils/libsvm-mat-3.0-1/');
addpath('../train_classifiers/common_training_code');

load '../../datafiles/region_training/models.mat';
load '../../datafiles/region_training/centroids.mat';

% Read all files
filesList = dir(imageDirectory);
[mRows, mCols] = size(filesList);

% Start Logging
startLog;

% Process all images in a certain directory
for k=1:mRows-2
    t1 = tic;
    filename = strcat(imageDirectory,filesList(k+2).name);
    fprintf('Reading file: %s',filename);
    
    % Initialization and Preprocessing
    [flags,regionMap,smallRegionIDs,dI,I,height,width] = ...
        initSegmenter(filename,maxImgWidth);
    
    % Segmentation
    [smallRegionIDs, nSmallRegions, regionMap] = ...
        segmentImage(dI, flags, rgThreshold, regionMap, ...
                        smallRegionIDs, smallRegionSizeSqPx);
    
    % Cleanup the regionMap
    [regionMap] = ...
        subsumeSmallRegions(regionMap, smallRegionIDs, nSmallRegions, ...
                            windowBorder, height, width);
    
    % Color the regionMap
    nRegions = numel(unique(regionMap));    % Update the number of regionMap
    [coloredSegments] = colorSegmentedImage(regionMap, nRegions, height, width);
    
    % Filename without the extension (assuming .jpg)
    filenameNE = strcat(imageDirectory,substr(filesList(k+2).name,0,-4));
    newfilename = sprintf('%s_numReg_%d_time_%.0f_thr_%.2f_sS_%d.png',...
                  filenameNE,nRegions,toc(t1),rgThreshold,smallRegionSizeSqPx);
    
    % Save segmentation result
    imwrite(coloredSegments,newfilename);
    
    % Attempt recognizing segments
    [labels maxProb] = tryPrediction(I, regionMap, unique(regionMap), nColorBins, nSIFTClusters, nCategories, models, gridUnit, centroids);
    
    % Map the returned labels to the chosen labels
    for i=1:length(labels)
        if (labels(i) ~= -1)
            labels(i) = chosenCategories(labels(i));
        else
            labels(i) = 11;      % Other
        end;
    end;
    
    % Color the image
    I = colorPrediction(I, regionMap, unique(regionMap), labels, gridUnit, maxProb, probThreshold);
    imwrite(I,sprintf('%s_identified.png',filenameNE));
    
    % Save variables and results
    matfilename = sprintf('%s_numReg_%d_time_%.0f_thr_%.2f_sS_%d.mat',...
                    filenameNE,nRegions,toc(t1),rgThreshold,smallRegionSizeSqPx);
    save(matfilename,'regionMap');
    
    disp(sprintf('Finished processing file: %s',filename));
    disp(sprintf('Summary: Number of regionMap = %d, Time elapsed = %.0f seconds.',nRegions,toc(t1)));
end;