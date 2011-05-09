function prepareTrainingMatrices(baseDirectory, nColorBins, nSiftClusters, nCategories)
% Prepare the set of training and testing matrices

nVisualFeatures = 3 * nColorBins + nSiftClusters;

trainingMatrices = cell(nCategories,1); % Matrices used to train models for each category
testingMatrices = cell(nCategories,1);  % Matrices used to test models for each category
trainingLabels = cell(nCategories,1);
testingLabels = cell(nCategories,1);
nAllPositives = cell(nCategories,1);    % Records how many positive samples for each category

load(strcat(baseDirectory,'features.mat'));             % features{}

disp('Preparing matrices for training...');
% Prepare training sets
for i=1:nCategories
    % Calculate number of positive samples for Label 'i'
    iPositiveSamples = floor(size(features{i},2)/2);
    nAllPositives{i} = iPositiveSamples;
    
    % Calculate number of negative samples for Label 'i'
    nNegativeSamples = 0;
    for j=1:nCategories
        if i~=j
            % All other labels are negative samples
            nNegativeSamples = nNegativeSamples + size(features{j},2);
        end;
    end;
    
    % Initialize
    % Rows = features, Cols = #File
    trainingMatrices{i} = ...
        double(zeros(nVisualFeatures, iPositiveSamples + nNegativeSamples));
    testingMatrices{i} = ...
        double(zeros(nVisualFeatures, size(features{i},2) - iPositiveSamples));
    % Rows = #File, Col = 1/0
    trainingLabels{i} = ...
        double(zeros(iPositiveSamples + nNegativeSamples,1));
    testingLabels{i} = ...
        double(zeros(size(features{i},2) - iPositiveSamples,1));
    
    % Populate training positive samples
    trainingMatrices{i}(:,1:iPositiveSamples) = ...
        features{i}(:,1:iPositiveSamples);
    trainingLabels{i}(1:iPositiveSamples) = i;      % Non-zero
    
    % Populate testing samples (remaining positive samples)
    testingMatrices{i}(:,:) = ...
        features{i}(:,iPositiveSamples+1:size(features{i},2));
    testingLabels{i}(:) = i;
    
    % Initialize training negative samples
    startCol = iPositiveSamples+1;
    for j=1:nCategories
        if i~=j
            % All other labels are negative samples
            iNegtiveSamples = size(features{j},2);
            
            trainingMatrices{i}(:,startCol:startCol+iNegtiveSamples-1) = ...
                features{j}(:,1:iNegtiveSamples);
            trainingLabels{i}(startCol:startCol+iNegtiveSamples-1) = 0;
            
            startCol = startCol+iNegtiveSamples;
        end;
    end;
end;

save(strcat(baseDirectory,'trainingMatrices.mat'),'trainingMatrices',...
    'trainingLabels','testingMatrices','testingLabels');