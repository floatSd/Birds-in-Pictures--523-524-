%% To find the visual features of all images
% Outputs a set of .mat files

clear;
clc;

nColorBins = 64;
nSiftClusters = 175;
nSiftDimensions = 128;
nVisualFeatures = 3 * nColorBins + nSiftClusters;

baseImageDirectory = '../../../datafiles/image_training/';
categoryNames = {'grass/','buildings/','mud/','roads/','snow/','water/'};
nCategories = length(categoryNames);

features = cell(nCategories,1);              % Visual features for each image in each category
areas = cell(nCategories,1);                 % Area in Sq. Px. for each image in each category
siftDescriptors = cell(nCategories,1);       % SIFT descriptors for each image in each category

addpath('../common_training_code/');
addpath('../../common_utils/');
addpath('../../common_utils/classifier/');
addpath('../../common_utils/region/');
addpath('../../common_utils/vlfeat-0.9.9/toolbox/mex/mexa64/');

imageDirectories = {strcat(baseImageDirectory,categoryNames{1}),...
                    strcat(baseImageDirectory,categoryNames{2}),...
                    strcat(baseImageDirectory,categoryNames{3}),...
                    strcat(baseImageDirectory,categoryNames{4}),...
                    strcat(baseImageDirectory,categoryNames{5}),...
                    strcat(baseImageDirectory,categoryNames{6})};

%% PART 1: Loop through all images and find the SIFT descriptor and Color Histogram for each image in each category.
for k=1:length(categoryNames)
    % Get a set of files in that folder
    list = dir(imageDirectories{k});
    
    disp(sprintf('Computing color histograms and SIFT descriptors for %d images in category: %s',length(list)-2,categoryNames{k}));
    
    % Allocate space for Visual Features of all files in that folder.
    % Rows = bins for Color Histograms + SIFT visual words, Cols = files
    kFeatures = double(zeros(nVisualFeatures,length(list)-2));
    kAreas = double(zeros(1,length(list)-2));
    kSIFTDescriptors = cell(length(list)-2,1);
    
    for j=1:length(list)-2
        % Read the image
        I = imread(strcat(imageDirectories{k}, list(j+2).name));
        [width,height,z] = size(I);
        
        % Populate the area
        kAreas(1,j) = width*height;
        
        % Populate the bins for the Color Histogram
        kFeatures(1:nColorBins*3,j) = computeImageRGBHistogram(I,nColorBins);
        
        % Check if it is a grayscale image
        if (z ~= 1)
            I = single(rgb2gray(I));
        else I = single(I);
        end;

        % Compute SIFT descriptor
        [f d] = vl_sift(I);
        kSIFTDescriptors{j} = d;
    end;

    features{k} = kFeatures;
    areas{k} = kAreas;
    siftDescriptors{k} = kSIFTDescriptors;
end;

save(strcat(baseImageDirectory,'siftDescriptors.mat'),'siftDescriptors');
clearvars 'siftDescriptors';

%% PART 2: Concatenate random SIFT descriptors and cluster them
disp('Computing clusters....');
centroids = computeSIFTClusters(strcat(baseImageDirectory,'siftDescriptors.mat'), nSiftDimensions, nSiftClusters);

save(strcat(baseImageDirectory,'centroids.mat'),'centroids');

%% PART 3: Calculate Visual Word Histograms
disp('Computing visual words...');
[counts] = computeVW(strcat(baseImageDirectory,'siftDescriptors.mat'), areas, nSiftDimensions, nSiftClusters, centroids);

%% PART 4: Append the Visual Word Histograms to the Color Histograms
for k=1:length(categoryNames)
    kFeatures = features{k};
    kFeatures(nColorBins*3+1:nVisualFeatures,:) = counts{k};
    features{k} = kFeatures;
end;

save(strcat(baseImageDirectory,'features.mat'),'features');
disp('Done.');