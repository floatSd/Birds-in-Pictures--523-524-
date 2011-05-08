function segmentImageSet(setName)
%% TASK : Segmenting images to get regions, based on a (color) region
%% growing algorithm

% Define constants
rgThreshold = 0.10;             % Threshold for region growing segmentation
maxImgWidth = 400;              % Resize if more than this
smallRegionSize = 65;           % In square pixels
border = 5;                     % Around a region when subsuming

baseImageDirectory = '../../../../datafiles/region_training/';
imageDirectory = sprintf('%soriginal_images/%s/',baseImageDirectory,setName);

% Add the necessary paths
addpath('../../../common_utils/');
addpath('../../../common_utils/classifier/');
addpath('../../../common_utils/region/');
addpath('../../../common_utils/segmentation/');

% Read all files
disp(sprintf('Scanning directory %s...',imageDirectory));
list = dir(strcat(imageDirectory,'*.jpg'));
[mRows, mCols] = size(list);
disp(sprintf('Found %d files...',mRows));

filenames = {};
regionMaps = {};

for k=1:mRows
    t1 = tic;
    filename = strcat(imageDirectory,list(k).name);
    disp(sprintf('Reading file: %s',filename));
    
    % Initialization and Preprocessing
    [flags,kRegionMap,smallRegionIDs,dI,I,m,n] = ...
        initSegmenter(filename,maxImgWidth);
    
    % Segmentation
    [smallRegionIDs, nSmallRegions, kRegionMap] = ...
        segmentImage(dI, flags, rgThreshold, kRegionMap, smallRegionIDs, smallRegionSize);
    
    % Cleanup the kRegionMap
    [kRegionMap] = ...
        subsumeSmallRegions(kRegionMap, smallRegionIDs, nSmallRegions, border, m, n);
    
    filenames{k} = filename;
    regionMaps{k} = kRegionMap;
    
    disp(sprintf('Finished processing file: %s',filename));
end;

% Save variables and results
savefile = sprintf('%srmap_%s.mat',baseImageDirectory,setName);
save(savefile,'regionMaps','filenames');