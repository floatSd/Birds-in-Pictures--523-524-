function [labels maxProb] = tryPrediction(I, regionMap, regions, nColorBins, nSiftClusters, nCategories, models, gridUnit, centroids)
%% Identifies the set of 'regions', based on the trained classifiers
% Sets -1 as a label if an illegal region is found
nRegions = size(regions,1);
labels = zeros(nRegions,1);
maxProb = zeros(nRegions,1);

for i=1:nRegions
    regid = regions(i);
    [hist] = computeRegionRGBHistogram(I, regionMap, regid, nColorBins);   % Color histogram
    descriptors = computeRegionSIFT(I, regionMap, regid, gridUnit);         % SIFT descriptors
    
    % Handle error cases
    if (isempty(descriptors))
        labels(i) = -1;
        continue;
    end;
    
    % More error handling
    errFlag = 1;
    for d=1:length(descriptors)
        if (isempty(descriptors{d}))
            continue;
        end;
        errFlag = 0;
    end;

    if (errFlag)
        labels(i) = -1;
        continue;
    end;
    
    vw = computeVisualWordFromSIFT(descriptors, centroids, nSiftClusters);
    
    featureVector = [hist;vw];
    
    probabilities = zeros(nCategories,1);
    for j=1:nCategories
        [predictedLabel, accuracy, prob] = svmpredict([i], featureVector', models{j}, '-b 1');
        probabilities(j) = prob(1);     % Pick the 'Yes' probability
    end;
    
    % Get the label with the highest predicted probability
    disp(probabilities);
    [value location] = max(probabilities);
    labels(i) = location;
    maxProb(i) = value;
end;