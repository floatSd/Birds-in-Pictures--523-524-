%% To find the visual features of all images
% Outputs a set of .mat files

clear;
clc;

nColorBins = 64;
nSiftClusters = 175;
nSiftDimensions = 128;
nVisualFeatures = 3 * nColorBins + nSiftClusters;

features = cell(nCategories,1);              % Visual features for each image in each category
areas = cell(nCategories,1);                 % Area in Sq. Px. for each image in each category
siftDescriptors = cell(nCategories,1);       % SIFT descriptors for each image in each category

addpath('..\..\common_utils\');
addpath('..\..\common_utils\classifier\');
addpath('..\..\common_utils\region\');
addpath('C:\\Users\\Nikhil\Downloads\\vlfeat-0.9.9-bin\\vlfeat-0.9.9\\toolbox\\');
vl_setup

categoryNames = {'grass','buildings','mud','roads','snow','water'};
nCategories = length(categoryNames);

imageDirectories = {'..\..\..\..\images\webimages\training\final\grass\',...
                    '..\..\..\..\images\webimages\training\final\buildings\',...
                    '..\..\..\..\images\webimages\training\final\mud\',...
                    '..\..\..\..\images\webimages\training\final\roads\',...
                    '..\..\..\..\images\webimages\training\final\snow\',...
                    '..\..\..\..\images\webimages\training\final\water\'};

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
        [f kSIFTDescriptors{j}] = vl_sift(I);
    end;

    features{k} = kFeatures;
    areas{k} = kAreas;
    siftDescriptors{k} = kSIFTDescriptors;
end;

save('.\siftDescriptors.mat','siftDescriptors');
clearvars 'siftDescriptors';

%% PART 2: Concatenate random SIFT descriptors and cluster them
disp('Computing clusters....');
centroids = computeSIFTClusters('.\siftDescriptors.mat', nSiftDimensions, nSiftClusters);

save('.\centroids.mat','centroids');

%% PART 3: Calculate Visual Word Histograms
disp('Computing visual words...');
[counts] = computeVW('.\siftDescriptors.mat', areas, nSiftDimensions, nSiftClusters, centroids);

%% PART 4: Append the Visual Word Histograms to the Color Histograms
for k=1:length(categoryNames)
    kFeatures = features{k};
    kFeatures(nColorBins*3+1:nVisualFeatures,:) = counts{k};
    features{k} = kFeatures;
end;

save('.\features.mat','features');
disp('Done.');