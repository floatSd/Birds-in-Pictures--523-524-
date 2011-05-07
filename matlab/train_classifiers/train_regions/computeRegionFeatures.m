%% To find the visual features of all images
% The beast:
% 
clear; clc;

gridUnit = 100;
nColorBins = 64;
nSiftClusters = 50;
nSiftDimensions = 128;
nVisualFeatures = 3 * nColorBins + nSiftClusters;

categoryNames = {'grass','buildings','mud','roads','snow','water',...
                 'sky','leaves','bark','sand','other','bird'};

nCategories = length(categoryNames);

setNames = {'set1'};
nSets = length(setNames);

features = cell(nCategories,1);              % Visual features for each region in each category
areas = cell(nCategories,1);                 % Area in Sq. Px. for each region in each category
siftDescriptors = cell(nCategories,1);       % SIFT descriptors for each region in each category
nSiftDescriptors = cell(nCategories,1);      % Number of SIFT descriptors per region

addpath('.\preprocessing\');
addpath('.\preprocessing\regionResults\');
addpath('.\preprocessing\trainingMaps\');
addpath('..\common_training_code\');
addpath('..\..\common_utils\');
addpath('..\..\common_utils\classifier\');
addpath('..\..\common_utils\region\');
addpath('C:\\Users\\Nikhil\Downloads\\vlfeat-0.9.9-bin\\vlfeat-0.9.9\\toolbox\\');
vl_setup

%% PART 1: Loop through all regions and find the SIFT descriptor and Color Histogram for each region in each category.
nSamples = zeros(nCategories,1);    % How many samples per category
tmFile = '.\preprocessing\trainingMaps\trainingLabelsSET1.mat';
rgFile = '.\preprocessing\regionResults\segmentationSET1.mat';

load(tmFile);           % trainingMaps{}
load(rgFile);           % filenames{} and regionMaps{}

%% PART 1.1 : Make a cursory inspection of how many samples per category are available
nFiles = length(trainingMaps);
for i=1:nFiles
    for j=1:nCategories
        if ~isempty(trainingMaps{i}{j})     % If the cell is not empty
            nEntries = length(trainingMaps{i}{j});
            for p=1:nEntries
                regid = trainingMaps{i}{j}(p);
                if (numel(find(regionMaps{i} == regid)) ~= 0)
                    nSamples(j) = nSamples(j) + 1;
                end;
            end;
        end;
    end;
end;

%% PART 1.2 : Preallocate memory according to how many samples per category were found
for i=1:nCategories
    features{i} = double(zeros(nVisualFeatures,nSamples(i)));
    nSiftDescriptors{i} = double(zeros(1,nSamples(i)));
end;

%% PART 1.3 : Calculate Color Histograms and SIFT features
iIndex = zeros(nCategories,1);      % Keep track of array index position for appending
for f=1:nFiles
    % Read the image
    I = imread(filenames{f});
    [width,height,z] = size(I);
    
    % Look for regions in all categories
    for c=1:nCategories
        regids = trainingMaps{f}{c};
        if ~isempty(regids)
            nRegions = length(regids);
            % For all region IDs, compute Color Histograms and SIFT
            % Descriptors and append them to the collection

            for p=1:nRegions
                regid = regids(p);
                
                if (numel(find(regionMaps{f} == regid)) == 0)
                    continue;           % Illegal region
                end;
                
                iIndex(c) = iIndex(c) + 1;

                features{c}(1:nColorBins*3,iIndex(c)) = ...
                computeRegionRGBHistogram(I,regionMaps{f},regid,nColorBins);
                
                [descriptors] = computeRegionSIFT(I, regionMaps{f}, regid);
                nSiftDescriptors{j}(iIndex(c)) = length(descriptors);
                
                if (isempty(descriptors) ~= 0)
                    disp('Non-Empty descriptors');
                end;
                
                for d=1:length(descriptors)
                    nextPos = length(siftDescriptors{c}) + 1;
                    siftDescriptors{c}{nextPos,1} = descriptors{d};
                end;
            end;
        end;
    end;
end;

save('.\siftDescriptors.mat','siftDescriptors');
clearvars 'siftDescriptors';

for i=1:nCategories
    nSIFT = sum(nSiftDescriptors{i}(:));
    areas{i} = double(zeros(1,nSIFT));
    areas{i}(:) = gridUnit * gridUnit;
end;
%% PART 2: Concatenate random SIFT descriptors and cluster them
disp('Computing clusters....');
centroids = computeSIFTClusters('.\siftDescriptors.mat', nSiftDimensions, nSiftClusters);

save('.\centroids.mat','centroids');

%% PART 3: Calculate Visual Word Histograms
disp('Computing visual words...');
[counts] = computeVW('.\siftDescriptors.mat', areas, nSiftDimensions, nSiftClusters, centroids);

%% PART 4.1: Group the set of SIFT histograms according to how many were used per region per category
newCounts = cell(nCategories,1);
for c=1:nCategories
    newCounts{c} = double(zeros(nSiftClusters,nSamples(c)));
    counter = 0;
    for i=1:nSamples(c)
        tempDescriptor = [];
        for j=1:nSiftDescriptors{c}(i)
            counter = counter + 1;
            tempDescriptor = [tempDescriptor counts(:,counter)];
        end;
        newCounts{c}(i) = mean(tempDescriptor,2);
    end;
end;

%% PART 4.2: Append the Visual Word Histograms to the Color Histograms
for k=1:length(categoryNames)
    kFeatures = features{k};
    kFeatures(nColorBins*3+1:nVisualFeatures,:) = newCounts{k};
    features{k} = kFeatures;
end;

save('.\features.mat','features');
disp('Done.');