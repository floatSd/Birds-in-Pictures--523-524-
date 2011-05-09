gridUnit = 50;
nColorBins = 16;
nSiftClusters = 80;
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
% [models{1} probMatrix{1} testingSize{1}] = buildAndTestModel(1, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{2} probMatrix{2} testingSize{2}] = buildAndTestModel(2, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{3} probMatrix{3} testingSize{3}] = buildAndTestModel(3, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{4} probMatrix{4} testingSize{4}] = buildAndTestModel(4, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{5} probMatrix{5} testingSize{5}] = buildAndTestModel(5, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{6} probMatrix{6} testingSize{6}] = buildAndTestModel(6, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{7} probMatrix{7} testingSize{7}] = buildAndTestModel(7, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{8} probMatrix{8} testingSize{8}] = buildAndTestModel(8, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{9} probMatrix{9} testingSize{9}] = buildAndTestModel(9, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{10} probMatrix{10} testingSize{10}] = buildAndTestModel(10, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{11} probMatrix{11} testingSize{11}] = buildAndTestModel(11, 8, 2, '../../../datafiles/region_training/', nCategories);
% [models{12} probMatrix{12} testingSize{12}] = buildAndTestModel(12, 8, 2, '../../../datafiles/region_training/', nCategories);

for i=1:nCategories
    disp(sprintf('Category: %s',categoryNames{i}));
    [models{i} probMatrix{i} testingSize{i}] = buildAndTestModel(i, 64, 1/8, '../../../datafiles/region_training/', nCategories);
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