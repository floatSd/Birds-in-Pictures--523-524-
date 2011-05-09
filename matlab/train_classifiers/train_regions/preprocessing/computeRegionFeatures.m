function computeRegionFeatures(gridUnit, nColorBins, nSiftClusters, nSiftDimensions)
%% To find the visual features of all regions
% The beast:
nVisualFeatures = 3 * nColorBins + nSiftClusters;

baseImageDirectory = '../../../../datafiles/region_training/';
categoryNames = {'grass','buildings','mud','roads','snow','water',...
                 'sky','leaves','bark','sand','other','bird'};

nCategories = length(categoryNames);

features = cell(nCategories,1);              % Visual features for each region in each category
areas = cell(nCategories,1);                 % Area in Sq. Px. for each region in each category
siftDescriptors = cell(nCategories,1);       % SIFT descriptors for each region in each category

addpath('../../common_training_code/');
addpath('../../../common_utils/');
addpath('../../../common_utils/classifier/');
addpath('../../../common_utils/region/');
addpath('../../../common_utils/vlfeat-0.9.9/toolbox/mex/mexa64/');

tlFile = strcat(baseImageDirectory,'concat_tl.mat');
rgFile = strcat(baseImageDirectory,'concat_rmap.mat');

load(tlFile);           % trainingMaps{}
load(rgFile);           % filenames{} and regionMaps{}

%% PART 1: Loop through all regions and find the SIFT descriptor and Color Histogram for each region in each category.
% Preallocate memory according to how many training samples per category were found
% This is memory for the final set of descriptors (features) per region,
% per category
nFiles = length(trainingMaps);

for i=1:nCategories
    features{i} = []; % double(zeros(nVisualFeatures,nSamples(i)));
end;

%% PART 1.1 : Calculate Color Histograms and SIFT features
iIndex = uint16(ones(nCategories,1));       % Keep track of array index position for appending color histograms
nSiftDescriptors = cell(nCategories,1);     % Number of SIFT descriptors per region. Each region within a category is uniquely identified by iIndex(c)

for i=1:nCategories
    nSiftDescriptors{i} = [];
end;

for f=1:nFiles
    disp(sprintf('Processing file #%d: %s',f,filenames{f}));
    
    % Read the image
    I = imread(filenames{f});
    [width,height,z] = size(I);
    
    % Look for regions in all categories
    for c=1:nCategories
        % Get the set of region IDs for that category
        regids = trainingMaps{f}{c};
        
        % Remove any duplicates
        regids = unique(regids);
        
        if ~isempty(regids)
            % How many regions?
            nRegions = length(regids);
            
            % For all region IDs, compute Color Histograms and SIFT
            % Descriptors and append them to the collection

            for p=1:nRegions
                regid = regids(p);
                
                % Is it a non-existent region id?
                if (numel(find(regionMaps{f} == regid)) == 0)
                    continue;
                end;
                
                % Another potential problem is that no SIFT descriptors may
                % be available for this region. This is done using the
                % below logic
                
                % Get a set of SIFT descriptors for that region (as a cell array)
                descriptors = computeRegionSIFT(I, regionMaps{f}, regid, gridUnit);
                
                if (isempty(descriptors))
                    disp(sprintf('Empty descriptors found for region %d!! Ignoring region.',regid));
                    continue;
                end;
                
                dlen = 0;
                
                errFlag = 1;
                % Append the descriptors
                for d=1:length(descriptors)
                    if (isempty(descriptors{d}))
                        continue;
                    end;
                    errFlag = 0;
                    nextPos = length(siftDescriptors{c}) + 1;
                    siftDescriptors{c}{nextPos,1} = descriptors{d};
                    dlen = dlen + 1;
                end;
                
                if (errFlag)
                    continue;
                end;
                
                % Store the number of SIFT descriptors for that region
                nSiftDescriptors{c}(iIndex(c)) = dlen;
                
                % The no overheads part: Compute RGB Color Histograms
                features{c} = [features{c} double(zeros(nVisualFeatures,1));];
                colorHistogram = computeRegionRGBHistogram(I,regionMaps{f},regid,nColorBins);
                features{c}(1:nColorBins*3,iIndex(c)) = colorHistogram;
                
                % Increment the counter for that category
                iIndex(c) = iIndex(c) + 1;
            end;
        end;
    end;
end;

save(strcat(baseImageDirectory,'siftDescriptors.mat'),'siftDescriptors');

% Prepare the set of areas (all of them the same)
for i=1:nCategories
    nSIFT = length(siftDescriptors{i});
    areas{i} = double(zeros(1,nSIFT));
    areas{i}(:) = gridUnit * gridUnit;
end;

%% PART 2: Concatenate random SIFT descriptors and cluster them
disp('Computing clusters....');
centroids = computeSIFTClusters(strcat(baseImageDirectory,'siftDescriptors.mat'), nSiftDimensions, nSiftClusters, 1.0);

% load(strcat(baseImageDirectory,'centroids.mat'));
save(strcat(baseImageDirectory,'centroids.mat'),'centroids');

%% PART 3: Calculate Visual Word Histograms
disp('Computing visual words...');
[counts] = computeVW(strcat(baseImageDirectory,'siftDescriptors.mat'), areas, nSiftDimensions, nSiftClusters, centroids);

%% PART 4.1: Group the set of SIFT histograms according to how many were used per region per category
newCounts = cell(nCategories,1);

for c=1:nCategories
    counter = 0;
    % Actual number of regions that got their feature descriptors computed
    newCounts{c} = double(zeros(nSiftClusters,length(nSiftDescriptors{c})));
    for i=1:length(nSiftDescriptors{c})
        tempDescriptor = [];
        for j=1:nSiftDescriptors{c}(i)
            counter = counter + 1;
            tempDescriptor = [tempDescriptor counts{c}(:,counter)];
        end;
        ans = mean(tempDescriptor,2);
        newCounts{c}(:,i) = ans;
    end;
end;

%% PART 4.2: Append the Visual Word Histograms to the Color Histograms
for k=1:nCategories
    kFeatures = features{k};
    kFeatures(nColorBins*3+1:nVisualFeatures,1:size(newCounts{k},2)) = newCounts{k};
    
    for i=1:size(kFeatures,2)
        x = kFeatures(:,i);
        x = x/norm(x);
        kFeatures(:,i) = x;
    end;
        
    features{k} = kFeatures;
end;

save(strcat(baseImageDirectory,'features.mat'),'features');
disp('Done.');