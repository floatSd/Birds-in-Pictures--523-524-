function [topLabels] = tryPrediction(I, regionMap, topRegions, nColorBins, nSIFT, nLabels)

numTopRegions = size(topRegions,1);
topLabels = zeros(numTopRegions,1);

for i=1:numTopRegions
    regid = topRegions(i);
    [hist] = rgbhistForRegion(I, regionMap, regid, nColorBins);   % Color histogram
    [visualWord] = computeRegionSIFT(I, regionMap, regid, nSIFT);             % SIFT visual words
    featureVector = [hist;visualWord];
    
    load 'models.mat';                  % Load trained models
    
    probabilities = zeros(nLabels,1);
    for j=1:nLabels
        [predictedLabel, accuracy, prob] = svmpredict([i], featureVector', models{j}, '-b 1');
        probabilities(j) = prob(1);     % Pick the 'Yes' probability
    end;
    
    % Get the label with the highest predicted probability
    disp(probabilities);
    [value location] = max(probabilities);
    disp(sprintf('Max probability for region %d is %.4f with label %d',regid,value,location));
    topLabels(i) = location;
end;