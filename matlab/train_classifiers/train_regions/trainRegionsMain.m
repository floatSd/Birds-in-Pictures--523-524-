gridUnit = 40;
nColorBins = 16;
nSiftClusters = 75;
nSiftDimensions = 128;
nCategories = 12;

models = cell(nCategories,1);
probMatrix = cell(nCategories,1);
testingSize = cell(nCategories,1);

addpath('./preprocessing/');
addpath('../common_training_code');
addpath('../../common_utils/libsvm-mat-3.0-1/');

categoryNames = {'grass','buildings','mud','roads','snow','water',...
                 'sky','leaves','bark','sand','other','bird'};
             
%% PART 1: Compute visual features
% computeRegionFeatures(gridUnit, nColorBins, nSiftClusters, nSiftDimensions);           % TO DO Fix path problem Need to run only once

%% PART 2: Prepare sets of positive and negative examples
prepareTrainingMatrices('../../../datafiles/region_training/', nColorBins, nSiftClusters, nCategories);        % Need to run only once

%% PART 3: Train the models
% [models{1} probMatrix{1} testingSize{1}] = buildAndTestModel(1, 30, 1/30, '../../../datafiles/region_training/', nCategories);
% [models{2} probMatrix{2} testingSize{2}] = buildAndTestModel(2, 100, 1/25, '../../../datafiles/region_training/', nCategories);

for i=1:nCategories
    disp(sprintf('Category: %s',categoryNames{i}));
    [models{i} probMatrix{i} testingSize{i}] = buildAndTestModel(i, 30, 1/30, '../../../datafiles/region_training/', nCategories);
end;

%% PART 4: Process the results in a human understandable manner
reorderedProbMatrix = cell(nCategories,1);
for i=1:nCategories
    reorderedProbMatrix{i} = zeros(nCategories,testingSize{i});
    for j=1:nCategories
        reorderedProbMatrix{i}(j,:) = probMatrix{j}{i};
    end;
end;

% Compute confusion matrix
confusionMatrix = zeros(nCategories,nCategories);
for i=1:nCategories
    % Count how many times each label was maximum
    counts = zeros(nCategories,1);
    for k=1:testingSize{i}
        [value location] = max(reorderedProbMatrix{i}(:,k));
        counts(location) = counts(location) + 1;
    end;
    for j=1:nCategories
        confusionMatrix(i,j) = counts(j);
    end;
end;

accuracies = double(zeros(nCategories,1));
for i=1:nCategories
    disp(sprintf('Accuracy for label %s is %.2f %',categoryNames{i},100*confusionMatrix(i,i)/sum(confusionMatrix(i,:))));
    accuracies(i) = 100*double(confusionMatrix(i,i))/double(sum(confusionMatrix(i,:)));
end;
save('../../../datafiles/region_training/confusion.mat','confusionMatrix');